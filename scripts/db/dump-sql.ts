/**
 * Supabase の SQL エディタに貼るための SQL を出す
 *
 *   npx tsx scripts/db/dump-sql.ts            # seed/out/ に書き出す
 *   npx tsx scripts/db/dump-sql.ts --stdout   # 標準出力に出す
 *
 * ★ CSV から生成する。手で書き写した SQL はすぐ古くなるためである。
 *   投入の規則（承認済みのみ・親を先に・primary は1件）は
 *   scripts/db/seed.ts と同じものをここでも守る。
 *
 * ★ スキーマ本体は docs/schema.sql をそのまま貼れる。
 *   Supabase には pgvector があり auth.uid() も実在するので、
 *   applySchema が行う置換（PGVECTOR=off）も shim も要らない。
 */
import { writeFileSync, mkdirSync } from 'node:fs'
import { join } from 'node:path'
import { readCsv, orNull, num, list } from './csv'
import { SEED_DIR } from './seed'

/** SQL の文字列リテラル。単引用符を二重にする */
const q = (v: string): string => `'${v.replaceAll("'", "''")}'`
const lit = (v: string | number | null): string =>
  v === null ? 'NULL' : typeof v === 'number' ? String(v) : q(v)
/** text[] のリテラル */
const arr = (v: string[]): string => (v.length === 0 ? `'{}'::text[]` : `ARRAY[${v.map(q).join(',')}]::text[]`)

export type SeedSql = { sql: string; counts: Record<string, number> }

