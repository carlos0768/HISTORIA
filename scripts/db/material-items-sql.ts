/**
 * 配信中の教材に、**設問だけ**を入れ直す SQL を書き出す
 *
 *   npx tsx scripts/db/material-items-sql.ts --user <uuid> wh.3.6.2
 *
 * ★ なぜ本文の投入器（material-sql.ts / -compact.ts）と別に要るのか。
 *   遠隔から投入すると、**転送が途中で切れる**ことが実際に起きた。
 *   本番の wh.3.6.2 は、本文7節は正しく入っているのに設問が22問中3問で
 *   止まっていた。本文の投入器を流し直せば直るが、それは
 *   「正しく入っている本文を捨てて入れ直す」ことであり、
 *   30KB を送る賭けをもう一度することになる。設問だけなら 8KB で済む。
 *
 * ★ **何度流しても増えない。** 同じ material に同じ stem があれば入れない。
 *   切れた転送の後始末は、どこまで入ったか分からない状態から始まるので、
 *   「途中から流しても正しくなる」ことが要る。
 *
 * ★ 本文には一切触れない。material も material_section も読むだけである。
 *   規則は material-sql.ts と同じ（provider = 'authored' /
 *   approved_by = 'author'。層3を通していないため 'factcheck' ではない）。
 */
import { readFileSync } from 'node:fs'
import { join } from 'node:path'
import { parseMaterialOutput } from '@/lib/ai/schema'
import { AUTHORED_DIR } from '@/lib/ai/authored'
import { MATERIAL_PROMPT_VERSION } from '@/lib/ai/prompt'
import { GUESS } from '@/lib/domain/params'

const argv = process.argv.slice(2)
const at = argv.indexOf('--user')
const userId = at >= 0 ? argv[at + 1] : null
const units = argv.filter((a, i) => !a.startsWith('--') && i !== at + 1)
if (!userId || units.length === 0) {
  console.error('使い方: material-items-sql.ts --user <uuid> <unitId>...')
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
    mcqs: m.mcqs.map(q => ({ stem: q.stem, choices: q.choices, answer: q.answer_key,
                             expl: q.explanation, kcs: q.kc_ids })),
    cards: m.flashcards.map(f => ({ front: f.front, back: f.back, kcs: f.kc_ids })),
  }
})

const DATA = lit(JSON.stringify(payload))

process.stdout.write(`BEGIN;

-- 配信中の共有教材に、まだ無い設問だけを足す。本文には触れない
WITH input AS (SELECT ${DATA}::jsonb AS d),
src AS (SELECT e.v FROM input, jsonb_array_elements(input.d) AS e(v)),
-- ★ 相手は「いま配信中の版」だけ。退けた版に足しても画面には出ない
mat AS (
  SELECT src.v, m.id
    FROM src JOIN material m ON m.unit_id = src.v->>'unit_id'
   WHERE m.user_id IS NULL AND m.status = 'ready'),
q AS (
  INSERT INTO item (id, user_id, material_id, format, stem, choices, answer_key, explanation,
                    guess_rate, provider, generated_by, prompt_version,
                    approved, approved_by, approved_at, created_at)
  SELECT gen_random_uuid(), ${lit(userId)}, mat.id, 'mcq4', e->>'stem', e->'choices', e->'answer',
         e->>'expl', ${GUESS.mcq4}, 'authored', 'claude-code', ${lit(MATERIAL_PROMPT_VERSION)},
         true, 'author', now(), now()
    FROM mat, jsonb_array_elements(mat.v->'mcqs') AS e
   -- ★ ここが「何度流しても増えない」の要。切れた転送の後始末に要る
   WHERE NOT EXISTS (SELECT 1 FROM item i
                      WHERE i.material_id = mat.id AND i.stem = e->>'stem')
  RETURNING id, stem),
c AS (
  INSERT INTO item (id, user_id, material_id, format, stem, answer_key,
                    guess_rate, provider, generated_by, prompt_version,
                    approved, approved_by, approved_at, created_at)
  SELECT gen_random_uuid(), ${lit(userId)}, mat.id, 'flashcard', e->>'front', e->'back',
         ${GUESS.flashcard}, 'authored', 'claude-code', ${lit(MATERIAL_PROMPT_VERSION)},
         true, 'author', now(), now()
    FROM mat, jsonb_array_elements(mat.v->'cards') AS e
   WHERE NOT EXISTS (SELECT 1 FROM item i
                      WHERE i.material_id = mat.id AND i.stem = e->>'front')
  RETURNING id, stem),
-- ★ KC の結びは ON CONFLICT DO NOTHING なので、既にある設問の分も安全に埋め直せる
qkc AS (
  INSERT INTO item_kc (item_id, kc_id, weight)
  SELECT q.id, k, 1.0
    FROM mat JOIN LATERAL jsonb_array_elements(mat.v->'mcqs') AS e ON true
             JOIN q ON q.stem = e->>'stem',
         jsonb_array_elements_text(e->'kcs') AS k
  ON CONFLICT DO NOTHING RETURNING item_id),
ckc AS (
  INSERT INTO item_kc (item_id, kc_id, weight)
  SELECT c.id, k, 1.0
    FROM mat JOIN LATERAL jsonb_array_elements(mat.v->'cards') AS e ON true
             JOIN c ON c.stem = e->>'front',
         jsonb_array_elements_text(e->'kcs') AS k
  ON CONFLICT DO NOTHING RETURNING item_id)
SELECT (SELECT count(*) FROM q) AS mcqs, (SELECT count(*) FROM c) AS cards,
       (SELECT count(*) FROM qkc) + (SELECT count(*) FROM ckc) AS kc_links;

COMMIT;
`)
