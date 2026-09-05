/**
 * 手で書いた教材を「JSON を1つ渡して SQL 側で展開する」形で投入する
 *
 *   npx tsx scripts/db/material-sql-compact.ts --user <uuid> wh.4.1.3
 *
 * ★ `material-sql.ts` と入るものは同じ。違うのは**大きさ**である。
 *   1行ずつ INSERT を並べると、教材1本で 42KB になる。中身（本文・設問）は
 *   8KB しかなく、**残り8割は列名の繰り返しと UUID** である。
 *   遠隔から流すときはその差がそのまま転送量になるので、
 *   JSON を1つ渡して `jsonb_to_recordset` で開く形にすると 1/4 になる。
 *
 * ★ 中身の規則は material-sql.ts と同じ。
 *   status = 'ready' / provider = 'authored' / model = 'claude-code' /
 *   item.approved_by = 'author'（'factcheck' ではない。層3を通していないため）。
 */
import { readFileSync } from 'node:fs'
import { join } from 'node:path'
import { createHash } from 'node:crypto'
import { parseMaterialOutput } from '@/lib/ai/schema'
import { AUTHORED_DIR } from '@/lib/ai/authored'
import { MATERIAL_PROMPT_VERSION } from '@/lib/ai/prompt'
import { GUESS } from '@/lib/domain/params'

const argv = process.argv.slice(2)
const at = argv.indexOf('--user')
const userId = at >= 0 ? argv[at + 1] : null
const units = argv.filter((a, i) => !a.startsWith('--') && i !== at + 1)
if (!userId || units.length === 0) {
  console.error('使い方: material-sql-compact.ts --user <uuid> <unitId>...')
  process.exit(1)
}

const lit = (s: string) => `'${s.replaceAll("'", "''")}'`

const payload = units.map(unitId => {
  const text = readFileSync(join(AUTHORED_DIR, `${unitId}.json`), 'utf8')
  const parsed = parseMaterialOutput(JSON.parse(text))
  if (!parsed.success) {
    console.error(`${unitId}: スキーマに反しています`)
    process.exit(1)
  }
  const m = parsed.data
  return {
    unit_id: unitId,
    title: m.title,
    sha: createHash('sha256').update(text).digest('hex').slice(0, 12),
    chars: m.sections.reduce((n, s) => n + s.body_md.length, 0),
    sections: m.sections.map(s => ({ ord: s.ord, heading: s.heading, body: s.body_md, kcs: s.kc_ids })),
    mcqs: m.mcqs.map(q => ({ stem: q.stem, choices: q.choices, answer: q.answer_key,
                             expl: q.explanation, kcs: q.kc_ids })),
    cards: m.flashcards.map(f => ({ front: f.front, back: f.back, kcs: f.kc_ids })),
  }
})

const DATA = lit(JSON.stringify(payload))

/**
 * ★ **文を2つに分ける。** 同じ文の中のデータ変更 CTE は互いの結果を見ない
 *   （Postgres はすべての CTE に同じスナップショットを見せる）。UPDATE を
 *   同居させると、INSERT は退けたはずの ready をまだ見ており、一意索引
 *   `material_one_shared_ready_per_unit` で落ちる。手元で実際に踏んだ。
 */
// ★ 1文目に JSON をもう一度載せない。単元 id の一覧だけで足りる。
//   載せると転送量が倍になる（教材1本で 28KB → 53KB になった）
const UNITS = units.map(u => lit(u)).join(', ')

