-- 歴史地球儀の既存DB向け差分。docs/schema.sql を投入済みの環境で1回適用する。
BEGIN;

CREATE TABLE IF NOT EXISTS atlas_source (
  id text PRIMARY KEY, url text NOT NULL CHECK (url ~ '^https?://'), title text NOT NULL,
  publisher text NOT NULL, accessed_at date NOT NULL, license text, UNIQUE (url)
);
CREATE TABLE IF NOT EXISTS atlas_event (
  id text PRIMARY KEY, canon_event_id text REFERENCES canon_event(id) ON DELETE SET NULL,
  wikidata_id text CHECK (wikidata_id IS NULL OR wikidata_id ~ '^Q[0-9]+$'),
  label text NOT NULL, aliases text[] NOT NULL DEFAULT '{}', summary text NOT NULL,
  start_year int NOT NULL CHECK (start_year <> 0 AND start_year BETWEEN -10000 AND 2100),
  start_date jsonb NOT NULL, end_year int CHECK (end_year IS NULL OR (end_year <> 0 AND end_year BETWEEN -10000 AND 2100)),
  end_date jsonb, exam_weight real NOT NULL DEFAULT 1 CHECK (exam_weight BETWEEN 0 AND 3),
  confidence text NOT NULL CHECK (confidence IN ('high','medium','low')),
  features jsonb NOT NULL CHECK (jsonb_array_length(features) > 0), evidence jsonb NOT NULL,
  tags text[] NOT NULL DEFAULT '{}', updated_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS atlas_event_year_idx ON atlas_event (start_year, end_year);
CREATE INDEX IF NOT EXISTS atlas_event_tags_idx ON atlas_event USING gin (tags);
CREATE TABLE IF NOT EXISTS atlas_event_source (
  event_id text NOT NULL REFERENCES atlas_event(id) ON DELETE CASCADE,
  source_id text NOT NULL REFERENCES atlas_source(id), claims text[] NOT NULL,
  PRIMARY KEY (event_id, source_id)
);
CREATE TABLE IF NOT EXISTS atlas_event_unit (
  event_id text NOT NULL REFERENCES atlas_event(id) ON DELETE CASCADE,
  unit_id text NOT NULL REFERENCES syllabus_unit(id), PRIMARY KEY (event_id, unit_id)
);
CREATE TABLE IF NOT EXISTS atlas_event_kc (
  event_id text NOT NULL REFERENCES atlas_event(id) ON DELETE CASCADE,
  kc_id text NOT NULL REFERENCES kc(id), PRIMARY KEY (event_id, kc_id)
);
CREATE TABLE IF NOT EXISTS atlas_story (
  id text PRIMARY KEY, title text NOT NULL, summary text NOT NULL,
  unit_id text NOT NULL REFERENCES syllabus_unit(id),
  kind text NOT NULL CHECK (kind IN ('journey','diffusion','chronology','conflict','exchange')),
  hero_year int NOT NULL CHECK (hero_year <> 0), exam_weight real NOT NULL DEFAULT 1 CHECK (exam_weight BETWEEN 0 AND 3)
);
CREATE TABLE IF NOT EXISTS atlas_story_step (
  id text PRIMARY KEY, story_id text NOT NULL REFERENCES atlas_story(id) ON DELETE CASCADE,
  event_id text NOT NULL REFERENCES atlas_event(id), ord smallint NOT NULL CHECK (ord BETWEEN 1 AND 12),
  title text NOT NULL, narration text NOT NULL,
  duration_ms int NOT NULL CHECK (duration_ms BETWEEN 1200 AND 20000), UNIQUE (story_id, ord)
);
CREATE INDEX IF NOT EXISTS atlas_story_step_event_idx ON atlas_story_step (event_id);

ALTER TABLE atlas_source ENABLE ROW LEVEL SECURITY;
ALTER TABLE atlas_event ENABLE ROW LEVEL SECURITY;
ALTER TABLE atlas_event_source ENABLE ROW LEVEL SECURITY;
ALTER TABLE atlas_event_unit ENABLE ROW LEVEL SECURITY;
ALTER TABLE atlas_event_kc ENABLE ROW LEVEL SECURITY;
ALTER TABLE atlas_story ENABLE ROW LEVEL SECURITY;
ALTER TABLE atlas_story_step ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS atlas_source_select ON atlas_source;
CREATE POLICY atlas_source_select ON atlas_source FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS atlas_event_select ON atlas_event;
CREATE POLICY atlas_event_select ON atlas_event FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS atlas_event_source_select ON atlas_event_source;
CREATE POLICY atlas_event_source_select ON atlas_event_source FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS atlas_event_unit_select ON atlas_event_unit;
CREATE POLICY atlas_event_unit_select ON atlas_event_unit FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS atlas_event_kc_select ON atlas_event_kc;
CREATE POLICY atlas_event_kc_select ON atlas_event_kc FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS atlas_story_select ON atlas_story;
CREATE POLICY atlas_story_select ON atlas_story FOR SELECT TO authenticated USING (true);
DROP POLICY IF EXISTS atlas_story_step_select ON atlas_story_step;
CREATE POLICY atlas_story_step_select ON atlas_story_step FOR SELECT TO authenticated USING (true);

GRANT SELECT ON atlas_source, atlas_event, atlas_event_source, atlas_event_unit,
  atlas_event_kc, atlas_story, atlas_story_step TO authenticated;

COMMIT;
