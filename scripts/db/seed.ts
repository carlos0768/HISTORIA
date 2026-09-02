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
import { createHash } from 'node:crypto'
import type { Sql } from 'postgres'
import { readCsv, orNull, num, list } from './csv'

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..', '..')
export const SEED_DIR = join(ROOT, 'seed')

/**
 * 1行ずつ INSERT しない。
 *
 * ★ seedAll は era 3 + region 24 + 節 117 + KC 408（＋節 408・地域 891）
 *   + canon_event 1,180 + person 446 を入れる。1行1往復だと **約3,500往復**になり、
 *   手元で約3秒、CI では約6倍で20秒前後かかる。
 *   `冪等: 2回流しても件数が増えない` は seedAll を2回呼ぶので 30 秒の上限を超え、
 *   **試験が時間切れで落ちた**（2026-09-02・PR #17）。
 *   さらに悪いことに、時間切れになった試験の書き込みが次の試験に漏れて
 *   別の試験まで巻き添えで落ちる。
 *
 * ★ 直し方として「上限を伸ばす」を採らない。遅いこと自体が原因なので、
 *   まとめて入れて往復を減らす。500行ずつに切るのは Postgres の
 *   パラメータ上限（65535）に将来ぶつからないようにするため。
 *
 * ★ 同じ鍵の行が1つの INSERT に2つあると Postgres が
 *   「ON CONFLICT DO UPDATE command cannot affect row a second time」で落ちる。
 *   1行ずつ入れていたときは後の行が前の行を上書きしていたので、
 *   **同じ意味になるよう鍵で畳んでから**（後勝ち）渡す。
 */
const CHUNK = 500

const dedupe = <T>(rows: T[], key: (r: T) => string): T[] => {
  const m = new Map<string, T>()
  for (const r of rows) m.set(key(r), r)   // 後勝ち。1行ずつ入れていたときと同じ
  return [...m.values()]
}

/** rows を columns の順で束ねて INSERT する。tail は ON CONFLICT 以降 */
async function insertMany(
  db: Sql, table: string, rows: Record<string, unknown>[], columns: string[],
  tail: (db: Sql) => ReturnType<Sql>,
): Promise<void> {
  for (let i = 0; i < rows.length; i += CHUNK) {
    const part = rows.slice(i, i + CHUNK)
    await db`INSERT INTO ${db(table)} ${db(part, ...columns)} ${tail(db)}`
  }
}

/**
 * CSV の読みやすい id から、決まった uuid を作る（RFC 4122 の版3と同じ組み立て）。
 *
 * ★ item.id は uuid なので、CSV に `it.greece.athens_vs_sparta.1` のような
 *   人が読める id を書いても、そのままでは主キーにできない。
 *   毎回 randomUUID にすると**同じ CSV を2回流すたびに設問が増える**ので、
 *   id から決まった uuid を導く。これで ON CONFLICT (id) が効く。
 *
 * ★ 名前空間を混ぜる。他の CSV の id と衝突させないためである。
 */
export const ITEM_NAMESPACE = 'historia.seed.item'
export function stableUuid(namespace: string, name: string): string {
  const h = createHash('md5').update(`${namespace}:${name}`).digest()
  h[6] = (h[6]! & 0x0f) | 0x30 // 版3
  h[8] = (h[8]! & 0x3f) | 0x80 // variant
  const s = h.toString('hex')
  return `${s.slice(0, 8)}-${s.slice(8, 12)}-${s.slice(12, 16)}-${s.slice(16, 20)}-${s.slice(20, 32)}`
}

export type SeedCounts = {
  era: number; region: number; syllabusUnit: number
  kc: number; kcRegion: number; kcSyllabusUnit: number
  canonEvent: number; person: number
  item: number; itemKc: number
  /** ★ KC の未承認件数。canon_event / person とは分けて数える。
   *   1つにまとめると「どの CSV の承認が遅れているか」が分からなくなる */
  skippedUnapproved: number
  skippedCanonEvent: number
  skippedPerson: number
  skippedItem: number
}

