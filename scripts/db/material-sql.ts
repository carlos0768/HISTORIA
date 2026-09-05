/**
 * 手で書いた教材（seed/material/*.json）を投入する SQL を書き出す
 *
 *   npx tsx scripts/db/material-sql.ts --user <uuid> > /tmp/load.sql
 *   npx tsx scripts/db/material-sql.ts --user <uuid> wh.4.1.3 wh.4.4.1
 *
 * ★ **`generateMaterial` を通さない経路である。だから何を書くかが重要になる。**
 *   あちらは「生成 → 層2 → 層3 → 配信可否」の全部をやる。ここは
 *   「用意された中身を入れる」だけで、`seedItem` と同じ立場にある。
 *
 * ★ **来歴に嘘を書かない。** 層3（別系統モデルによる二次照合）を通していない以上、
 *   `item.approved_by` に `'factcheck'` と書くことはできない。**`'author'` と書く。**
 *   作者が読んで配信を決めた、という事実はそのとおりだからである（docs/02 §5）。
 *   `human_edit_log` に「層3を通していない」を明記し、後から数えられるようにする。
 *
 * ★ `provider = 'authored'` / `model = 'claude-code'`。API で作ったことにしない
 *   （docs/10 §8）。`fake:` で始まらないので FakeWarning は出ない — 出すべきでもない。
 *   これはフェイクではなく、人（と道具）が書いた本物である。
 *
 * ★ 壊さない。DELETE も DROP も書かない。同じ単元に既に配信中の教材があれば
 *   `superseded` にして入れ替える（一意索引 material_one_shared_ready_per_unit）。
 */
import { readdirSync, readFileSync } from 'node:fs'
import { join } from 'node:path'
import { randomUUID, createHash } from 'node:crypto'
import { parseMaterialOutput } from '@/lib/ai/schema'
import { AUTHORED_DIR } from '@/lib/ai/authored'
import { MATERIAL_PROMPT_VERSION } from '@/lib/ai/prompt'
import { GUESS } from '@/lib/domain/params'

const argv = process.argv.slice(2)
const at = argv.indexOf('--user')
const userId = at >= 0 ? argv[at + 1] : null
if (!userId) {
  console.error('--user <uuid> が要ります（設問の紐づけ先）')
  process.exit(1)
}
const only = argv.filter((a, i) => !a.startsWith('--') && i !== at + 1)

const PROVIDER = 'authored'
const MODEL = 'claude-code'

/** 文字列リテラル。単引用符を倍にする（Postgres の標準） */
const lit = (s: string) => `'${s.replaceAll("'", "''")}'`
const jsonLit = (v: unknown) => `${lit(JSON.stringify(v))}::jsonb`

const files = readdirSync(AUTHORED_DIR).filter(f => f.endsWith('.json'))
  .map(f => f.replace(/\.json$/, ''))
  .filter(u => only.length === 0 || only.includes(u)).sort()

const say = (s = '') => process.stdout.write(s + '\n')

say('-- 手で書いた教材の投入（scripts/db/material-sql.ts が生成）')
say('-- ★ 層3（別系統モデルによる二次照合）は通していない。')
say("--   だから item.approved_by は 'author' であって 'factcheck' ではない。")
say('BEGIN;')

let materials = 0, sections = 0, items = 0
for (const unitId of files) {
  const text = readFileSync(join(AUTHORED_DIR, `${unitId}.json`), 'utf8')
  const sha = createHash('sha256').update(text).digest('hex').slice(0, 12)
  const parsed = parseMaterialOutput(JSON.parse(text))
  if (!parsed.success) {
    console.error(`${unitId}: スキーマに反しています。check-material.ts を先に通してください`)
    process.exit(1)
  }
  const m = parsed.data
  const materialId = randomUUID()
  const chars = m.sections.reduce((n, s) => n + s.body_md.length, 0)

  // ★ 来歴。now() を SQL 側で入れたいので jsonb_build_object で組む
  const NOTE = '層3（別系統モデルによる二次照合）を実施していない。作者の判断で配信する'
  const editLog =
    `jsonb_build_array(jsonb_build_object(` +
    `'at', now()::text, 'by', 'author', 'action', 'seed_authored_material', ` +
    `'note', ${lit(NOTE)}, 'source', 'seed/material', ` +
    `'sha256_12', ${lit(sha)}, 'chars', ${chars}))`

  say('')
  say(`-- ${unitId}  ${m.title}  ${chars}字`)
  // 同じ単元の共有教材で配信中のものを退ける（一意索引に触れないため）
  say(`UPDATE material SET status = 'superseded'`)
  say(`  WHERE unit_id = ${lit(unitId)} AND status = 'ready' AND user_id IS NULL;`)
  say(`INSERT INTO material (id, user_id, unit_id, title, provider, model, prompt_version,`)
  say(`                      status, input_tokens, output_tokens, generated_at, human_edit_log)`)
  say(`  VALUES (${lit(materialId)}, NULL, ${lit(unitId)}, ${lit(m.title)}, ${lit(PROVIDER)},`)
  say(`          ${lit(MODEL)}, ${lit(MATERIAL_PROMPT_VERSION)}, 'ready', 0, 0, now(),`)
  say(`          ${editLog});`)
  materials++

  for (const s of m.sections) {
    const sectionId = randomUUID()
    say(`INSERT INTO material_section (id, material_id, ord, heading, body_md, char_count)`)
    say(`  VALUES (${lit(sectionId)}, ${lit(materialId)}, ${s.ord}, ${lit(s.heading)},`)
    say(`          ${lit(s.body_md)}, ${s.body_md.length});`)
    for (const kcId of s.kc_ids) {
      say(`INSERT INTO material_section_kc (section_id, kc_id) VALUES (${lit(sectionId)}, ${lit(kcId)})`)
      say(`  ON CONFLICT DO NOTHING;`)
    }
    sections++
  }

  const item = (id: string, format: string, stem: string, choices: string, answer: string,
                explanation: string, guess: number, kcIds: string[]) => {
    say(`INSERT INTO item (id, user_id, material_id, format, stem, choices, answer_key, explanation,`)
    say(`                  guess_rate, provider, generated_by, prompt_version,`)
    say(`                  approved, approved_by, approved_at, created_at)`)
    say(`  VALUES (${lit(id)}, ${lit(userId)}, ${lit(materialId)}, ${lit(format)}, ${lit(stem)},`)
    say(`          ${choices}, ${answer}, ${explanation}, ${guess}, ${lit(PROVIDER)}, ${lit(MODEL)},`)
    // ★ 'author'。事実確認は通っていない
    say(`          ${lit(MATERIAL_PROMPT_VERSION)}, true, 'author', now(), now());`)
    for (const kcId of kcIds) {
      say(`INSERT INTO item_kc (item_id, kc_id, weight) VALUES (${lit(id)}, ${lit(kcId)}, 1.0)`)
      say(`  ON CONFLICT DO NOTHING;`)
    }
    items++
  }

  for (const q of m.mcqs) {
    item(randomUUID(), 'mcq4', q.stem, jsonLit(q.choices), jsonLit(q.answer_key),
         lit(q.explanation), GUESS.mcq4, q.kc_ids)
  }
  for (const f of m.flashcards) {
    item(randomUUID(), 'flashcard', f.front, 'NULL', jsonLit(f.back), 'NULL',
         GUESS.flashcard, f.kc_ids)
  }
}

say('')
say('COMMIT;')
console.error(`教材 ${materials} / 節 ${sections} / 設問 ${items}`)
