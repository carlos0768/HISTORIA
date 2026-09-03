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
import { SEED_DIR as DEFAULT_SEED_DIR, ITEM_NAMESPACE, stableUuid } from './seed'

/** SQL の文字列リテラル。単引用符を二重にする */
const q = (v: string): string => `'${v.replaceAll("'", "''")}'`
const lit = (v: string | number | null): string =>
  v === null ? 'NULL' : typeof v === 'number' ? String(v) : q(v)
/** text[] のリテラル */
const arr = (v: string[]): string => (v.length === 0 ? `'{}'::text[]` : `ARRAY[${v.map(q).join(',')}]::text[]`)
/** smallint[] のリテラル。canon_event.region_ids 用（arr は ::text[] 固定なので使えない） */
const numArr = (v: number[]): string =>
  v.length === 0 ? `'{}'::smallint[]` : `ARRAY[${v.join(',')}]::smallint[]`

/**
 * SQL エディタに貼れる大きさの目安（KB）。
 *
 * ★ 実測（2026-09-03）: 1016KB の 02_seed.sql は Supabase のエディタで実行できなかった。
 *   厳密な上限は公表されていないので、余裕を見てこの値で「貼るな」に切り替える。
 *   seed-remote.ts のヘッダが挙げている 400KB より低めに取ってある。
 */
export const PASTE_LIMIT_KB = 300

/**
 * 投入手順の案内。
 *
 * ★ 純粋関数にしてある。**実際に出る文字列を試験できるようにするため**である。
 *   最初は console.log を直に並べていたが、試験が「ソースにこの語が在るか」しか
 *   見られず、案内から1行消しても落ちなかった（生成物のヘッダに同じ語があったため）。
 *   出力そのものを返す形にすれば、その取り違えは起きない。
 *
 * ★ ここは**実際に作者を詰まらせた**ので分岐を明示する（2026-09-03）。
 *   以前は「1. docs/schema.sql（そのまま貼れる）2. seed/sql/02_seed.sql」とだけ出していた。
 *   どちらも既存の本番DBには当てはまらない:
 *     - docs/schema.sql は CREATE TABLE 44本すべてが IF NOT EXISTS 無しなので、
 *       既に流したDBでは最初の era で必ず落ちる（「そのまま貼れる」のは空のDBだけ）
 *     - 02_seed.sql は承認が進むほど大きくなり、SQL エディタが受け付けなくなる
 */
export function deployGuidance(kb: number): string[] {
  const lines = [
    'スキーマを入れる（どちらか一方）:',
    '  新規の空DB   → docs/schema.sql → seed/sql/03_rls.sql をエディタに貼る',
    '  既に流したDB → seed/sql/04_phase3.sql → seed/sql/03_rls.sql をエディタに貼る',
    '               （docs/schema.sql は貼らない。era がすでに存在すると言われて止まる）',
    '  いまどの状態か分からないとき:',
    "    DATABASE_URL='...' npx tsx scripts/db/check-remote.ts",
    '',
    'seed を入れる:',
  ]
  if (kb > PASTE_LIMIT_KB) {
    lines.push(
      `  ★ ${kb.toFixed(0)}KB あるので SQL エディタには貼れない（上限 ${PASTE_LIMIT_KB}KB 目安）。`,
      '    貼らずに、CSV から直接 INSERT する:',
      "      DATABASE_URL='...' npx tsx scripts/db/seed-remote.ts          # 下見",
      "      DATABASE_URL='...' npx tsx scripts/db/seed-remote.ts --apply  # 実行",
    )
  } else {
    lines.push(
      `  seed/sql/02_seed.sql をエディタに貼る（${kb.toFixed(0)}KB）`,
      "  または DATABASE_URL='...' npx tsx scripts/db/seed-remote.ts --apply",
    )
  }
  return lines
}

export type SeedSql = { sql: string; counts: Record<string, number> }

/**
 * CSV から SQL を組み立てる。試験から呼べるよう関数にしてある。
 *
 * ★ dir を差し替えられるようにしてある（`seedKc(db, dir, opts)` と同じ形）。
 *   実データが全件承認になると「未承認は含めない」を実データでは示せなくなるため、
 *   承認を落とした写しを渡して確かめられる必要がある。
 */