export async function seedMasters(db: Sql, dir = SEED_DIR): Promise<Pick<SeedCounts, 'era' | 'region' | 'syllabusUnit'>> {
  const eras = readCsv(join(dir, 'era.csv'))
  await insertMany(db, 'era',
    dedupe(eras.map(e => ({
      id: num(e.id), label: e.label!, start_year: num(e.start_year),
      end_year: num(e.end_year), ord: num(e.ord),
    })), r => String(r.id)),
    ['id', 'label', 'start_year', 'end_year', 'ord'],
    d => d`ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, start_year = EXCLUDED.start_year,
             end_year = EXCLUDED.end_year, ord = EXCLUDED.ord`)

  // 親を先に入れる必要があるので、親を持たない行から順に入れる
  const regions = readCsv(join(dir, 'region.csv'))
  const byLabel = new Map(regions.map(r => [r.label!, r]))
  const ordered = [...regions].sort((a, b) => Number(!!orNull(a.parent_label)) - Number(!!orNull(b.parent_label)))
  await insertMany(db, 'region',
    dedupe(ordered.map(r => {
      const parent = orNull(r.parent_label)
      const parentId = parent ? num(byLabel.get(parent)?.id) : null
      if (parent && parentId === null) throw new Error(`region.csv: 親 "${parent}" が見つかりません（${r.label}）`)
      return { id: num(r.id), label: r.label!, parent_id: parentId, grid_id: num(r.grid_id), ord: num(r.ord) }
    }), r => String(r.id)),
    ['id', 'label', 'parent_id', 'grid_id', 'ord'],
    d => d`ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, parent_id = EXCLUDED.parent_id,
             grid_id = EXCLUDED.grid_id, ord = EXCLUDED.ord`)

  const units = readCsv(join(dir, 'syllabus_unit.csv'))
  await insertMany(db, 'syllabus_unit',
    dedupe([...units].sort((a, b) => Number(a.level) - Number(b.level)).map(u => ({
      id: u.id!, subject: u.subject!, parent_id: orNull(u.parent_id),
      level: num(u.level), label: u.label!, ord: num(u.ord),
    })), r => r.id),
    ['id', 'subject', 'parent_id', 'level', 'label', 'ord'],
    d => d`ON CONFLICT (id) DO UPDATE SET subject = EXCLUDED.subject, parent_id = EXCLUDED.parent_id,
             level = EXCLUDED.level, label = EXCLUDED.label, ord = EXCLUDED.ord`)

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

  // ★ 地域は primary を先に並べる。同じ (kc, region) が primary と others の
  //   両方に出てきたとき、後勝ちの畳み込みで others が勝つと primary が消える。
  //   1行ずつ入れていたときは others 側が ON CONFLICT DO NOTHING だったので
  //   primary が残っていた。その挙動を保つため、primary を**後**に置く。
  const regions: { kc_id: string; region_id: number; is_primary: boolean }[] = []
  for (const k of approved) {
    for (const label of list(k.region_others)) {
      const rid = regionId.get(label)
      if (rid === undefined) throw new Error(`kc.csv: region_others "${label}" が region.csv にありません（${k.id}）`)
      regions.push({ kc_id: k.id!, region_id: rid, is_primary: false })
    }
    // primary は1件だけ。kc_region_one_primary の UNIQUE INDEX がこれを保証する
    const primary = regionId.get(k.region_primary!)
    if (primary === undefined) throw new Error(`kc.csv: region_primary "${k.region_primary}" が region.csv にありません（${k.id}）`)
    regions.push({ kc_id: k.id!, region_id: primary, is_primary: true })
  }
  const uniqueRegions = dedupe(regions, r => `${r.kc_id}|${r.region_id}`)

  await insertMany(db, 'kc',
    dedupe(approved.map(k => ({
      id: k.id!, label: k.label!, kind: k.kind!, era_id: num(k.era_id),
      year_from: num(k.year_from), year_to: num(k.year_to),
      year_precision: orNull(k.year_precision), prereq_ids: list(k.prereq_ids),
      exam_weight: num(k.exam_weight) ?? 1,
    })), r => r.id),
    ['id', 'label', 'kind', 'era_id', 'year_from', 'year_to', 'year_precision', 'prereq_ids', 'exam_weight'],
    d => d`ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, kind = EXCLUDED.kind, era_id = EXCLUDED.era_id,
             year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to, year_precision = EXCLUDED.year_precision,
             prereq_ids = EXCLUDED.prereq_ids, exam_weight = EXCLUDED.exam_weight`)

  await insertMany(db, 'kc_syllabus_unit',
    dedupe(approved.map(k => ({ kc_id: k.id!, unit_id: k.unit_id! })), r => `${r.kc_id}|${r.unit_id}`),
    ['kc_id', 'unit_id'],
    d => d`ON CONFLICT DO NOTHING`)

  await insertMany(db, 'kc_region', uniqueRegions, ['kc_id', 'region_id', 'is_primary'],
    d => d`ON CONFLICT (kc_id, region_id) DO UPDATE SET is_primary = EXCLUDED.is_primary`)

  return {
    kc: approved.length,
    kcRegion: uniqueRegions.length,
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

  await insertMany(db, 'canon_event',
    dedupe(approved.map(e => ({
      id: e.id!, label: e.label!, aliases: list(e.aliases),
      year_from: num(e.year_from), year_to: num(e.year_to), precision: e.precision!,
      region_ids: list(e.region_ids).map(label => {
        const id = regionId.get(label)
        if (id === undefined) throw new Error(`canon_event.csv: region "${label}" が region.csv にありません（${e.id}）`)
        return id
      }),
    })), r => r.id),
    ['id', 'label', 'aliases', 'year_from', 'year_to', 'precision', 'region_ids'],
    d => d`ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,
             year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,
             precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids`)

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

  await insertMany(db, 'person',
    dedupe(approved.map(p => ({
      label: p.label!, aliases: list(p.aliases), era_id: num(p.era_id),
    })), r => r.label),
    ['label', 'aliases', 'era_id'],
    d => d`ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id`)

  return { person: approved.length, skipped: rows.length - approved.length }
}

/**
 * 共有の設問プール（`item.user_id IS NULL`）
 *
 * ★ なぜ手で書くか。app/study/page.tsx は
 *   `(i.user_id = userId OR i.user_id IS NULL)` で出題を引くので、
 *   ここに入れた設問は**日々の出題にも確認テストにも使われる**。
 *   つまり AI の鍵が無くても勉強を始められる。
 *   Gemini の課金開通を待つあいだ、アプリが空のままにならない。
 *
 * ★ 承認は作者が手で行う（schema.sql の item のコメント）。
 *   ファクトチェックによる自動承認は user_id 非NULL の生成物だけである。
 *   共有プールは全員に配られるので、誤りの影響が全員に及ぶ。
 *
 * ★ 四択だけを扱う。guess_rate は lib/loop/answer.ts の guessRateFor と
 *   同じ 0.25 を使う（2箇所に別々の数を書かない）。
 */
export async function seedItem(
  db: Sql,
  dir = SEED_DIR,
  opts: { requireApproval?: boolean; now?: Date } = {},
): Promise<{ item: number; itemKc: number; skipped: number }> {
  const requireApproval = opts.requireApproval ?? true
  const now = opts.now ?? new Date()
  const rows = readCsv(join(dir, 'item.csv'))
  const approved = requireApproval ? rows.filter(r => r.approve === '○') : rows

  const items = dedupe(approved.map(r => ({
    id: stableUuid(ITEM_NAMESPACE, r.id!),
    user_id: null,
    format: 'mcq4',
    stem: r.stem!,
    // ★ db.json で包む。JSON.stringify した文字列をそのまま渡すと、
    //   text → jsonb の暗黙変換で**もう一段 JSON に包まれ**、
    //   配列ではなく「JSON 文字列」として保存される。
    //   そうなると出題の SQL（jsonb_array_elements）が
    //   「cannot get array length of a scalar」で落ちる。実際に踏んで気づいた。
    // why_wrong は入れない。入れるなら選択肢ごとに書く必要があり、
    // いまは explanation で誤答の理由まで説明している
    choices: db.json((['a', 'b', 'c', 'd'] as const).map(k => ({ key: k, text: r[k]! }))),
    answer_key: db.json(r.answer!),
    explanation: r.explanation!,
    guess_rate: 0.25,
    approved: true,
    approved_by: 'author',
    approved_at: now,
  })), r => r.id)

  await insertMany(db, 'item', items,
    ['id', 'user_id', 'format', 'stem', 'choices', 'answer_key', 'explanation',
     'guess_rate', 'approved', 'approved_by', 'approved_at'],
    d => d`ON CONFLICT (id) DO UPDATE SET stem = EXCLUDED.stem, choices = EXCLUDED.choices,
             answer_key = EXCLUDED.answer_key, explanation = EXCLUDED.explanation,
             approved = EXCLUDED.approved, approved_by = EXCLUDED.approved_by,
             approved_at = EXCLUDED.approved_at`)

  const links = dedupe(approved.map(r => ({
    item_id: stableUuid(ITEM_NAMESPACE, r.id!), kc_id: r.kc_id!, weight: 1.0,
  })), r => `${r.item_id}|${r.kc_id}`)

  await insertMany(db, 'item_kc', links, ['item_id', 'kc_id', 'weight'],
    d => d`ON CONFLICT DO NOTHING`)

  return { item: items.length, itemKc: links.length, skipped: rows.length - approved.length }
}

export async function seedAll(db: Sql, dir = SEED_DIR, opts: { requireApproval?: boolean } = {}): Promise<SeedCounts> {
  const m = await seedMasters(db, dir)
  const k = await seedKc(db, dir, opts)
  // 正典は region を解決するのでマスタの後に入れる
  const c = await seedCanonEvent(db, dir, opts)
  const p = await seedPerson(db, dir, opts)
  // 設問は KC を参照するので KC の後に入れる
  const i = await seedItem(db, dir, opts)
  return {
    ...m, ...k,
    canonEvent: c.canonEvent,
    person: p.person,
    item: i.item,
    itemKc: i.itemKc,
    skippedCanonEvent: c.skipped,
    skippedPerson: p.skipped,
    skippedItem: i.skipped,
  }
}
