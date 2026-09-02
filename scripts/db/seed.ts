/**
 * seed/*.csv をデータベースに投入する
 *
 * 仕様: docs/09-content-sourcing.md §7（01_masters / 02_kc）
 *
 * ★ すべて冪等にする。途中で失敗しても再実行すれば未完了分だけが入る。
 * ★ kc は approve = '○' の行だけを入れる（docs/02 §5 の作者承認制）。
 */
import { join, dirname } from 'node:path'
import { fileURLToPath } from 'node:url'
import type { Sql } from 'postgres'
import { readCsv, orNull, num, list } from './csv'

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..', '..')
export const SEED_DIR = join(ROOT, 'seed')

export type SeedCounts = {
  era: number; region: number; syllabusUnit: number
  kc: number; kcRegion: number; kcSyllabusUnit: number
  canonEvent: number; person: number
  /** ★ KC の未承認件数。canon_event / person とは分けて数える。
   *   1つにまとめると「どの CSV の承認が遅れているか」が分からなくなる */
  skippedUnapproved: number
  skippedCanonEvent: number
  skippedPerson: number
}

export async function seedMasters(db: Sql, dir = SEED_DIR): Promise<Pick<SeedCounts, 'era' | 'region' | 'syllabusUnit'>> {
  const eras = readCsv(join(dir, 'era.csv'))
  for (const e of eras) {
    await db`
      INSERT INTO era (id, label, start_year, end_year, ord)
      VALUES (${num(e.id)}, ${e.label!}, ${num(e.start_year)}, ${num(e.end_year)}, ${num(e.ord)})
      ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, start_year = EXCLUDED.start_year,
        end_year = EXCLUDED.end_year, ord = EXCLUDED.ord`
  }

  // 親を先に入れる必要があるので、親を持たない行から順に入れる
  const regions = readCsv(join(dir, 'region.csv'))
  const byLabel = new Map(regions.map(r => [r.label!, r]))
  const ordered = [...regions].sort((a, b) => Number(!!orNull(a.parent_label)) - Number(!!orNull(b.parent_label)))
  for (const r of ordered) {
    const parent = orNull(r.parent_label)
    const parentId = parent ? num(byLabel.get(parent)?.id) : null
    if (parent && parentId === null) throw new Error(`region.csv: 親 "${parent}" が見つかりません（${r.label}）`)
    await db`
      INSERT INTO region (id, label, parent_id, grid_id, ord)
      VALUES (${num(r.id)}, ${r.label!}, ${parentId}, ${num(r.grid_id)}, ${num(r.ord)})
      ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, parent_id = EXCLUDED.parent_id,
        grid_id = EXCLUDED.grid_id, ord = EXCLUDED.ord`
  }

  const units = readCsv(join(dir, 'syllabus_unit.csv'))
  for (const u of [...units].sort((a, b) => Number(a.level) - Number(b.level))) {
    await db`
      INSERT INTO syllabus_unit (id, subject, parent_id, level, label, ord)
      VALUES (${u.id!}, ${u.subject!}, ${orNull(u.parent_id)}, ${num(u.level)}, ${u.label!}, ${num(u.ord)})
      ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
        level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord`
  }

  return { era: eras.length, region: regions.length, syllabusUnit: units.length }
}

