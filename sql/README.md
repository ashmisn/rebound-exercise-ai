# REBOUND SQL layer

This directory contains the reviewable PostgreSQL layer for the data the application currently writes and reads.

| File | Purpose |
| --- | --- |
| [`schema.sql`](schema.sql) | `public.user_sessions` table, constraints, indexes, and RLS policies |
| [`seed.sql`](seed.sql) | Commented local/demo insert template; no fabricated records are committed |
| [`analytics.sql`](analytics.sql) | Progress, exercise, weekly activity, adherence, streak, and return-behavior queries |

The application has session-level data only. One `user_sessions` row represents one completed exercise session; no event table or duration column exists today. Analytics therefore pre-aggregate nothing from a child event table and explicitly mark event-level and duration-based metrics as unsupported.

Supabase Auth owns `auth.users`, and `user_sessions.user_id` references it. Review `schema.sql` against an existing Supabase project before applying it, especially if RLS policies already exist.
