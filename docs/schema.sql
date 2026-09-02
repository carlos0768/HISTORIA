-- =====================================================================
-- HISTORIA — PostgreSQL スキーマ v0.3
-- 仕様の詳細は docs/03-data-model.md および各章を参照
--
-- 前提: PostgreSQL 15+ / Supabase
-- 拡張: vector (pgvector), pgroonga（日本語全文検索・Phase2）
--
-- 検証: psql -f docs/schema.sql
-- =====================================================================

CREATE EXTENSION IF NOT EXISTS vector;

-- =====================================================================
-- 1. マスタ（facet）        docs/02-domain-model.md §4
-- =====================================================================

-- 測定用の粗い時代グリッド。教科書の章立てとは独立（§4.1）
CREATE TABLE era (
  id         smallint PRIMARY KEY,
  label      text     NOT NULL,
  start_year int      NOT NULL,          -- 負値は紀元前
  end_year   int      NOT NULL,
  ord        smallint NOT NULL,
  CHECK (end_year > start_year)
);

-- 地域の階層マスタ。grid_id は診断テスト用の粗グリッド（4値）
CREATE TABLE region (
  id        smallint PRIMARY KEY,
  label     text     NOT NULL,
  parent_id smallint REFERENCES region(id),
  grid_id   smallint NOT NULL CHECK (grid_id BETWEEN 1 AND 4),
  ord       smallint NOT NULL
);

CREATE TABLE person (
  id      int GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  label   text     NOT NULL UNIQUE,
  aliases text[]   NOT NULL DEFAULT '{}',   -- 「フビライ/クビライ」等の表記ゆれ
  era_id  smallint REFERENCES era(id)
);

-- 教科書の部・章・節。集中特訓の範囲指定と教材の生成単位（§4.4）
CREATE TABLE syllabus_unit (
  id        text     PRIMARY KEY,           -- 'wh.2.4.1'
  subject   text     NOT NULL CHECK (subject IN ('world_history','general_history')),
  parent_id text     REFERENCES syllabus_unit(id),
  level     smallint NOT NULL CHECK (level BETWEEN 1 AND 3),  -- 1=部 2=章 3=節
  label     text     NOT NULL,
  ord       smallint NOT NULL
);
CREATE INDEX ON syllabus_unit (parent_id, ord);

-- =====================================================================
-- 2. 知識単位 KC           docs/02-domain-model.md §1, §7
-- =====================================================================