export async function seedKc(
  db: Sql,
  dir = SEED_DIR,
  opts: { requireApproval?: boolean } = {},
): Promise<Pick<SeedCounts, 'kc' | 'kcRegion' | 'kcSyllabusUnit' | 'skippedUnapproved'>> {
  const requireApproval = opts.requireApproval ?? true
  const rows = readCsv(join(dir, 'kc.csv'))
  const regionId = new Map(
    readCsv(join(dir, 'region.csv')).map(r => [r.label!, Number(r.id)]),
  )

  const approved = requireApproval ? rows.filter(r => r.approve === '○') : rows
  let kcRegion = 0

  for (const k of approved) {
    await db`
      INSERT INTO kc (id, label, kind, era_id, year_from, year_to, year_precision, prereq_ids, exam_weight)
      VALUES (${k.id!}, ${k.label!}, ${k.kind!}, ${num(k.era_id)}, ${num(k.year_from)}, ${num(k.year_to)},
              ${orNull(k.year_precision)}, ${list(k.prereq_ids)}, ${num(k.exam_weight) ?? 1})
      ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
        year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
        prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight`

    await db`
      INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES (${k.id!}, ${k.unit_id!})
      ON CONFLICT DO NOTHING`

    // primary は1件だけ。kc_region_one_primary の UNIQUE INDEX がこれを保証する
    const primary = regionId.get(k.region_primary!)
    if (primary === undefined) throw new Error(`kc.csv: region_primary "${k.region_primary}" が region.csv にありません（${k.id}）`)
    await db`
      INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES (${k.id!}, ${primary}, true)
      ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = true`
    kcRegion++

    for (const label of list(k.region_others)) {
      const rid = regionId.get(label)
      if (rid === undefined) throw new Error(`kc.csv: region_others "${label}" が region.csv にありません（${k.id}）`)
      await db`
        INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES (${k.id!}, ${rid}, false)
        ON CONFLICT DO NOTHING`
      kcRegion++
    }
  }

  return {
    kc: approved.length,
    kcRegion,
    kcSyllabusUnit: approved.length,
    skippedUnapproved: rows.length - approved.length,
  }
}

/**
 * 層2の正典マスタ（docs/08 §5 層2）
 *
 * ★ kc と同じ承認制にする。年号そのものが中身なので、
 *   誤った行は「正しい教材を誤りと判定して配信を止める」向きに効く。
 *   era / region のように「仕様で確定済み・承認不要」とは扱えない。
 *
 * ★ region_ids は kc.csv と同じくラベルで書き、region.csv から解決する。
 *   CSV に生の id を書くと、region.csv の採番を変えたときに黙って壊れる。
 */
export async function seedCanonEvent(
  db: Sql,
  dir = SEED_DIR,
  opts: { requireApproval?: boolean } = {},
): Promise<{ canonEvent: number; skipped: number }> {
  const requireApproval = opts.requireApproval ?? true
  const rows = readCsv(join(dir, 'canon_event.csv'))
  const regionId = new Map(
    readCsv(join(dir, 'region.csv')).map(r => [r.label!, Number(r.id)]),
  )

  const approved = requireApproval ? rows.filter(r => r.approve === '○') : rows

  for (const e of approved) {
    const regions = list(e.region_ids).map(label => {
      const id = regionId.get(label)
      if (id === undefined) throw new Error(`canon_event.csv: region "${label}" が region.csv にありません（${e.id}）`)
      return id
    })
    await db`
      INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids)
      VALUES (${e.id!}, ${e.label!}, ${list(e.aliases)}, ${num(e.year_from)}, ${num(e.year_to)},
              ${e.precision!}, ${regions})
      ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
        year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
        precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids`
  }

  return { canonEvent: approved.length, skipped: rows.length - approved.length }
}

/**
 * 層2の人物マスタ（docs/08 §5 層2）
 *
 * ★ person.id は GENERATED ALWAYS AS IDENTITY なので CSV の id は使わない。
 *   label が UNIQUE なので、冪等性はそちらで担保する。
 *   CSV の id 列は人が行を指すためだけの鍵である（`validate.mjs` が一意性を見る）。
 */
export async function seedPerson(
  db: Sql,
  dir = SEED_DIR,
  opts: { requireApproval?: boolean } = {},
): Promise<{ person: number; skipped: number }> {
  const requireApproval = opts.requireApproval ?? true
  const rows = readCsv(join(dir, 'person.csv'))
  const approved = requireApproval ? rows.filter(r => r.approve === '○') : rows

  for (const p of approved) {
    await db`
      INSERT INTO person (label, aliases, era_id)
      VALUES (${p.label!}, ${list(p.aliases)}, ${num(p.era_id)})
      ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id`
  }

  return { person: approved.length, skipped: rows.length - approved.length }
}

export async function seedAll(db: Sql, dir = SEED_DIR, opts: { requireApproval?: boolean } = {}): Promise<SeedCounts> {
  const m = await seedMasters(db, dir)
  const k = await seedKc(db, dir, opts)
  // 正典は region を解決するのでマスタの後に入れる
  const c = await seedCanonEvent(db, dir, opts)
  const p = await seedPerson(db, dir, opts)
  return {
    ...m, ...k,
    canonEvent: c.canonEvent,
    person: p.person,
    skippedCanonEvent: c.skipped,
    skippedPerson: p.skipped,
  }
}