/** CSV から SQL を組み立てる。試験から呼べるよう関数にしてある */
export function buildSeedSql(): SeedSql {
const out: string[] = []
const say = (s = '') => out.push(s)

say('-- HISTORIA seed（自動生成 — 手で編集しない）')
say('-- 作り直す: npx tsx scripts/db/dump-sql.ts')
say('--')
say('-- 先に docs/schema.sql を流しておくこと。')
say('-- 何度流しても結果は同じになる（ON CONFLICT で上書きする）。')
say('')
say('BEGIN;')
say('')

// ---- 時代 ----
const eras = readCsv(join(SEED_DIR, 'era.csv'))
say(`-- 時代 ${eras.length} 件`)
for (const e of eras) {
  say(`INSERT INTO era (id, label, start_year, end_year, ord) VALUES ` +
    `(${lit(num(e.id))}, ${lit(e.label!)}, ${lit(num(e.start_year))}, ${lit(num(e.end_year))}, ${lit(num(e.ord))})`)
  say(`  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, start_year = EXCLUDED.start_year,`)
  say(`    end_year = EXCLUDED.end_year, ord = EXCLUDED.ord;`)
}
say('')

// ---- 地域（親を先に入れる）----
const regions = readCsv(join(SEED_DIR, 'region.csv'))
const regionByLabel = new Map(regions.map(r => [r.label!, r]))
const orderedRegions = [...regions].sort(
  (a, b) => Number(!!orNull(a.parent_label)) - Number(!!orNull(b.parent_label)),
)
say(`-- 地域 ${regions.length} 件（親を先に入れる）`)
for (const r of orderedRegions) {
  const parent = orNull(r.parent_label)
  const parentId = parent ? num(regionByLabel.get(parent)?.id) : null
  if (parent && parentId === null) throw new Error(`region.csv: 親 "${parent}" が見つかりません（${r.label}）`)
  say(`INSERT INTO region (id, label, parent_id, grid_id, ord) VALUES ` +
    `(${lit(num(r.id))}, ${lit(r.label!)}, ${lit(parentId)}, ${lit(num(r.grid_id))}, ${lit(num(r.ord))})`)
  say(`  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, parent_id = EXCLUDED.parent_id,`)
  say(`    grid_id = EXCLUDED.grid_id, ord = EXCLUDED.ord;`)
}
say('')

// ---- 章立て（level 順。parent_id が自己参照なので浅い方から）----
const units = readCsv(join(SEED_DIR, 'syllabus_unit.csv'))
say(`-- 章立て ${units.length} 件（level の浅い方から。parent_id が自己参照のため）`)
for (const u of [...units].sort((a, b) => Number(a.level) - Number(b.level))) {
  say(`INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord) VALUES ` +
    `(${lit(u.id!)}, ${lit(u.subject!)}, ${lit(orNull(u.parent_id))}, ${lit(num(u.level))}, ${lit(u.label!)}, ${lit(num(u.ord))})`)
  say(`  ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,`)
  say(`    level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord;`)
}
say('')

// ---- KC（承認済みのみ）----
const kcRows = readCsv(join(SEED_DIR, 'kc.csv'))
const approved = kcRows.filter(k => k.approve === '○')
const skipped = kcRows.length - approved.length
const regionId = new Map(regions.map(r => [r.label!, Number(r.id)]))

say(`-- KC ${approved.length} 件（承認済みのみ。未承認 ${skipped} 件は含めない）`)
say(`-- 作者承認制については docs/02 §5 を参照`)
for (const k of approved) {
  say(`INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight) VALUES`)
  say(`  (${lit(k.id!)}, ${lit(k.label!)}, ${lit(k.kind!)}, ${lit(num(k.era_id))}, ${lit(num(k.year_from))},`)
  say(`   ${lit(num(k.year_to))}, ${lit(orNull(k.year_precision))}, ${arr(list(k.prereq_ids))}, ${lit(num(k.exam_weight) ?? 1)})`)
  say(`  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,`)
  say(`    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,`)
  say(`    prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight;`)
}
say('')

say('-- KC と節の対応')
for (const k of approved) {
  say(`INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES (${lit(k.id!)}, ${lit(k.unit_id!)}) ON CONFLICT DO NOTHING;`)
}
say('')

say('-- KC と地域の対応（primary は1件だけ。kc_region_one_primary が保証する）')
let kcRegionCount = 0
for (const k of approved) {
  const primary = regionId.get(k.region_primary!)
  if (primary === undefined) {
    throw new Error(`kc.csv: region_primary "${k.region_primary}" が region.csv にありません（${k.id}）`)
  }
  say(`INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES (${lit(k.id!)}, ${primary}, true)`)
  say(`  ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true;`)
  kcRegionCount++
  for (const label of list(k.region_others)) {
    const rid = regionId.get(label)
    if (rid === undefined) {
      throw new Error(`kc.csv: region_others "${label}" が region.csv にありません（${k.id}）`)
    }
    say(`INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES (${lit(k.id!)}, ${rid}, false) ON CONFLICT DO NOTHING;`)
    kcRegionCount++
  }
}
say('')

say('COMMIT;')
say('')
say('-- 確認用')
say(`-- SELECT (SELECT count(*) FROM era) AS era, (SELECT count(*) FROM region) AS region,`)
say(`--        (SELECT count(*) FROM syllabus_unit) AS unit, (SELECT count(*) FROM kc) AS kc,`)
say(`--        (SELECT count(*) FROM kc_region) AS kc_region;`)
say(`-- 期待値: era=${eras.length} region=${regions.length} unit=${units.length} kc=${approved.length} kc_region=${kcRegionCount}`)

return {
  sql: out.join('\n') + '\n',
  counts: {
    era: eras.length, region: regions.length, syllabusUnit: units.length,
    kc: approved.length, kcRegion: kcRegionCount, skipped,
  },
}
}

/** 書き出し先。リポジトリに入れて、実行しなくても GitHub から取れるようにする */
export const SEED_SQL_PATH = join(SEED_DIR, 'sql', '02_seed.sql')

if (process.argv[1]?.endsWith('dump-sql.ts')) {
  const { sql, counts } = buildSeedSql()
  if (process.argv.includes('--stdout')) {
    process.stdout.write(sql)
  } else {
    mkdirSync(join(SEED_DIR, 'sql'), { recursive: true })
    writeFileSync(SEED_SQL_PATH, sql)
    console.log(`seed/sql/02_seed.sql に書き出した（${(sql.length / 1024).toFixed(0)}KB）`)
    console.log(`  時代 ${counts.era} / 地域 ${counts.region} / 章立て ${counts.syllabusUnit} / ` +
      `KC ${counts.kc}（除外 ${counts.skipped}）/ kc_region ${counts.kcRegion}`)
    console.log('')
    console.log('Supabase の SQL エディタに、この順で貼る:')
    console.log('  1. docs/schema.sql          （そのまま貼れる）')
    console.log('  2. seed/sql/02_seed.sql')
  }
}