process.stdout.write(`-- 1. 同じ単元で配信中の共有教材を退ける
UPDATE material SET status = 'superseded'
 WHERE status = 'ready' AND user_id IS NULL AND unit_id IN (${UNITS});

-- 2. 入れる
WITH input AS (SELECT ${DATA}::jsonb AS d),
src AS (SELECT e.* FROM input, jsonb_array_elements(input.d) AS e(v)),
ins AS (
  INSERT INTO material (id, user_id, unit_id, title, provider, model, prompt_version,
                        status, input_tokens, output_tokens, generated_at, human_edit_log)
  SELECT gen_random_uuid(), NULL, v->>'unit_id', v->>'title', 'authored', 'claude-code',
         ${lit(MATERIAL_PROMPT_VERSION)}, 'ready', 0, 0, now(),
         jsonb_build_array(jsonb_build_object(
           'at', now()::text, 'by', 'author', 'action', 'seed_authored_material',
           'note', ${lit('層3（別系統モデルによる二次照合）を実施していない。作者の判断で配信する')},
           'source', 'seed/material', 'sha256_12', v->>'sha', 'chars', (v->>'chars')::int))
    FROM src
  RETURNING id, unit_id),
sec AS (
  INSERT INTO material_section (id, material_id, ord, heading, body_md, char_count)
  SELECT gen_random_uuid(), ins.id, (s->>'ord')::smallint, s->>'heading', s->>'body',
         length(s->>'body')
    FROM src JOIN ins ON ins.unit_id = src.v->>'unit_id',
         jsonb_array_elements(src.v->'sections') AS s
  RETURNING id, material_id, ord),
seckc AS (
  INSERT INTO material_section_kc (section_id, kc_id)
  SELECT sec.id, k
    FROM src JOIN ins ON ins.unit_id = src.v->>'unit_id'
             JOIN LATERAL jsonb_array_elements(src.v->'sections') AS s ON true
             JOIN sec ON sec.material_id = ins.id AND sec.ord = (s->>'ord')::smallint,
         jsonb_array_elements_text(s->'kcs') AS k
  ON CONFLICT DO NOTHING
  RETURNING section_id),
q AS (
  INSERT INTO item (id, user_id, material_id, format, stem, choices, answer_key, explanation,
                    guess_rate, provider, generated_by, prompt_version,
                    approved, approved_by, approved_at, created_at)
  SELECT gen_random_uuid(), ${lit(userId)}, ins.id, 'mcq4', m->>'stem', m->'choices', m->'answer',
         m->>'expl', ${GUESS.mcq4}, 'authored', 'claude-code', ${lit(MATERIAL_PROMPT_VERSION)},
         true, 'author', now(), now()
    FROM src JOIN ins ON ins.unit_id = src.v->>'unit_id',
         jsonb_array_elements(src.v->'mcqs') AS m
  RETURNING id, stem),
qkc AS (
  INSERT INTO item_kc (item_id, kc_id, weight)
  SELECT q.id, k, 1.0
    FROM src JOIN ins ON ins.unit_id = src.v->>'unit_id'
             JOIN LATERAL jsonb_array_elements(src.v->'mcqs') AS m ON true
             JOIN q ON q.stem = m->>'stem',
         jsonb_array_elements_text(m->'kcs') AS k
  ON CONFLICT DO NOTHING
  RETURNING item_id),
c AS (
  INSERT INTO item (id, user_id, material_id, format, stem, answer_key,
                    guess_rate, provider, generated_by, prompt_version,
                    approved, approved_by, approved_at, created_at)
  SELECT gen_random_uuid(), ${lit(userId)}, ins.id, 'flashcard', f->>'front', f->'back',
         ${GUESS.flashcard}, 'authored', 'claude-code', ${lit(MATERIAL_PROMPT_VERSION)},
         true, 'author', now(), now()
    FROM src JOIN ins ON ins.unit_id = src.v->>'unit_id',
         jsonb_array_elements(src.v->'cards') AS f
  RETURNING id, stem),
ckc AS (
  INSERT INTO item_kc (item_id, kc_id, weight)
  SELECT c.id, k, 1.0
    FROM src JOIN ins ON ins.unit_id = src.v->>'unit_id'
             JOIN LATERAL jsonb_array_elements(src.v->'cards') AS f ON true
             JOIN c ON c.stem = f->>'front',
         jsonb_array_elements_text(f->'kcs') AS k
  ON CONFLICT DO NOTHING
  RETURNING item_id)
SELECT (SELECT count(*) FROM ins) AS materials,
       (SELECT count(*) FROM sec) AS sections, (SELECT count(*) FROM q) AS mcqs,
       (SELECT count(*) FROM c) AS cards;
`)