CREATE TABLE kc (
  id              text PRIMARY KEY,          -- 'kc.islam.umayyad_vs_abbasid'
  label           text NOT NULL,
  kind            text NOT NULL
                  CHECK (kind IN ('fact','distinction','causal','chronology','geo')),
  era_id          smallint REFERENCES era(id),
  person_id       int      REFERENCES person(id),
  year_from       int,
  year_to         int,
  year_precision  text CHECK (year_precision IN ('exact','decade','century','unknown')),
  prereq_ids      text[]  NOT NULL DEFAULT '{}',
  exam_weight     real    NOT NULL DEFAULT 1.0 CHECK (exam_weight >= 0),
  base_difficulty real    NOT NULL DEFAULT 0.0,
  embedding       vector(768),
  retired         boolean NOT NULL DEFAULT false,
  created_at      timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON kc (era_id) WHERE NOT retired;
CREATE INDEX ON kc (person_id) WHERE person_id IS NOT NULL;
CREATE INDEX ON kc USING hnsw (embedding vector_cosine_ops);

-- KC と地域は多対多。対外関係史は単一地域に属さない（§6）
CREATE TABLE kc_region (
  kc_id      text     NOT NULL REFERENCES kc(id) ON DELETE CASCADE,
  region_id  smallint NOT NULL REFERENCES region(id),
  is_primary boolean  NOT NULL DEFAULT false,
  PRIMARY KEY (kc_id, region_id)
);
CREATE UNIQUE INDEX kc_region_one_primary ON kc_region (kc_id) WHERE is_primary;

CREATE TABLE kc_syllabus_unit (
  kc_id   text NOT NULL REFERENCES kc(id) ON DELETE CASCADE,
  unit_id text NOT NULL REFERENCES syllabus_unit(id),
  PRIMARY KEY (kc_id, unit_id)
);
CREATE INDEX ON kc_syllabus_unit (unit_id);

-- LLM が新KCを必要としたときの提案キュー。作者承認制（§5）
CREATE TABLE kc_proposal (
  id            bigserial PRIMARY KEY,
  label         text NOT NULL,
  rationale     text,
  nearest_kc_id text REFERENCES kc(id),
  similarity    real,
  proposed_by   text NOT NULL
                CHECK (proposed_by IN ('material_gen','item_gen','user_report','author')),
  status        text NOT NULL DEFAULT 'pending'
                CHECK (status IN ('pending','approved','merged','rejected')),
  created_at    timestamptz NOT NULL DEFAULT now()
);

-- KC を統合したときの写像。response の再生時に使う
CREATE TABLE kc_merge (
  from_id   text PRIMARY KEY REFERENCES kc(id),
  to_id     text NOT NULL   REFERENCES kc(id),
  merged_at timestamptz NOT NULL DEFAULT now(),
  CHECK (from_id <> to_id)
);

-- ファクトチェック層2の正典マスタ  docs/08-ai-architecture.md §5
CREATE TABLE canon_event (
  id         text PRIMARY KEY,
  label      text NOT NULL,
  aliases    text[]   NOT NULL DEFAULT '{}',
  year_from  int      NOT NULL,
  year_to    int,
  precision  text     NOT NULL CHECK (precision IN ('exact','decade','century')),
  region_ids smallint[] NOT NULL DEFAULT '{}'
);

-- =====================================================================
-- 3. ユーザー              docs/10-legal-risk.md §5.2
-- =====================================================================

-- Supabase では id は auth.users(id) を参照する。
-- 単体検証のため本ファイルでは外部参照を張らない。
CREATE TABLE app_user (
  id                        uuid PRIMARY KEY,
  display_name              text,
  birth_date                date NOT NULL,
  -- サインアップ時に算出して固定する。CHECK に CURRENT_DATE は使えないため（STABLE 関数）
  guardian_consent_required boolean NOT NULL,
  guardian_email            text,
  guardian_consent_at       timestamptz,
  consent_version           text NOT NULL,
  consent_at                timestamptz NOT NULL,
  invited_by                uuid REFERENCES app_user(id),
  daily_generation_quota    smallint NOT NULL DEFAULT 10,   -- 1日に生成できる教材ユニット数（08 §7）
  -- ★ 出題の1日上限。ユーザー自身と管理画面の両方から変更できる（05-scheduler.md §9.1）
  max_daily_items           smallint NOT NULL DEFAULT 80 CHECK (max_daily_items BETWEEN 10 AND 300),
  created_at                timestamptz NOT NULL DEFAULT now(),
  CHECK (
    NOT guardian_consent_required
    OR (guardian_email IS NOT NULL AND guardian_consent_at IS NOT NULL)
  )
);

-- 招待制の担保  docs/10-legal-risk.md §3.2 G1/G7
CREATE TABLE invite_code (
  code       text PRIMARY KEY,
  issued_by  uuid REFERENCES app_user(id),
  used_by    uuid REFERENCES app_user(id),
  used_at    timestamptz,
  expires_at timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- 学習継続（ストリーク）  docs/11-ux.md
CREATE TABLE user_activity (
  user_id       uuid NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  activity_date date NOT NULL,
  responses     int  NOT NULL DEFAULT 0,
  sections_read int  NOT NULL DEFAULT 0,
  PRIMARY KEY (user_id, activity_date)
);

-- =====================================================================
-- 4. 教材                  docs/07-content-pipeline.md
-- =====================================================================

-- ★ v0.3: ユーザーごとに生成する。(user_id, unit_id) で1本（§3.1）
CREATE TABLE material (
  id             uuid PRIMARY KEY,
  -- NULL = 共有教材。誰の弱点にも寄せていない「初回版」であり、全利用者が読む。
  --   初回生成の時点では p_know も misconception も空なので、
  --   誰に対しても同じプロンプトから同じ教材が作られる（docs/07 §3.1 の実装上の帰結）。
  --   人数分作ると生成費だけが人数倍になり、得るものが無い。
  -- 非NULL = 個別教材。学習が進んで弱点が溜まった利用者に作り直したもの。
  user_id        uuid REFERENCES app_user(id) ON DELETE CASCADE,
  unit_id        text NOT NULL REFERENCES syllabus_unit(id),
  title          text NOT NULL,
  provider       text NOT NULL,               -- 'gemini' | 'anthropic'
  model          text NOT NULL,
  prompt_version text NOT NULL,
  source         text NOT NULL DEFAULT 'ai_generated_no_external_text',
  -- ready    : 事実確認を通過し表示できる
  -- blocked  : 事実確認を通らなかったため配信しない（08-ai-architecture.md §5 層5）
  -- failed   : 生成自体が失敗した（モデルの拒否・タイムアウト等）
  status         text NOT NULL DEFAULT 'generating'
                 CHECK (status IN ('generating','ready','blocked','superseded','failed')),
  blocked_reason text,                        -- 検出された誤りの要約（作者が見る）
  judge_scores   jsonb,                       -- 開発時のベンチマークでのみ使う（§6.1）
  supersedes_id  uuid REFERENCES material(id),
  human_edit_log jsonb NOT NULL DEFAULT '[]'::jsonb,
  input_tokens   int,
  output_tokens  int,
  generated_at   timestamptz NOT NULL DEFAULT now()
);
-- 1ユーザー・1単元につき、表示できる教材はちょうど1本。
-- ★ 索引を2本に分ける。PostgreSQL の一意索引は NULL を互いに異なる値として扱うため、
--   (user_id, unit_id) の1本だけでは共有教材（user_id IS NULL）が同じ単元に
--   何本でも作れてしまう。
CREATE UNIQUE INDEX material_one_ready_per_user_unit
  ON material (user_id, unit_id) WHERE status = 'ready' AND user_id IS NOT NULL;
CREATE UNIQUE INDEX material_one_shared_ready_per_unit
  ON material (unit_id) WHERE status = 'ready' AND user_id IS NULL;
CREATE INDEX ON material (user_id, unit_id);
CREATE INDEX ON material (unit_id) WHERE user_id IS NULL;

CREATE TABLE material_section (
  id          uuid PRIMARY KEY,
  material_id uuid NOT NULL REFERENCES material(id) ON DELETE CASCADE,
  ord         smallint NOT NULL CHECK (ord BETWEEN 1 AND 7),
  heading     text NOT NULL,
  body_md     text NOT NULL,
  char_count  int  NOT NULL,
  hidden        boolean NOT NULL DEFAULT false,  -- 誤り報告 or ファクトチェックで非表示
  hidden_reason text CHECK (hidden_reason IN ('user_report','factcheck_flag','moderation')),
  UNIQUE (material_id, ord)
);

CREATE TABLE material_section_kc (
  section_id uuid NOT NULL REFERENCES material_section(id) ON DELETE CASCADE,
  kc_id      text NOT NULL REFERENCES kc(id),
  PRIMARY KEY (section_id, kc_id)
);
CREATE INDEX ON material_section_kc (kc_id);

-- 読了は弱い学習イベント  docs/04-weakness-engine.md
CREATE TABLE material_read (
  id         bigserial PRIMARY KEY,
  user_id    uuid NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  section_id uuid NOT NULL REFERENCES material_section(id) ON DELETE CASCADE,
  dwell_ms   int  NOT NULL,
  scroll_pct real,
  read_at    timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON material_read (user_id, section_id);

-- =====================================================================
-- 5. 設問 item             docs/06-assessment.md
-- =====================================================================

-- ★ v0.3: user_id IS NULL = 診断テスト用の共有プール（04-weakness-engine.md §5.2）
--          user_id 非NULL = そのユーザー用に生成された設問
CREATE TABLE item (
  id               uuid PRIMARY KEY,
  user_id          uuid REFERENCES app_user(id) ON DELETE CASCADE,
  material_id      uuid REFERENCES material(id) ON DELETE SET NULL,
  format           text NOT NULL
                   CHECK (format IN ('mcq4','cloze','tf','order','flashcard')),
  stem             text NOT NULL,
  choices          jsonb,                    -- [{key,text,why_wrong}, ...]
  answer_key       jsonb NOT NULL,
  explanation      text,
  guess_rate       real NOT NULL CHECK (guess_rate > 0 AND guess_rate < 1),
  -- Elo は診断用の共有プール（user_id IS NULL）でのみ較正される。
  -- ユーザーごとの設問は同じものが二度と出ないため溜まらない（04b §1.3）
  elo_b            real NOT NULL DEFAULT 0.0,
  elo_n            int  NOT NULL DEFAULT 0,
  -- Elo の代替となる実測難易度（04b §5.1）
  observed_correct int  NOT NULL DEFAULT 0,
  observed_total   int  NOT NULL DEFAULT 0,
  provider         text,
  generated_by     text,                     -- model 名
  prompt_version   text,
  -- ★ approved = 「出題してよい」。false のままの item は出題されない。
  --   user_id 非NULL（ユーザー生成）: ファクトチェック通過時にサーバーが自動で true にする
  --   user_id IS NULL（診断プール）  : 作者が手動レビューして true にする
  --   誰が承認したかを approved_by に必ず残す（08-ai-architecture.md §5.3）
  approved         boolean NOT NULL DEFAULT false,
  approved_by      text CHECK (approved_by IN ('factcheck','author')),
  approved_at      timestamptz,
  hidden           boolean NOT NULL DEFAULT false,
  hidden_reason    text CHECK (hidden_reason IN ('user_report','factcheck_flag','moderation')),
  CHECK (NOT approved OR (approved_by IS NOT NULL AND approved_at IS NOT NULL)),
  created_at       timestamptz NOT NULL DEFAULT now(),
  CHECK (observed_correct <= observed_total)
);
CREATE INDEX ON item (material_id);
CREATE INDEX ON item (user_id) WHERE user_id IS NOT NULL;
-- 診断テスト用の共有プールを引くための索引
CREATE INDEX item_diagnostic_pool ON item (format)
  WHERE user_id IS NULL AND approved AND NOT hidden;

-- Q行列: item と KC の多対多
CREATE TABLE item_kc (
  item_id uuid NOT NULL REFERENCES item(id) ON DELETE CASCADE,
  kc_id   text NOT NULL REFERENCES kc(id),
  weight  real NOT NULL DEFAULT 1.0 CHECK (weight > 0),
  PRIMARY KEY (item_id, kc_id)
);
CREATE INDEX ON item_kc (kc_id);

-- =====================================================================
-- 6. 集中特訓 drill        docs/05-scheduler.md
-- =====================================================================

CREATE TABLE drill (
  id         uuid PRIMARY KEY,
  user_id    uuid NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  title      text NOT NULL,
  deadline   date NOT NULL,
  mode       text NOT NULL CHECK (mode IN ('ai_material','self_study')),
  status     text NOT NULL DEFAULT 'active'
             CHECK (status IN ('active','completed','abandoned')),
  created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON drill (user_id) WHERE status = 'active';

CREATE TABLE drill_unit (
  drill_id uuid NOT NULL REFERENCES drill(id) ON DELETE CASCADE,
  unit_id  text NOT NULL REFERENCES syllabus_unit(id),
  PRIMARY KEY (drill_id, unit_id)
);

CREATE TABLE drill_kc (
  drill_id uuid NOT NULL REFERENCES drill(id) ON DELETE CASCADE,
  kc_id    text NOT NULL REFERENCES kc(id),
  PRIMARY KEY (drill_id, kc_id)
);
CREATE INDEX ON drill_kc (kc_id);

-- 遅延評価したノルマのキャッシュ  docs/05-scheduler.md §7
CREATE TABLE user_daily_plan (
  user_id     uuid NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  plan_date   date NOT NULL,
  target      int  NOT NULL,
  feasible    boolean NOT NULL,
  shortfall   int  NOT NULL DEFAULT 0,
  computed_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, plan_date)
);

-- =====================================================================
-- 7. 学習の記録            docs/04-weakness-engine.md §4
-- =====================================================================

-- ★ 唯一の真実。UPDATE / DELETE を禁止する（RLS とアプリ層の両方で）
CREATE TABLE response (
  id                 bigserial PRIMARY KEY,
  user_id            uuid NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  item_id            uuid NOT NULL REFERENCES item(id),
  session_kind       text NOT NULL
                     CHECK (session_kind IN ('diagnostic','flashcard','quiz','checktest',
                                             'video_retrieval','import')),
  drill_id           uuid REFERENCES drill(id) ON DELETE SET NULL,
  correct            boolean NOT NULL,
  chosen             jsonb,
  latency_ms         int,
  q                  smallint CHECK (q BETWEEN 0 AND 5),
  clamped            boolean NOT NULL DEFAULT false,
  weight             real NOT NULL DEFAULT 1.0 CHECK (weight > 0 AND weight <= 1),
  evidence_import_id uuid,
  answered_at        timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON response (user_id, answered_at);
CREATE INDEX ON response (user_id, item_id, answered_at DESC);

-- 導出テーブル: KC 単位のマスタリー
CREATE TABLE user_kc_state (
  user_id          uuid NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  kc_id            text NOT NULL REFERENCES kc(id),
  theta            real NOT NULL DEFAULT -0.5,
  p_know           real NOT NULL CHECK (p_know >= 0 AND p_know <= 1),
  n_obs            int  NOT NULL DEFAULT 0,
  n_eff            real NOT NULL DEFAULT 0,
  last_seen_at     timestamptz,
  first_correct_at timestamptz,
  algo_version     smallint NOT NULL DEFAULT 1,
  updated_at       timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, kc_id)
);
CREATE INDEX ON user_kc_state (user_id, p_know);

-- 導出テーブル: KC 単位のスケジュール（SM-2）  docs/04b-spaced-repetition.md §1.2
-- ★ v0.3: 設問を毎回生成するため item 単位では状態が積み上がらない。KC 単位にした。
CREATE TABLE kc_card (
  user_id        uuid NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  kc_id          text NOT NULL REFERENCES kc(id),
  n              int  NOT NULL DEFAULT 0,
  -- ★ 1.3::real と書くこと。1.3 は float4 で表現できず 1.2999999523... に丸められるため、
  --   SM-2 が下限にクリップした値（JS の 1.3）を入れると `ef >= 1.3`（numeric 比較）は必ず落ちる。
  --   ease hell に入ったカードが1枚も保存できなくなる（docs/04b §8 ケース2）。
  ef             real NOT NULL DEFAULT 2.5 CHECK (ef >= 1.3::real),
  interval_days  int  NOT NULL DEFAULT 0 CHECK (interval_days >= 0 AND interval_days <= 365),
  due_at         timestamptz NOT NULL,
  last_review_at timestamptz,
  lapses         int  NOT NULL DEFAULT 0,
  suspended      boolean NOT NULL DEFAULT false,
  sched_algo     text NOT NULL DEFAULT 'sm2',
  sched_version  smallint NOT NULL DEFAULT 1,
  PRIMARY KEY (user_id, kc_id)
);
CREATE INDEX ON kc_card (user_id, due_at) WHERE NOT suspended;

-- 導出テーブル: 反復して選ばれた誤答
CREATE TABLE misconception (
  user_id        uuid NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  kc_id          text NOT NULL REFERENCES kc(id),
  distractor_key text NOT NULL,
  hits           smallint NOT NULL DEFAULT 1,
  last_at        timestamptz NOT NULL DEFAULT now(),
  resolved_at    timestamptz,
  PRIMARY KEY (user_id, kc_id, distractor_key)
);

-- 確認テストのセッション
CREATE TABLE check_test (
  id           uuid PRIMARY KEY,
  user_id      uuid NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  drill_id     uuid NOT NULL REFERENCES drill(id) ON DELETE CASCADE,
  item_ids     uuid[] NOT NULL,
  raw_score    smallint,
  total        smallint NOT NULL,
  verdict      text CHECK (verdict IN ('pass','almost','retry')),
  progress_after real,
  started_at   timestamptz NOT NULL DEFAULT now(),
  finished_at  timestamptz
);
CREATE INDEX ON check_test (user_id, drill_id, started_at DESC);

-- =====================================================================
-- 8. 動画                  docs/09b-video.md
-- =====================================================================

CREATE TABLE channel_allowlist (
  channel_id    text PRIMARY KEY,
  channel_title text NOT NULL,
  subject_scope text NOT NULL
                CHECK (subject_scope IN ('world_history','japanese_history','both')),
  note          text,
  added_at      timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE video (
  id              text PRIMARY KEY,
  title           text NOT NULL,
  description     text,
  channel_id      text NOT NULL REFERENCES channel_allowlist(channel_id),
  duration_sec    int  NOT NULL CHECK (duration_sec > 0),
  published_at    timestamptz,
  embeddable      boolean NOT NULL,
  yt_rating       text,
  status          text NOT NULL DEFAULT 'candidate'
                  CHECK (status IN ('candidate','approved','rejected','unavailable')),
  reject_reason   text,
  approved_at     timestamptz,
  last_checked_at timestamptz,
  embedding       vector(768),
  created_at      timestamptz NOT NULL DEFAULT now(),
  -- 年齢制限・埋め込み禁止の動画は approved にできない
  CHECK (status <> 'approved' OR (embeddable AND yt_rating IS DISTINCT FROM 'ytAgeRestricted'))
);
CREATE INDEX ON video (status) WHERE status = 'approved';
CREATE INDEX ON video USING hnsw (embedding vector_cosine_ops);

CREATE TABLE video_kc (
  video_id  text NOT NULL REFERENCES video(id) ON DELETE CASCADE,
  kc_id     text NOT NULL REFERENCES kc(id),
  start_sec int  NOT NULL DEFAULT 0 CHECK (start_sec >= 0),
  end_sec   int,
  relevance real NOT NULL DEFAULT 1.0 CHECK (relevance >= 0 AND relevance <= 1),
  source    text NOT NULL DEFAULT 'embedding' CHECK (source IN ('embedding','manual')),
  PRIMARY KEY (video_id, kc_id, start_sec),
  CHECK (end_sec IS NULL OR end_sec > start_sec)
);
CREATE INDEX ON video_kc (kc_id, relevance DESC);

CREATE TABLE video_view (
  id           bigserial PRIMARY KEY,
  user_id      uuid NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  video_id     text NOT NULL REFERENCES video(id) ON DELETE CASCADE,
  watched_sec  int  NOT NULL CHECK (watched_sec >= 0),
  duration_sec int  NOT NULL,
  viewed_at    timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON video_view (user_id, viewed_at DESC);

-- =====================================================================
-- 9. 過去問（Phase2。スキーマのみ先に確定）  docs/10-legal-risk.md §3.3
-- =====================================================================

CREATE TABLE past_exam (
  id         uuid PRIMARY KEY,
  university text NOT NULL,
  faculty    text,
  year       smallint NOT NULL,
  sitting    text,
  subject    text NOT NULL,
  source_url text,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- ★ 1問を要素に分解する。1カラムに丸ごと入れると部分マスキングが不可能になる
CREATE TABLE past_exam_element (
  id            uuid PRIMARY KEY,
  exam_id       uuid NOT NULL REFERENCES past_exam(id) ON DELETE CASCADE,
  question_no   text NOT NULL,
  element_kind  text NOT NULL
                CHECK (element_kind IN ('stem','lead_text','source_material',
                                        'figure','choices','answer')),
  ord           smallint NOT NULL,
  body          text,
  rights_status text NOT NULL DEFAULT 'needs_permission'
                CHECK (rights_status IN ('self_made','public_domain','licensed',
                                         'needs_permission','withheld')),
  rights_source text,
  withheld_note text,
  created_at    timestamptz NOT NULL DEFAULT now(),
  -- 権利未処理・保留の要素は本文を保持しない
  CHECK (rights_status IN ('self_made','public_domain','licensed') OR body IS NULL)
);
CREATE INDEX ON past_exam_element (exam_id, question_no, ord);
CREATE INDEX ON past_exam_element (rights_status);

CREATE TABLE past_exam_kc (
  exam_id     uuid NOT NULL REFERENCES past_exam(id) ON DELETE CASCADE,
  question_no text NOT NULL,
  kc_id       text NOT NULL REFERENCES kc(id),
  PRIMARY KEY (exam_id, question_no, kc_id)
);

-- =====================================================================
-- 10. 画像取り込み（Phase2）  docs/04-weakness-engine.md §6
-- =====================================================================

CREATE TABLE evidence_import (
  id           uuid PRIMARY KEY,
  user_id      uuid NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  kind         text NOT NULL
               CHECK (kind IN ('score_report','marked_answer_sheet','handwritten')),
  storage_path text,                       -- 抽出後に NULL にする
  purge_after  date NOT NULL,
  vision_model text NOT NULL,
  raw_json     jsonb NOT NULL,
  status       text NOT NULL DEFAULT 'pending_review'
               CHECK (status IN ('pending_review','confirmed','rejected','expired')),
  created_at   timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE evidence_claim (
  id           bigserial PRIMARY KEY,
  import_id    uuid NOT NULL REFERENCES evidence_import(id) ON DELETE CASCADE,
  kc_id        text REFERENCES kc(id),
  facet_hint   jsonb,
  claim        text NOT NULL CHECK (claim IN ('wrong','right','low_rate')),
  chosen_key   text,
  conf         real NOT NULL CHECK (conf >= 0 AND conf <= 1),
  bbox         jsonb,
  user_verdict text CHECK (user_verdict IN ('accept','reject','edit')),
  applied_at   timestamptz
);

ALTER TABLE response
  ADD CONSTRAINT response_evidence_import_fk
  FOREIGN KEY (evidence_import_id) REFERENCES evidence_import(id) ON DELETE SET NULL;

-- =====================================================================
-- 11. 運用                 docs/08-ai-architecture.md §4, §5
-- =====================================================================

CREATE TABLE generation_job (
  id            uuid PRIMARY KEY,
  user_id       uuid REFERENCES app_user(id) ON DELETE CASCADE,
  kind          text NOT NULL
                CHECK (kind IN ('material','items_refresh','factcheck','scope_parse','judge')),
  scope_id      text NOT NULL,
  params_hash   text NOT NULL,
  status        text NOT NULL DEFAULT 'queued'
                CHECK (status IN ('queued','running','succeeded','failed','cancelled')),
  attempts      smallint NOT NULL DEFAULT 0,
  provider      text NOT NULL,
  model         text NOT NULL,
  input_tokens  int,
  output_tokens int,
  error         text,
  created_at    timestamptz NOT NULL DEFAULT now(),
  started_at    timestamptz,
  finished_at   timestamptz,
  UNIQUE (user_id, kind, scope_id, params_hash)
);
-- 無料枠の RPM を守るため、running を数えて同時実行を絞る（08-ai-architecture.md §7）
CREATE INDEX ON generation_job (status, created_at) WHERE status IN ('queued','running');

-- ---------------------------------------------------------------------
-- 支出遮断器（08-ai-architecture.md §7.1）
-- 月の支出が上限に達したら課金呼び出しを止める。作者の決定「1万円を超えたら即停止」。
-- ★ 金額に float を使わない。numeric で持つ。
-- ---------------------------------------------------------------------

-- 月ごとの1行。遮断の判定はこの1行の UPDATE で原子的に行う（§7.1 の関門クエリ）
CREATE TABLE ai_budget (
  period        date PRIMARY KEY,                    -- 月初（Asia/Tokyo）
  cap_jpy       numeric(10,2) NOT NULL DEFAULT 10000 CHECK (cap_jpy > 0),
  warn_jpy      numeric(10,2) NOT NULL DEFAULT 5000  CHECK (warn_jpy > 0),
  degrade_jpy   numeric(10,2) NOT NULL DEFAULT 8000  CHECK (degrade_jpy > 0),
  reserved_jpy  numeric(12,4) NOT NULL DEFAULT 0     CHECK (reserved_jpy >= 0),
  settled_jpy   numeric(12,4) NOT NULL DEFAULT 0     CHECK (settled_jpy  >= 0),
  halted        boolean NOT NULL DEFAULT false,
  halted_at     timestamptz,
  halted_reason text CHECK (halted_reason IN ('cap_exceeded','manual','provider_error')),
  CHECK (warn_jpy <= degrade_jpy AND degrade_jpy <= cap_jpy),
  -- 停止した理由と時刻が分からない停止を作らせない
  CHECK (NOT halted OR (halted_at IS NOT NULL AND halted_reason IS NOT NULL))
);

-- 課金呼び出しの元帳。1行 = 1呼び出し。reserved（発行前）→ settled（確定）
-- est_jpy は「上限見積り」であり actual_jpy はこれを超えない（§7.1 の前提: max_output_tokens 必須）
CREATE TABLE ai_spend (
  id            bigserial PRIMARY KEY,
  period        date NOT NULL REFERENCES ai_budget(period),
  job_id        uuid REFERENCES generation_job(id) ON DELETE SET NULL,
  provider      text NOT NULL,
  model         text NOT NULL,
  purpose       text NOT NULL
                CHECK (purpose IN ('generate','factcheck','judge','diagnostic','embed','scope_parse')),
  state         text NOT NULL DEFAULT 'reserved'
                CHECK (state IN ('reserved','settled','released')),
  est_jpy       numeric(10,4) NOT NULL CHECK (est_jpy >= 0),
  actual_jpy    numeric(10,4) CHECK (actual_jpy >= 0),
  input_tokens  int, output_tokens int,
  jpy_per_usd   numeric(6,2) NOT NULL,               -- 換算に使った為替。後から再計算できるように残す
  created_at    timestamptz NOT NULL DEFAULT now(),
  settled_at    timestamptz,
  -- 確定したのに金額が無い、という行を作らせない
  CHECK (state <> 'settled' OR (actual_jpy IS NOT NULL AND settled_at IS NOT NULL)),
  -- 見積りを超える確定は設計上ありえない。起きたら見積り式のバグなので落とす
  CHECK (actual_jpy IS NULL OR actual_jpy <= est_jpy)
);
CREATE INDEX ON ai_spend (period, state);
-- 予約したまま確定していない行の回収（プロセス異常終了で予約が漏れる。§7.1 の回収ジョブ）
CREATE INDEX ai_spend_stale_reservation ON ai_spend (created_at) WHERE state = 'reserved';

-- 管理画面から変更できるアプリ全体の設定（12-nonfunctional.md §7.1）
-- ★ ここに置いてよいのは「変更しても過去のデータと矛盾しない値」だけ。
--   guess / slip / mastery 閾値などの推定パラメータは置かない（04-weakness-engine.md §9）
CREATE TABLE app_setting (
  key         text PRIMARY KEY,
  value       jsonb NOT NULL,
  description text NOT NULL,
  updated_by  uuid REFERENCES app_user(id),
  updated_at  timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE content_report (
  id          bigserial PRIMARY KEY,
  user_id     uuid NOT NULL REFERENCES app_user(id) ON DELETE CASCADE,
  target_kind text NOT NULL CHECK (target_kind IN ('material_section','item')),
  target_id   uuid NOT NULL,
  comment     text,
  status      text NOT NULL DEFAULT 'open'
              CHECK (status IN ('open','confirmed','dismissed','fixed')),
  created_at  timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ON content_report (status) WHERE status = 'open';

-- =====================================================================
-- 12. ビュー
-- =====================================================================

-- 弱点の根拠を引く（説明可能性）  docs/04-weakness-engine.md §4.3
--
-- ★ security_invoker を明示する。既定に頼ってはいけない。
--   PostgreSQL 15 以降もビューの既定は「定義者（所有者）の権限で実行」である。
--   このビューは response を読むが、既定のままだと所有者 postgres の権限で
--   評価されるため response の RLS が素通りする。つまり anon キーで
--   /rest/v1/v_weakness_evidence を1回叩くだけで、
--   全利用者の解答履歴（誰が・どの KC を・何と答えて・正誤）が読めてしまう。
--   Supabase のリンタが ERROR で挙げる security_definer_view はこれである。
--   security_invoker = true にすると、問い合わせた本人の権限と RLS で評価される。
CREATE VIEW v_weakness_evidence WITH (security_invoker = true) AS
SELECT r.user_id, ik.kc_id, r.answered_at, r.correct, r.chosen,
       i.stem, i.format, r.session_kind, r.latency_ms
FROM response r
JOIN item    i  ON i.id = r.item_id
JOIN item_kc ik ON ik.item_id = i.id;

-- =====================================================================
-- 13. RLS（Supabase）
--     所有者のみが自分の行を読み書きできる。
--     マスタ系（era/region/kc/video など）は全認証ユーザーが読み取り可・書き込み不可。
--
-- ★★ Supabase では素の PostgreSQL と既定が逆である。ここを間違えると穴が開く。
--
--   素の PostgreSQL … 権限は「GRANT した分だけ」。何もしなければ誰も読めない。
--   Supabase        … public スキーマに作った表は、ALTER DEFAULT PRIVILEGES に
--                     よって anon / authenticated へ自動的に ALL が付く。
--                     つまり **RLS を有効にしていない表は、公開されている anon
--                     キーだけで誰でも SELECT / INSERT / UPDATE / DELETE できる。**
--
--   2026-09-02 に本番（Supabase）で実測した結果:
--       has_table_privilege('anon', 'public.kc', 'DELETE') → true
--   RLS を有効にしていなければ、anon キー1本で kc を全消しできる状態だった。
--
--   したがって本スキーマの原則は次の2つになる。
--     (a) public の**全ての表**で RLS を有効にする。例外を作らない。
--     (b) 読ませたい表にだけ SELECT ポリシーを書いて開ける。
--   RLS を有効にしただけでポリシーを書かなければ「全行拒否」になる。
--   これは事故ではなく、既定として正しい側である。
-- =====================================================================

ALTER TABLE app_user                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE drill                    ENABLE ROW LEVEL SECURITY;
ALTER TABLE drill_kc                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE drill_unit               ENABLE ROW LEVEL SECURITY;
ALTER TABLE response                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_kc_state            ENABLE ROW LEVEL SECURITY;
ALTER TABLE kc_card                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE misconception            ENABLE ROW LEVEL SECURITY;
ALTER TABLE check_test               ENABLE ROW LEVEL SECURITY;
ALTER TABLE material_read            ENABLE ROW LEVEL SECURITY;
ALTER TABLE material                 ENABLE ROW LEVEL SECURITY;
-- ★ 本文は material_section にある。ここを保護しないと material のポリシーが素通りする
--   （他人の教材も、配信を止めた blocked の本文も読めてしまう）。
ALTER TABLE material_section         ENABLE ROW LEVEL SECURITY;
ALTER TABLE material_section_kc      ENABLE ROW LEVEL SECURITY;
ALTER TABLE item                     ENABLE ROW LEVEL SECURITY;
ALTER TABLE generation_job           ENABLE ROW LEVEL SECURITY;
ALTER TABLE video_view               ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_activity            ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_daily_plan          ENABLE ROW LEVEL SECURITY;
ALTER TABLE evidence_import          ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_report           ENABLE ROW LEVEL SECURITY;

-- ---- 運用テーブル（意図的に「全行拒否」にする。ポリシーを書かない） ----
-- ★ ここだけは下の原則の例外である。利用者に見せる必要も書かせる必要も無い。
--   ポリシーを1つも定義しないことで anon / authenticated からは一切読めなくなり、
--   service_role（サーバー側）だけが RLS を迂回して読み書きする。
--   遮断器の上限値をユーザーが読めても書けても困るので、これが正しい状態である。
--   将来この3テーブルに「ポリシーが無い」と指摘されても、追加してはならない。
--   同じ理由で item の SELECT と response の INSERT も意図的に存在しない（下記）。
ALTER TABLE app_setting              ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_budget                ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_spend                 ENABLE ROW LEVEL SECURITY;

-- ---- マスタ系（全認証ユーザーが読み取り可・書き込み不可）----
-- ★ 以前はこの9表で RLS を有効にしていなかった。「RLS を掛けなければ読める」
--   という素の PostgreSQL の感覚で書いたためだが、上に書いたとおり Supabase では
--   それは「誰でも書き換えられる」を意味する。読み取りは下の SELECT ポリシーで開ける。
ALTER TABLE era                      ENABLE ROW LEVEL SECURITY;
ALTER TABLE region                   ENABLE ROW LEVEL SECURITY;
ALTER TABLE person                   ENABLE ROW LEVEL SECURITY;
ALTER TABLE syllabus_unit            ENABLE ROW LEVEL SECURITY;
ALTER TABLE kc                       ENABLE ROW LEVEL SECURITY;
ALTER TABLE kc_region                ENABLE ROW LEVEL SECURITY;
ALTER TABLE kc_syllabus_unit         ENABLE ROW LEVEL SECURITY;
ALTER TABLE canon_event              ENABLE ROW LEVEL SECURITY;
ALTER TABLE video                    ENABLE ROW LEVEL SECURITY;
ALTER TABLE video_kc                 ENABLE ROW LEVEL SECURITY;

-- ---- 残りも全て「全行拒否」にする（ポリシーを書かない）----
-- ★ ここも以前は RLS 無効だった。invite_code と past_exam は特に危ない。
--   invite_code … 未使用の招待コードが読めると、招待制（上限10名）が意味を失う。
--   past_exam   … 過去問の本文を格納している（docs/10 §2・作者がリスクを承知の上で採用）。
--                 「非公開・招待制」が前提の判断なので、anon から読めてはならない。
--   item_kc     … item に SELECT を許さない方針（下記）と揃える。
ALTER TABLE invite_code              ENABLE ROW LEVEL SECURITY;
ALTER TABLE kc_proposal              ENABLE ROW LEVEL SECURITY;
ALTER TABLE kc_merge                 ENABLE ROW LEVEL SECURITY;
ALTER TABLE item_kc                  ENABLE ROW LEVEL SECURITY;
ALTER TABLE channel_allowlist        ENABLE ROW LEVEL SECURITY;
ALTER TABLE past_exam                ENABLE ROW LEVEL SECURITY;
ALTER TABLE past_exam_element        ENABLE ROW LEVEL SECURITY;
ALTER TABLE past_exam_kc             ENABLE ROW LEVEL SECURITY;
ALTER TABLE evidence_claim           ENABLE ROW LEVEL SECURITY;

-- ★ RLS を有効にしたテーブルには必ずポリシーを書く（直上の運用3テーブルを除く）。
--   ポリシーが1つも無いテーブルは「全行アクセス拒否」になり、アプリが一切動かない。
--
-- 方針:
--   SELECT  … 自分の行のみ（診断用の共有 item は全員が読める）
--   INSERT  … ユーザーが自分で作るもの（応答・読了・視聴・特訓・誤り報告）のみ
--   UPDATE / DELETE … 特訓の編集と削除のみ
--   導出テーブル（user_kc_state / kc_card / misconception / user_activity /
--   user_daily_plan / check_test）は SELECT のみ。書き込みはサーバー側
--   （service_role）が行う。これが「response が唯一の真実」（03-data-model.md §2.2）
--   をDB層で強制する。

-- ★ 全てのポリシーに TO authenticated を付ける。既定の PUBLIC にしない。
--   PUBLIC のままだと anon（未ログイン）にもポリシーが適用され、
--   条件に当てはまる行は読めてしまう。実際 material_select の
--   「OR user_id IS NULL」（共有教材）は anon にも当たるため、
--   公開されている anon キー1本で共有教材の本文が全部読めていた。
--   HISTORIA は招待制（上限10名・docs/10）である。未ログインには何も見せない。

-- ---- 自分のアカウント（SELECT のみ。設定変更は Server Action 経由） ----
-- 列単位の制限は RLS では書けないため、max_daily_items の変更などは
-- service_role で動く Server Action に閉じる（guardian_consent_at 等を書き換えさせない）
CREATE POLICY app_user_select ON app_user
  FOR SELECT TO authenticated USING (id = (SELECT auth.uid()));

-- ---- 追記専用ログ（UPDATE / DELETE のポリシーを作らない） ----
CREATE POLICY response_select ON response
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));
-- ★ INSERT のポリシーを作らない（12-nonfunctional.md §6.1）。
--   correct はサーバーが答え合わせをして決める値であり、利用者が申告する値ではない。
--   クライアントに INSERT を許すと DevTools から correct=true を直接書けてしまい、
--   「response が唯一の真実」（03-data-model.md §2.2）の入力源が改竄可能になる。
--   書き込みは採点を行う Server Action（service_role）に閉じる。

-- ---- ユーザーが作って編集できるもの ----
CREATE POLICY drill_all ON drill
  FOR ALL TO authenticated USING (user_id = (SELECT auth.uid()))
  WITH CHECK (user_id = (SELECT auth.uid()));

-- drill_kc / drill_unit は user_id を持たないので drill 経由で判定する
CREATE POLICY drill_kc_all ON drill_kc
  FOR ALL TO authenticated USING (EXISTS (SELECT 1 FROM drill d
                         WHERE d.id = drill_kc.drill_id AND d.user_id = (SELECT auth.uid())))
  WITH CHECK (EXISTS (SELECT 1 FROM drill d
                      WHERE d.id = drill_kc.drill_id AND d.user_id = (SELECT auth.uid())));
CREATE POLICY drill_unit_all ON drill_unit
  FOR ALL TO authenticated USING (EXISTS (SELECT 1 FROM drill d
                         WHERE d.id = drill_unit.drill_id AND d.user_id = (SELECT auth.uid())))
  WITH CHECK (EXISTS (SELECT 1 FROM drill d
                      WHERE d.id = drill_unit.drill_id AND d.user_id = (SELECT auth.uid())));

-- ---- ユーザーが追加できる記録（更新・削除はしない） ----
CREATE POLICY material_read_select ON material_read
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));
CREATE POLICY material_read_insert ON material_read
  FOR INSERT TO authenticated WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY video_view_select ON video_view
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));
CREATE POLICY video_view_insert ON video_view
  FOR INSERT TO authenticated WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY content_report_select ON content_report
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));
CREATE POLICY content_report_insert ON content_report
  FOR INSERT TO authenticated WITH CHECK (user_id = (SELECT auth.uid()));

CREATE POLICY evidence_import_select ON evidence_import
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));
CREATE POLICY evidence_import_insert ON evidence_import
  FOR INSERT TO authenticated WITH CHECK (user_id = (SELECT auth.uid()));

