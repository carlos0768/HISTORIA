-- HISTORIA: RLS の修正（自動生成 — 手で編集しない）
-- 作り直す: npx tsx scripts/db/dump-rls.ts
--
-- 既に docs/schema.sql を流してしまったデータベースを、いまの docs/schema.sql に
-- 追いつかせるための差分である。Supabase の SQL エディタに貼って実行する。
-- 何度流しても結果は同じになる。
--
-- 直すもの（2026-09-02 に本番のデータベースを読んで見つけた3件）:
--
--   1. v_weakness_evidence が「定義者の権限で実行する」ビューだった。
--      response の RLS を素通りするため、公開されている anon キー1本で
--      /rest/v1/v_weakness_evidence を叩くだけで全利用者の解答履歴が読めた。
--
--   2. 19 の表で RLS が無効だった。Supabase は public に作った表へ
--      anon / authenticated の ALL を既定で付けるので、無効は「誰でも
--      読み書きできる」を意味する。実測: 
--        has_table_privilege('anon','public.kc','DELETE') → true
--
--   3. ポリシーが PUBLIC 向けだった。material_select の「OR user_id IS NULL」
--      （共有教材）は anon にも当たるため、未ログインで共有教材の本文が読めた。
--      HISTORIA は招待制（上限10名・docs/10）なので、これは意図と違う。

BEGIN;

-- ---- 1. ビューを「問い合わせた本人の権限」で評価させる ----
ALTER VIEW v_weakness_evidence SET (security_invoker = true);

-- ---- 2. public の全ての表で RLS を有効にする（42 表）----
ALTER TABLE app_user             ENABLE ROW LEVEL SECURITY;
ALTER TABLE drill                ENABLE ROW LEVEL SECURITY;
ALTER TABLE drill_kc             ENABLE ROW LEVEL SECURITY;
ALTER TABLE drill_unit           ENABLE ROW LEVEL SECURITY;
ALTER TABLE response             ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_kc_state        ENABLE ROW LEVEL SECURITY;
ALTER TABLE kc_card              ENABLE ROW LEVEL SECURITY;
ALTER TABLE misconception        ENABLE ROW LEVEL SECURITY;
ALTER TABLE check_test           ENABLE ROW LEVEL SECURITY;
ALTER TABLE material_read        ENABLE ROW LEVEL SECURITY;
ALTER TABLE material             ENABLE ROW LEVEL SECURITY;
ALTER TABLE material_section     ENABLE ROW LEVEL SECURITY;
ALTER TABLE material_section_kc  ENABLE ROW LEVEL SECURITY;
ALTER TABLE item                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE generation_job       ENABLE ROW LEVEL SECURITY;
ALTER TABLE video_view           ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_activity        ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_daily_plan      ENABLE ROW LEVEL SECURITY;
ALTER TABLE evidence_import      ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_report       ENABLE ROW LEVEL SECURITY;
ALTER TABLE app_setting          ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_budget            ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_spend             ENABLE ROW LEVEL SECURITY;
ALTER TABLE era                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE region               ENABLE ROW LEVEL SECURITY;
ALTER TABLE person               ENABLE ROW LEVEL SECURITY;
ALTER TABLE syllabus_unit        ENABLE ROW LEVEL SECURITY;
ALTER TABLE kc                   ENABLE ROW LEVEL SECURITY;
ALTER TABLE kc_region            ENABLE ROW LEVEL SECURITY;
ALTER TABLE kc_syllabus_unit     ENABLE ROW LEVEL SECURITY;
ALTER TABLE canon_event          ENABLE ROW LEVEL SECURITY;
ALTER TABLE video                ENABLE ROW LEVEL SECURITY;
ALTER TABLE video_kc             ENABLE ROW LEVEL SECURITY;
ALTER TABLE invite_code          ENABLE ROW LEVEL SECURITY;
ALTER TABLE kc_proposal          ENABLE ROW LEVEL SECURITY;
ALTER TABLE kc_merge             ENABLE ROW LEVEL SECURITY;
ALTER TABLE item_kc              ENABLE ROW LEVEL SECURITY;
ALTER TABLE channel_allowlist    ENABLE ROW LEVEL SECURITY;
ALTER TABLE past_exam            ENABLE ROW LEVEL SECURITY;
ALTER TABLE past_exam_element    ENABLE ROW LEVEL SECURITY;
ALTER TABLE past_exam_kc         ENABLE ROW LEVEL SECURITY;
ALTER TABLE evidence_claim       ENABLE ROW LEVEL SECURITY;

-- ---- 3. ポリシーを貼り直す（34 本）----
-- ★ ポリシーには CREATE OR REPLACE も IF NOT EXISTS も無い。
--   DROP IF EXISTS → CREATE が、何度流しても同じにする唯一の書き方である。

DROP POLICY IF EXISTS app_user_select ON app_user;
CREATE POLICY app_user_select ON app_user
  FOR SELECT TO authenticated USING (id = (SELECT auth.uid()));

