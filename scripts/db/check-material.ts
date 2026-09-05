/**
 * 手で書いた教材を、DB にも API にも触らずに検査する
 *
 *   npx tsx scripts/db/check-material.ts            # seed/material/*.json を全部
 *   npx tsx scripts/db/check-material.ts wh.4.1.3
 *
 * ★ **投入する前に落とす。** `seed-material.ts` は Gemini を呼ぶので1本あたり
 *   実費がかかる。スキーマ違反や存在しない KC は、その前にここで分かる。
 *
 * ★ **層2を CSV だけで先取りする。** `machineCheck`（lib/pipeline/factcheck.ts）は
 *   DB の canon_event と照合するが、同じ表は `seed/canon_event.csv` にある。
 *   year の claim を CSV と突き合わせれば、**鍵も DB も無しに照合率の見込みが出る**。
 *   本番の層2と完全に同じではない（別名の扱い・最長一致は DB 側の SQL が持つ）ので、
 *   ここの数字は**目安**である。確定値は seed-material.ts の出力を見ること。
 */
import { readdirSync, readFileSync } from 'node:fs'
import { join } from 'node:path'
import { parseMaterialOutput } from '@/lib/ai/schema'
import { AUTHORED_DIR } from '@/lib/ai/authored'
import { readCsv } from './csv'
import { SEED_DIR } from './seed'

const only = process.argv.slice(2).filter(a => !a.startsWith('--'))
const files = readdirSync(AUTHORED_DIR).filter(f => f.endsWith('.json'))
  .map(f => f.replace(/\.json$/, ''))
  .filter(u => only.length === 0 || only.includes(u)).sort()

const kcRows = readCsv(join(SEED_DIR, 'kc.csv'))
const kcById = new Map(kcRows.filter(k => k.approve === '○').map(k => [k.id!, k]))
const canon = readCsv(join(SEED_DIR, 'canon_event.csv')).filter(c => c.approve === '○')
const units = new Set(readCsv(join(SEED_DIR, 'syllabus_unit.csv')).map(u => u.id!))

/** docs/07 §5.3 の節ごとの字数（prompts/material_v2.md と同じ） */
const SECTION_RANGE: Array<[number, number]> = [
  [150, 250], [200, 350], [1600, 2200], [400, 600], [300, 500], [200, 300], [200, 300],
]
const TOTAL_RANGE: [number, number] = [3050, 4500]

let bad = 0
for (const unitId of files) {
  console.log(`\n═══ ${unitId}`)
  const problems: string[] = []
  const notes: string[] = []

  if (!units.has(unitId)) problems.push(`syllabus_unit に ${unitId} がありません`)

  const parsed = parseMaterialOutput(JSON.parse(readFileSync(join(AUTHORED_DIR, `${unitId}.json`), 'utf8')))
  if (!parsed.success) {
    console.log('  ✗ スキーマ違反')
    for (const i of parsed.error.issues.slice(0, 10)) {
      console.log(`     ${i.path.join('.')}: ${i.message}`)
    }
    bad++
    continue
  }
  const m = parsed.data

  // ---- 字数 ----
  const chars = m.sections.map(s => s.body_md.length)
  const total = chars.reduce((a, b) => a + b, 0)
  m.sections.forEach((s, i) => {
    const [lo, hi] = SECTION_RANGE[i]!
    if (s.body_md.length < lo || s.body_md.length > hi) {
      problems.push(`§${s.ord} が ${s.body_md.length}字（${lo}〜${hi}）`)
    }
  })
  if (total < TOTAL_RANGE[0] || total > TOTAL_RANGE[1]) {
    problems.push(`合計 ${total}字（${TOTAL_RANGE[0]}〜${TOTAL_RANGE[1]}）`)
  }

  // ---- KC が実在し、その単元のものか ----
  const used = new Set([
    ...m.sections.flatMap(s => s.kc_ids),
    ...m.flashcards.flatMap(f => f.kc_ids),
    ...m.mcqs.flatMap(q => q.kc_ids),
  ])
  for (const id of used) {
    const kc = kcById.get(id)
    if (!kc) problems.push(`KC ${id} が kc.csv にありません`)
    else if (kc.unit_id !== unitId) problems.push(`KC ${id} は ${kc.unit_id} の項目です`)
    else if (kc.retired) problems.push(`KC ${id} は範囲外です（retired）`)
  }
  const ofUnit = kcRows.filter(k => k.approve === '○' && k.unit_id === unitId && !k.retired)
  const unused = ofUnit.filter(k => !used.has(k.id!))
  if (unused.length > 0) notes.push(`使われていない KC ${unused.length}件: ${unused.map(k => k.id).join(', ')}`)

  // ---- 層2の先取り: year の claim を正典と突き合わせる ----
  const yearClaims = m.claims.filter(c => c.kind === 'year' && typeof c.year_from === 'number')
  let matched = 0
  const misses: string[] = []
  for (const c of yearClaims) {
    const needle = c.subject ?? c.text
    // 最長一致。短い label に当たって別の事件を「正しい」と判定しないため
    const hits = canon
      .filter(e => needle.includes(e.label!)
        || (e.aliases ?? '').split(';').some(a => a.trim() && needle.includes(a.trim())))
      .sort((a, b) => (b.label!.length) - (a.label!.length))
    const hit = hits[0]
    if (!hit) { misses.push(`照合先なし: ${needle}`); continue }
    const from = Number(hit.year_from)
    const to = hit.year_to === '' ? from : Number(hit.year_to)
    if (c.year_from! >= from && c.year_from! <= to) matched++
    else misses.push(`${hit.label}: 教材 ${c.year_from} / 正典 ${hit.year_from}${hit.year_to ? `〜${hit.year_to}` : ''}`)
  }
  const rate = yearClaims.length === 0 ? null : matched / yearClaims.length

  // ---- 出力 ----
  console.log(`  題       : ${m.title}（${m.title.length}字）`)
  console.log(`  本文     : ${total}字  [${chars.join(' / ')}]`)
  console.log(`  内訳     : フラッシュカード ${m.flashcards.length} / 四択 ${m.mcqs.length} / claims ${m.claims.length}`)
  const kinds = m.claims.reduce<Record<string, number>>((a, c) => ({ ...a, [c.kind]: (a[c.kind] ?? 0) + 1 }), {})
  console.log(`  claims   : ${Object.entries(kinds).map(([k, v]) => `${k} ${v}`).join(' / ')}`)
  console.log(`  年号照合 : ${rate === null ? '—' : `${(rate * 100).toFixed(0)}% (${matched}/${yearClaims.length})`}  ★ 目安。確定は seed-material.ts`)
  for (const n of notes) console.log(`  · ${n}`)
  for (const x of misses) console.log(`  ⚠ ${x}`)
  if (problems.length === 0) {
    console.log('  ✓ 契約は満たしています')
  } else {
    bad++
    for (const p of problems) console.log(`  ✗ ${p}`)
  }
}

console.log(`\n${files.length} 件中 ${bad} 件に問題があります。`)
process.exit(bad === 0 ? 0 : 1)
