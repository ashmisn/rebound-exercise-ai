-- REBOUND has no committed seed rows.
--
-- Session rows reference auth.users, so a valid Supabase test account must be
-- created first. For local/demo testing, replace the placeholder UUID and
-- uncomment the insert below. Do not use real patient data in a repository.

-- insert into public.user_sessions
--   (user_id, exercise_name, reps_completed, accuracy_score, session_date)
-- values
--   ('00000000-0000-0000-0000-000000000000', 'Shoulder Flexion', 5, 100.00, current_date);