export function buildSeedSql(SEED_DIR = DEFAULT_SEED_DIR): SeedSql {
const out: string[] = []
const say = (s = '') => out.push(s)

say('-- HISTORIA seed（自動生成 — 手で編集しない）')
say('-- 作り直す: npx tsx scripts/db/dump-sql.ts')
say('--')
say('-- 先にスキーマを入れておくこと。')
say('--   新規の空DB     : docs/schema.sql')
say('--   既に流したDB   : seed/sql/04_phase3.sql（docs/schema.sql は貼らない。era で落ちる）')
say('-- 何度流しても結果は同じになる（ON CONFLICT で上書きする）。')
say('--')
say('-- ★ このファイルは**新規DBへの貼り付け用**である。')
say(`--   Supabase の SQL エディタは ${PASTE_LIMIT_KB}KB を超えると実行できない。`)
say('--   本番へ入れるときは貼らずに、CSV から直接 INSERT する道具を使う:')
say("--     DATABASE_URL='...' npx tsx scripts/db/seed-remote.ts --apply")
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

// ---- 層2の正典（docs/08 §5 層2）----
const canonRows = readCsv(join(SEED_DIR, 'canon_event.csv'))
const canon = canonRows.filter(r => r.approve === '○')
say(`-- 正典イベント ${canon.length} 件（承認されず除外 ${canonRows.length - canon.length}）`)
for (const e of canon) {
  const regions2 = list(e.region_ids).map(label => {
    const id = regionId.get(label)
    if (id === undefined) throw new Error(`canon_event.csv: region "${label}" が region.csv にありません（${e.id}）`)
    return id
  })
  say(`INSERT INTO canon_event (id, label, aliases, year_from, year_to, precision, region_ids) VALUES ` +
    `(${lit(e.id!)}, ${lit(e.label!)}, ${arr(list(e.aliases))}, ${lit(num(e.year_from))}, ` +
    `${lit(num(e.year_to))}, ${lit(e.precision!)}, ${numArr(regions2)})`)
  say(`  ON CONFLICT (id) DO UPDATE SET label = EXCLUDED.label, aliases = EXCLUDED.aliases,`)
  say(`    year_from = EXCLUDED.year_from, year_to = EXCLUDED.year_to,`)
  say(`    precision = EXCLUDED.precision, region_ids = EXCLUDED.region_ids;`)
}
say('')

// ★ person.id は GENERATED ALWAYS AS IDENTITY。label が UNIQUE なので冪等性はそちらで取る
const personRows = readCsv(join(SEED_DIR, 'person.csv'))
const persons = personRows.filter(r => r.approve === '○')
say(`-- 正典人物 ${persons.length} 件（承認されず除外 ${personRows.length - persons.length}）`)
for (const p of persons) {
  say(`INSERT INTO person (label, aliases, era_id) VALUES ` +
    `(${lit(p.label!)}, ${arr(list(p.aliases))}, ${lit(num(p.era_id))})`)
  say(`  ON CONFLICT (label) DO UPDATE SET aliases = EXCLUDED.aliases, era_id = EXCLUDED.era_id;`)
}
say('')

// ---- 共有設問 ----
// ★ これが無いと、SQL を貼っただけでは1問も出題されない。
//   KC と正典だけ入れても「今日やること」は空になる（出題は item が要る）。
//   seedItem と同じ規則で作る: id は stableUuid で決まり、user_id は NULL（共有プール）、
//   approved は作者の承認済みとして true。
//
// ★ approved_at に生成時刻を焼き込まない。焼き込むと流すたびに SQL が変わり、
//   生成物の鮮度を見る dump-sql.test.ts が毎回落ちる。SQL の now() に任せる。
// ★ **承認済みの KC を参照している設問だけを出す。**
//   item_kc.kc_id は kc(id) への外部キーである（docs/schema.sql:320）。
//   承認されなかった KC を指す item_kc を出すと外部キー違反になり、
//   seed 全体が1つのトランザクションなので**丸ごと落ちる**。
//   設問だけ承認して KC を却下する、という組み合わせは作者がいつでも作れるので、
//   ここで先に落としておく（落とした数は下の行に出す）。
const approvedKcIds = new Set(approved.map(k => k.id!))
const itemRows = readCsv(join(SEED_DIR, 'item.csv'))
const itemsApproved = itemRows.filter(r => r.approve === '○')
const items = itemsApproved.filter(r => approvedKcIds.has(r.kc_id!))
const orphanItems = itemsApproved.length - items.length
const seenItemId = new Set<string>()
say(`-- 共有設問 ${items.length} 件（承認されず除外 ${itemRows.length - itemsApproved.length}` +
    `${orphanItems > 0 ? ` / KC が未承認のため除外 ${orphanItems}` : ''}）`)
for (const t of items) {
  const id = stableUuid(ITEM_NAMESPACE, t.id!)
  if (seenItemId.has(id)) continue          // seed.ts の dedupe と同じ（後勝ちではなく先勝ち）
  seenItemId.add(id)
  const choices = (['a', 'b', 'c', 'd'] as const).map(k => ({ key: k, text: t[k]! }))
  say(`INSERT INTO item (id, user_id, format, stem, choices, answer_key, explanation,`)
  say(`                  guess_rate, approved, approved_by, approved_at) VALUES`)
  say(`  (${lit(id)}, NULL, 'mcq4', ${lit(t.stem!)}, ${q(JSON.stringify(choices))}::jsonb,`)
  say(`   ${q(JSON.stringify(t.answer!))}::jsonb, ${lit(t.explanation!)}, 0.25, true, 'author', now())`)
  say(`  ON CONFLICT (id) DO UPDATE SET stem = EXCLUDED.stem, choices = EXCLUDED.choices,`)
  say(`    answer_key = EXCLUDED.answer_key, explanation = EXCLUDED.explanation,`)
  say(`    approved = EXCLUDED.approved, approved_by = EXCLUDED.approved_by;`)
  say(`INSERT INTO item_kc (item_id, kc_id, weight) VALUES (${lit(id)}, ${lit(t.kc_id!)}, 1.0)`)
  say(`  ON CONFLICT DO NOTHING;`)
}
say('')

// ---- 動画（docs/09b-video.md）----
// ★ 承認済みのチャンネルと動画だけ。埋め込み禁止・年齢制限は入れない（V5）。
//   DB 側の CHECK にも同じ条件があるが、当てて落とすのではなくここで落とす。
const chRows = readCsv(join(SEED_DIR, 'channel_allowlist.csv'))
const channels = chRows.filter(r => r.approve === '○')
say(`-- 動画のチャンネル ${channels.length} 件（承認されず除外 ${chRows.length - channels.length}）`)
for (const c of channels) {
  say(`INSERT INTO channel_allowlist (channel_id, channel_title, subject_scope, note) VALUES ` +
    `(${lit(c.id!)}, ${lit(c.channel_title!)}, ${lit(c.subject_scope!)}, ${lit(orNull(c.note))})`)
  say(`  ON CONFLICT (channel_id) DO UPDATE SET channel_title = EXCLUDED.channel_title,`)
  say(`    subject_scope = EXCLUDED.subject_scope, note = EXCLUDED.note;`)
}
say('')

const vRows = readCsv(join(SEED_DIR, 'video.csv'))
const videos = vRows.filter(r => r.approve === '○'
  && r.embeddable === 'true' && r.yt_rating !== 'ytAgeRestricted')
const chSet = new Set(channels.map(c => c.id))
say(`-- 動画 ${videos.length} 件（承認・埋め込み可のみ。除外 ${vRows.length - videos.length}）`)
for (const v of videos) {
  if (!chSet.has(v.channel_id)) {
    throw new Error(`video.csv: channel_id "${v.channel_id}" が承認済みの channel_allowlist にありません（${v.id}）`)
  }
  say(`INSERT INTO video (id, title, description, channel_id, duration_sec, published_at,`)
  say(`                   embeddable, yt_rating, status, approved_at) VALUES`)
  say(`  (${lit(v.id!)}, ${lit(v.title!)}, ${lit(orNull(v.description))}, ${lit(v.channel_id!)},`)
  say(`   ${lit(num(v.duration_sec))}, ${v.published_at ? lit(v.published_at) : 'NULL'},`)
  // ★ true と決め打ちにしない（scripts/db/seed.ts と同じ理由）。
  //   上の filter を通った行しか来ないので値は同じだが、決め打ちにすると
  //   docs/schema.sql:484 の CHECK が一度も発火しない死んだ制約になる
  say(`   ${v.embeddable === 'true'}, ${lit(orNull(v.yt_rating))}, 'approved', now())`)
  say(`  ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title,`)
  say(`    description = EXCLUDED.description, duration_sec = EXCLUDED.duration_sec,`)
  say(`    embeddable = EXCLUDED.embeddable, yt_rating = EXCLUDED.yt_rating,`)
  say(`    status = EXCLUDED.status, approved_at = EXCLUDED.approved_at;`)
}
say('')

const vSet = new Set(videos.map(v => v.id))
const links = readCsv(join(SEED_DIR, 'video_kc.csv')).filter(r => vSet.has(r.video_id))
say(`-- 動画と KC の対応 ${links.length} 件`)
for (const l of links) {
  say(`INSERT INTO video_kc (video_id, kc_id, start_sec, end_sec, relevance, source) VALUES ` +
    `(${lit(l.video_id!)}, ${lit(l.kc_id!)}, ${num(l.start_sec) ?? 0}, ` +
    `${lit(num(l.end_sec))}, ${num(l.relevance) ?? 1.0}, 'manual')`)
  say(`  ON CONFLICT (video_id, kc_id, start_sec) DO UPDATE SET`)
  say(`    end_sec = EXCLUDED.end_sec, relevance = EXCLUDED.relevance, source = EXCLUDED.source;`)
}
say('')

say('COMMIT;')
say('')
say('-- 確認用')
say(`-- SELECT (SELECT count(*) FROM era) AS era, (SELECT count(*) FROM region) AS region,`)
say(`--        (SELECT count(*) FROM syllabus_unit) AS unit, (SELECT count(*) FROM kc) AS kc,`)
say(`--        (SELECT count(*) FROM kc_region) AS kc_region,`)
say(`--        (SELECT count(*) FROM canon_event) AS canon_event, (SELECT count(*) FROM person) AS person,`)
say(`--        (SELECT count(*) FROM item) AS item, (SELECT count(*) FROM item_kc) AS item_kc;`)
say(`-- 期待値: era=${eras.length} region=${regions.length} unit=${units.length} kc=${approved.length} ` +
  `kc_region=${kcRegionCount} canon_event=${canon.length} person=${persons.length} item=${seenItemId.size}`)

return {
  sql: out.join('\n') + '\n',
  counts: {
    era: eras.length, region: regions.length, syllabusUnit: units.length,
    kc: approved.length, kcRegion: kcRegionCount, skipped,
    canonEvent: canon.length, person: persons.length, item: seenItemId.size,
    channel: channels.length, video: videos.length, videoKc: links.length,
  },
}
}