-- ---- 導出テーブル（SELECT のみ。書き込みは service_role） ----
CREATE POLICY user_kc_state_select ON user_kc_state
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));
CREATE POLICY kc_card_select ON kc_card
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));
CREATE POLICY misconception_select ON misconception
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));
CREATE POLICY user_activity_select ON user_activity
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));
CREATE POLICY user_daily_plan_select ON user_daily_plan
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));
CREATE POLICY check_test_select ON check_test
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));

-- ---- 生成物（読むだけ。作るのはサーバー側） ----
-- material と item は「自分のもの」＋「診断用の共有プール（item.user_id IS NULL）」を読める
CREATE POLICY material_select ON material
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()) OR user_id IS NULL);
-- ★ item に SELECT ポリシーを作らない（12-nonfunctional.md §6.1）。
--   RLS は列単位の制限ができないため、SELECT を許すと answer_key・explanation・
--   choices[].why_wrong まで解答前に読めてしまう。出題は Server Action が
--   stem と choices の key/text だけを返し、正答は採点の応答で初めて返す。
-- 本文は「読める教材の、配信できる版」に限る。
-- blocked / failed の本文は誰にも見せない（作者判断 Q4・docs/08 §5 層5）。
CREATE POLICY material_section_select ON material_section
  FOR SELECT TO authenticated USING (EXISTS (
    SELECT 1 FROM material m
     WHERE m.id = material_section.material_id
       AND m.status = 'ready'
       AND (m.user_id = (SELECT auth.uid()) OR m.user_id IS NULL)));
