-- seed/*.csv を DB に投入する。docs/schema.sql を流したあとに実行する。
--   psql -f docs/schema.sql -f seed/load.sql
--
-- Phase 1 では scripts/seed/01_masters.ts / 02_kc.ts が同じことを冪等に行う
-- （docs/09-content-sourcing.md §7）。この SQL は仕様の検証と初期投入のためのもの。
-- ★ approve 列が '○' の行だけを kc に入れる（docs/02-domain-model.md §5 の作者承認制）。

\set ON_ERROR_STOP on
BEGIN;

CREATE TEMP TABLE s_era      (id smallint, label text, start_year int, end_year int, ord smallint);
CREATE TEMP TABLE s_region   (id smallint, label text, parent_label text, grid_id smallint, ord smallint);
CREATE TEMP TABLE s_syllabus (id text, subject text, parent_id text, level smallint, label text, ord smallint);
CREATE TEMP TABLE s_kc (
  approve text, id text, label text, kind text, unit_id text, era_id smallint,
  region_primary text, region_others text, year_from int, year_to int,
  year_precision text, exam_weight real, prereq_ids text, why_confusable text, note text
);

\copy s_era      FROM 'seed/era.csv'           WITH (FORMAT csv, HEADER true)
\copy s_region   FROM 'seed/region.csv'        WITH (FORMAT csv, HEADER true)
\copy s_syllabus FROM 'seed/syllabus_unit.csv' WITH (FORMAT csv, HEADER true)
\copy s_kc       FROM 'seed/kc.csv'            WITH (FORMAT csv, HEADER true)

INSERT INTO era SELECT id, label, start_year, end_year, ord FROM s_era;

-- 親を先に入れる必要があるので、親を持たない行から順に入れる
INSERT INTO region (id, label, parent_id, grid_id, ord)
SELECT s.id, s.label, p.id, s.grid_id, s.ord
  FROM s_region s LEFT JOIN s_region p ON p.label = s.parent_label
 ORDER BY (coalesce(s.parent_label, '') <> ''), s.id;

INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord)
SELECT id, subject, nullif(coalesce(parent_id, ''), ''), level, label, ord
  FROM s_syllabus ORDER BY level, id;

INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight)
SELECT id, label, kind, era_id,
       year_from, year_to, nullif(year_precision, ''),
       CASE WHEN coalesce(prereq_ids, '') = '' THEN '{}'::text[]
            ELSE string_to_array(prereq_ids, ';') END,
       exam_weight
  FROM s_kc WHERE approve = '○';

INSERT INTO kc_syllabus_unit (kc_id, unit_id)
SELECT id, unit_id FROM s_kc WHERE approve = '○';

INSERT INTO kc_region (kc_id, region_id, is_primary)
SELECT k.id, r.id, true FROM s_kc k JOIN region r ON r.label = k.region_primary WHERE k.approve = '○';

INSERT INTO kc_region (kc_id, region_id, is_primary)
SELECT k.id, r.id, false
  FROM s_kc k
  CROSS JOIN LATERAL unnest(string_to_array(coalesce(k.region_others, ''), ';')) AS o(label)
  JOIN region r ON r.label = trim(o.label)
 WHERE k.approve = '○' AND coalesce(k.region_others, '') <> '';

COMMIT;

-- 投入結果
SELECT 'era'               AS t, count(*) FROM era
UNION ALL SELECT 'region',            count(*) FROM region
UNION ALL SELECT 'syllabus_unit',     count(*) FROM syllabus_unit
UNION ALL SELECT 'kc',                count(*) FROM kc
UNION ALL SELECT 'kc_region',         count(*) FROM kc_region
UNION ALL SELECT 'kc_syllabus_unit',  count(*) FROM kc_syllabus_unit;
