-- HISTORIA: 後から足した表と列（自動生成 — 手で編集しない）
-- 作り直す: npx tsx scripts/db/dump-migration.ts
--
-- 既に docs/schema.sql を流してしまったデータベースに、後から足した分だけを当てる。
-- Supabase の SQL エディタに貼って実行する。何度流しても結果は同じになる。
--
-- 新しいデータベースにはこのファイルは要らない。docs/schema.sql に同じものが入っている。
--
-- この差分のあと、seed/sql/03_rls.sql を流し直すこと。
-- 新しい表の RLS とポリシーはそちらが貼る（ここでは出さない。二重に書くとずれる）。

BEGIN;

-- ---- push_subscription ----
CREATE TABLE IF NOT EXISTS push_subscription (
  endpoint   text PRIMARY KEY,
  user_id    uuid NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  p256dh     text NOT NULL,
  auth       text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  last_sent_at timestamptz
);
CREATE INDEX IF NOT EXISTS push_subscription_user_id_idx ON push_subscription (user_id);

-- ---- ops_log ----
CREATE TABLE IF NOT EXISTS ops_log (
  id     bigserial PRIMARY KEY,
  kind   text NOT NULL CHECK (kind IN ('remind','video_healthcheck','reap_reservations')),
  ok     boolean NOT NULL,
  detail jsonb,
  ran_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS ops_log_kind_ran_at_idx ON ops_log (kind, ran_at DESC);

-- ---- app_user.remind_hour ----
ALTER TABLE app_user ADD COLUMN IF NOT EXISTS remind_hour smallint CHECK (remind_hour BETWEEN 0 AND 23);

COMMIT;

-- ---- 確認 ----
-- 表 が 2、列 が 1 になっていれば当たっている。
SELECT
  (SELECT count(*) FROM pg_tables WHERE schemaname = 'public'
     AND tablename IN ('push_subscription', 'ops_log')) AS 表,
  (SELECT count(*) FROM information_schema.columns WHERE table_schema = 'public'
     AND (table_name, column_name) IN (('app_user', 'remind_hour'))) AS 列;