CREATE POLICY material_section_kc_select ON material_section_kc
  FOR SELECT TO authenticated USING (EXISTS (
    SELECT 1 FROM material_section s JOIN material m ON m.id = s.material_id
     WHERE s.id = material_section_kc.section_id
       AND m.status = 'ready'
       AND (m.user_id = (SELECT auth.uid()) OR m.user_id IS NULL)));

CREATE POLICY generation_job_select ON generation_job
  FOR SELECT TO authenticated USING (user_id = (SELECT auth.uid()));

-- ---- マスタ系を読み取りだけ開ける ----
-- ★ USING (true) は「RLS を無効にする」と同じではない。
--   ポリシーは SELECT にしか付けないので、INSERT / UPDATE / DELETE は
--   ポリシーが無い＝拒否のままである。これで §13 冒頭に書いた
--   「全認証ユーザーが読み取り可・書き込み不可」が初めて本当になる。
--   なお anon（未ログイン）にも開くかは to authenticated で分けている。
--   招待制（上限10名・docs/10）なので、未ログインには何も見せない。
CREATE POLICY era_select               ON era               FOR SELECT TO authenticated USING (true);
CREATE POLICY region_select            ON region            FOR SELECT TO authenticated USING (true);
CREATE POLICY person_select            ON person            FOR SELECT TO authenticated USING (true);
CREATE POLICY syllabus_unit_select     ON syllabus_unit     FOR SELECT TO authenticated USING (true);
CREATE POLICY kc_select                ON kc                FOR SELECT TO authenticated USING (true);
CREATE POLICY kc_region_select         ON kc_region         FOR SELECT TO authenticated USING (true);
CREATE POLICY kc_syllabus_unit_select  ON kc_syllabus_unit  FOR SELECT TO authenticated USING (true);
CREATE POLICY canon_event_select       ON canon_event       FOR SELECT TO authenticated USING (true);
CREATE POLICY video_select             ON video             FOR SELECT TO authenticated USING (true);
CREATE POLICY video_kc_select          ON video_kc          FOR SELECT TO authenticated USING (true);

-- ---- 取り込んだ根拠（親の evidence_import が自分のものなら読める）----
-- evidence_claim は user_id を持たないので親を辿る。evidence_import の
-- SELECT ポリシーと同じ範囲になり、他人の模試の読み取りは拒まれる。
CREATE POLICY evidence_claim_select ON evidence_claim
  FOR SELECT TO authenticated USING (EXISTS (
    SELECT 1 FROM evidence_import i
     WHERE i.id = evidence_claim.import_id AND i.user_id = (SELECT auth.uid())));
