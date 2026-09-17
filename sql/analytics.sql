-- REBOUND analytics for public.user_sessions.
--
-- Grain: one row is one completed exercise session. There is no event-level
-- table in the current application, so these queries do not join sessions to
-- events and cannot multiply session-level values through an event join.
-- Replace :user_id with a UUID parameter in the calling client.

-- 1. User progress: totals, repetition-weighted accuracy, and latest session.
select
  count(*) as total_sessions,
  coalesce(sum(reps_completed), 0) as total_reps,
  round(
    coalesce(
      sum(reps_completed * accuracy_score)
        / nullif(sum(reps_completed), 0),
      0
    ),
    1
  ) as weighted_average_accuracy,
  max(created_at) as most_recent_session
from public.user_sessions
where user_id = :user_id;

-- Duration is not available: /api/save_session does not write a duration
-- column, so total exercise duration cannot be honestly calculated yet.

-- 2. Exercise-level sessions, repetitions, and average accuracy.
select
  exercise_name,
  count(*) as sessions,
  coalesce(sum(reps_completed), 0) as total_reps,
  round(avg(accuracy_score), 1) as average_accuracy,
  max(created_at) as most_recent_session
from public.user_sessions
where user_id = :user_id
group by exercise_name
order by total_reps desc, exercise_name;

-- 3. Most recently performed exercise for one user.
select exercise_name, session_date, reps_completed, accuracy_score, created_at
from public.user_sessions
where user_id = :user_id
order by created_at desc
limit 1;

-- 4. Weekly activity: sessions and repetitions by ISO week.
select
  date_trunc('week', created_at)::date as week_start,
  count(*) as sessions,
  coalesce(sum(reps_completed), 0) as total_reps
from public.user_sessions
where user_id = :user_id
group by week_start
order by week_start;

-- Active duration per week is not supported because session duration is not
-- stored. Do not estimate it from request timestamps.

-- 5. Adherence signals over the last 30 calendar days.
select
  count(*) as sessions_30d,
  count(distinct session_date) as active_days_30d,
  count(distinct date_trunc('week', session_date)) as active_weeks_30d,
  round(
    count(*)::numeric / (30.0 / 7.0),
    1
  ) as average_sessions_per_week_30d,
  coalesce(sum(reps_completed), 0) as reps_30d
from public.user_sessions
where user_id = :user_id
  and session_date >= current_date - 29;

-- 6. Current consecutive-day streak for one user.
with active_days as (
  select distinct session_date
  from public.user_sessions
  where user_id = :user_id
),
numbered as (
  select
    session_date,
    session_date - (row_number() over (order by session_date))::int as streak_group
  from active_days
),
streaks as (
  select
    streak_group,
    min(session_date) as streak_start,
    max(session_date) as streak_end,
    count(*) as streak_days
  from numbered
  group by streak_group
)
select streak_start, streak_end, streak_days
from streaks
where streak_end >= current_date - 1
order by streak_end desc
limit 1;

-- 7. First completed session for every user represented in the table.
select distinct on (user_id)
  user_id,
  session_date as first_session_date,
  created_at as first_session_at,
  exercise_name
from public.user_sessions
order by user_id, created_at;

-- 8. Returning-user rate and seven-day return rate.
with first_sessions as (
  select user_id, min(created_at) as first_session_at
  from public.user_sessions
  group by user_id
),
return_flags as (
  select
    f.user_id,
    exists (
      select 1
      from public.user_sessions s
      where s.user_id = f.user_id
        and s.created_at > f.first_session_at
    ) as returned,
    exists (
      select 1
      from public.user_sessions s
      where s.user_id = f.user_id
        and s.created_at > f.first_session_at
        and s.created_at <= f.first_session_at + interval '7 days'
    ) as returned_within_7_days
  from first_sessions f
)
select
  count(*) as users_with_a_session,
  count(*) filter (where returned) as returning_users,
  round(100.0 * count(*) filter (where returned)
    / nullif(count(*), 0), 1) as returning_user_rate_pct,
  count(*) filter (where returned_within_7_days) as users_returned_within_7_days,
  round(100.0 * count(*) filter (where returned_within_7_days)
    / nullif(count(*), 0), 1) as seven_day_return_rate_pct
from return_flags;

-- A product-level session completion rate is not supported: the current
-- schema stores completed sessions only and does not record starts, target
-- sets, abandonments, or failed attempts.