/** 書き出し先。リポジトリに入れて、実行しなくても GitHub から取れるようにする */
export const SEED_SQL_PATH = join(DEFAULT_SEED_DIR, 'sql', '02_seed.sql')

if (process.argv[1]?.endsWith('dump-sql.ts')) {
  const { sql, counts } = buildSeedSql()
  if (process.argv.includes('--stdout')) {
    process.stdout.write(sql)
  } else {
    mkdirSync(join(DEFAULT_SEED_DIR, 'sql'), { recursive: true })
    writeFileSync(SEED_SQL_PATH, sql)
    console.log(`seed/sql/02_seed.sql に書き出した（${(sql.length / 1024).toFixed(0)}KB）`)
    console.log(`  時代 ${counts.era} / 地域 ${counts.region} / 章立て ${counts.syllabusUnit} / ` +
      `KC ${counts.kc}（除外 ${counts.skipped}）/ kc_region ${counts.kcRegion}`)
    console.log(`  正典: canon_event ${counts.canonEvent} / person ${counts.person}`)
    console.log(`  共有設問: item ${counts.item}`)
    console.log(`  動画: チャンネル ${counts.channel} / 動画 ${counts.video} / 対応 ${counts.videoKc}`)
    if (counts.item === 0) {
      console.log('  ※ item が0件。承認欄が空のままだと1問も出題されない。')
      console.log('    npx tsx scripts/db/approve-kc.ts --file item --all')
    }
    console.log('')
    for (const line of deployGuidance(sql.length / 1024)) console.log(line)
  }
}