DROP POLICY IF EXISTS response_select ON response;
CREATE POLICY response_select ON response
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS drill_all ON drill;
CREATE POLICY drill_all ON drill
  FOR ALL TO authenticated USING (user_id = (SELECT auth.uid()))
  WITH CHECK (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS drill_kc_all ON drill_kc;
CREATE POLICY drill_kc_all ON drill_kc
  FOR ALL TO authenticated USING (EXISTS (SELECT 1 FROM drill d
                         WHERE d.id = drill_kc.drill_id AND d.user_id = (SELECT auth.uid())))
  WITH CHECK (EXISTS (SELECT 1 FROM drill d
                      WHERE d.id = drill_kc.drill_id AND d.user_id = (SELECT auth.uid())));

DROP POLICY IF EXISTS drill_unit_all ON drill_unit;
CREATE POLICY drill_unit_all ON drill_unit
  FOR ALL TO authenticated USING (EXISTS (SELECT 1 FROM drill d
                         WHERE d.id = drill_unit.drill_id AND d.user_id = (SELECT auth.uid())))
  WITH CHECK (EXISTS (SELECT 1 FROM drill d
                      WHERE d.id = drill_unit.drill_id AND d.user_id = (SELECT auth.uid())));

DROP POLICY IF EXISTS material_read_select ON material_read;
CREATE POLICY material_read_select ON material_read
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS material_read_insert ON material_read;
CREATE POLICY material_read_insert ON material_read
  FOR INSERT TO authenticated WITH CHECK (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS video_view_select ON video_view;
CREATE POLICY video_view_select ON video_view
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS video_view_insert ON video_view;
CREATE POLICY video_view_insert ON video_view
  FOR INSERT TO authenticated WITH CHECK (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS content_report_select ON content_report;
CREATE POLICY content_report_select ON content_report
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS content_report_insert ON content_report;
CREATE POLICY content_report_insert ON content_report
  FOR INSERT TO authenticated WITH CHECK (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS evidence_import_select ON evidence_import;
CREATE POLICY evidence_import_select ON evidence_import
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS evidence_import_insert ON evidence_import;
CREATE POLICY evidence_import_insert ON evidence_import
  FOR INSERT TO authenticated WITH CHECK (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS user_kc_state_select ON user_kc_state;
CREATE POLICY user_kc_state_select ON user_kc_state
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS kc_card_select ON kc_card;
CREATE POLICY kc_card_select ON kc_card
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS misconception_select ON misconception;
CREATE POLICY misconception_select ON misconception
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS user_activity_select ON user_activity;
CREATE POLICY user_activity_select ON user_activity
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS user_daily_plan_select ON user_daily_plan;
CREATE POLICY user_daily_plan_select ON user_daily_plan
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS check_test_select ON check_test;
CREATE POLICY check_test_select ON check_test
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS material_select ON material;
CREATE POLICY material_select ON material
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()) OR user_id IS NULL);

DROP POLICY IF EXISTS material_section_select ON material_section;
CREATE POLICY material_section_select ON material_section
  FOR SELECT TO authenticated USING (EXISTS (
    SELECT 1 FROM material m
     WHERE m.id = material_section.material_id
       AND m.status = 'ready'
       AND (m.user_id = (SELECT auth.uid()) OR m.user_id IS NULL)));

DROP POLICY IF EXISTS material_section_kc_select ON material_section_kc;
CREATE POLICY material_section_kc_select ON material_section_kc
  FOR SELECT TO authenticated USING (EXISTS (
    SELECT 1 FROM material_section s JOIN material m ON m.id = s.material_id
     WHERE s.id = material_section_kc.section_id
       AND m.status = 'ready'
       AND (m.user_id = (SELECT auth.uid()) OR m.user_id IS NULL)));

DROP POLICY IF EXISTS generation_job_select ON generation_job;
CREATE POLICY generation_job_select ON generation_job
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));

DROP POLICY IF EXISTS era_select ON era;
CREATE POLICY era_select               ON era               FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS region_select ON region;
CREATE POLICY region_select            ON region            FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS person_select ON person;
CREATE POLICY person_select            ON person            FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS syllabus_unit_select ON syllabus_unit;
CREATE POLICY syllabus_unit_select     ON syllabus_unit     FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS kc_select ON kc;
CREATE POLICY kc_select                ON kc                FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS kc_region_select ON kc_region;
CREATE POLICY kc_region_select         ON kc_region         FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS kc_syllabus_unit_select ON kc_syllabus_unit;
CREATE POLICY kc_syllabus_unit_select  ON kc_syllabus_unit  FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS canon_event_select ON canon_event;
CREATE POLICY canon_event_select       ON canon_event       FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS video_select ON video;
CREATE POLICY video_select             ON video             FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS video_kc_select ON video_kc;
CREATE POLICY video_kc_select          ON video_kc          FOR SELECT TO authenticated USING (true);

DROP POLICY IF EXISTS evidence_claim_select ON evidence_claim;
CREATE POLICY evidence_claim_select ON evidence_claim
  FOR SELECT TO authenticated USING (EXISTS (
    SELECT 1 FROM evidence_import i
     WHERE i.id = evidence_claim.import_id AND i.user_id = (SELECT auth.uid())));

COMMIT;

-- ---- 確認 ----
-- rls_無効な表 が 0、ポリシー本数 が 34 になっていれば当たっている。
SELECT
  (SELECT count(*) FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
    WHERE n.nspname = 'public' AND c.relkind = 'r' AND NOT c.relrowsecurity) AS rls_無効な表,
  (SELECT count(*) FROM pg_policies WHERE schemaname = 'public') AS ポリシー本数,
  (SELECT reloptions FROM pg_class WHERE relname = 'v_weakness_evidence') AS ビューの設定;
