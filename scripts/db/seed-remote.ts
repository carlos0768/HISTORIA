/**
 * 既に動いているデータベース（本番の Supabase など）へ seed を入れる
 *
 *   DATABASE_URL='postgresql://...' npx tsx scripts/db/seed-remote.ts           # 下見だけ
 *   DATABASE_URL='postgresql://...' npx tsx scripts/db/seed-remote.ts --apply   # 実行
 *
 * ★ なぜ専用の入口が要るのか。既存の2つはどちらも本番に向けられない。
 *   - dev-seed.ts は DROP DATABASE してから作り直す。本番に向けたら全部消える
 *   - migrate.ts は public に表があると拒否する（スキーマ適用のための道具だから）
 *
 * ★ この道具は壊さない。DROP も TRUNCATE も DELETE も書かない。
 *   seedAll（マスタ / KC / 正典）の INSERT は全て ON CONFLICT なので、
 *   何度流しても結果は同じになる。
 *
 * ★ SQL 本文を会話や画面に出さない。seed/sql/02_seed.sql は 400KB を超えるため、
 *   貼り付けで運ぶのは現実的でない。ここでは CSV から直接 INSERT する。
 */
import postgres from 'postgres'
import { seedAll, SEED_DIR } from './seed'

const url = process.env.DATABASE_URL
if (!url) {
  console.error('DATABASE_URL が未設定です。')
  console.error("  DATABASE_URL='postgresql://...' npx tsx scripts/db/seed-remote.ts --apply")
  process.exit(1)
}

const apply = process.argv.includes('--apply')

// パスワードは出さない（migrate.ts と同じ）
const shown = new URL(url)
shown.password = '***'
console.log(`接続先: ${shown.host}${shown.pathname}`)

const db = postgres(url, { prepare: false, max: 1, onnotice: () => {} })

/**
 * ★ **item を必ず出す。** 2026-09-03、この道具は KC と正典しか報告せず、
 *   `item` を一度も画面に出さないまま「完了。」と言っていた。作者が古い
 *   作業ツリーで流したとき（`cd` に失敗して `git pull` が飛ばされた）、
 *   0 問しか入っていないのに成功に見えた。**一番知りたい数字が出ない道具は、
 *   成功と失敗を見分けられない。**
 */
type Counts = {
  kc: string; retired: string; ksu: string; kr: string; units: string; live: string
  ce: string; pe: string; item: string; ikc: string
}
const snapshot = async (): Promise<Counts> => {
  const [r] = await db<Counts[]>`
    SELECT (SELECT count(*) FROM kc)                              AS kc,
           (SELECT count(*) FROM kc WHERE retired)                AS retired,
           (SELECT count(*) FROM kc_syllabus_unit)                AS ksu,
           (SELECT count(*) FROM kc_region)                       AS kr,
           (SELECT count(DISTINCT unit_id) FROM kc_syllabus_unit) AS units,
           -- ★ 教材を作るのはこちらの数である（generate-remote.ts の pendingUnits）。
           --   範囲外にした KC しか無い節は入らない（docs/02 §6.1）
           (SELECT count(DISTINCT ku.unit_id)
              FROM kc_syllabus_unit ku
              JOIN kc k ON k.id = ku.kc_id AND NOT k.retired)     AS live,
           (SELECT count(*) FROM canon_event)                     AS ce,
           (SELECT count(*) FROM person)                          AS pe,
           (SELECT count(*) FROM item WHERE user_id IS NULL)      AS item,
           (SELECT count(*) FROM item_kc)                         AS ikc`
  return r!
}
const show = (label: string, c: Counts) => {
  const pad = ' '.repeat(label.length)
  console.log(`  ${label}: kc ${c.kc}（範囲外 ${c.retired}）/ kc_syllabus_unit ${c.ksu} / kc_region ${c.kr}`)
  // ★ 「KC を持つ節」と「教材を作る節」は違う。後者が生成の分母であり、
  //   そのまま金額になる（1本あたり約50円）。ここがずれていたら seed がまだである
  console.log(`  ${pad}  KC を持つ節 ${c.units} / 教材を作る節 ${c.live}`)
  console.log(`  ${pad}  正典: canon_event ${c.ce} / person ${c.pe}`)
  console.log(`  ${pad}  共有設問: item ${c.item} / item_kc ${c.ikc}` +
    (c.item === '0' ? '  ← 0 問。approve が空のままか、古い作業ツリーで流している' : ''))
}

try {
  // スキーマが無い相手に流さない。表が無いのに INSERT を始めると
  // 「途中まで入った」状態になりうる
  const [has] = await db<{ ok: boolean }[]>`
    SELECT to_regclass('public.kc') IS NOT NULL AS ok`
  if (!has?.ok) {
    console.error('\nkc 表がありません。先に docs/schema.sql を流してください。')
    process.exit(1)
  }

  const before = await snapshot()
  show('現在', before)

  if (!apply) {
    console.log('\n下見だけで終わります。実行するには --apply を付けてください。')
    console.log('  DATABASE_URL=... npx tsx scripts/db/seed-remote.ts --apply')
    process.exit(0)
  }

  console.log('\n投入しています…（KC 1件あたり3クエリ以上あるので少しかかります）')
  // 1トランザクションにまとめる。途中で切れても半端に入らないようにするため
  const counts = await db.begin(async tx =>
    seedAll(tx as unknown as postgres.Sql, SEED_DIR))

  console.log(`  時代 ${counts.era} / 地域 ${counts.region} / 章立て ${counts.syllabusUnit}`)
  console.log(`  KC ${counts.kc}（承認されず除外 ${counts.skippedUnapproved}）/ kc_region ${counts.kcRegion}`)
  console.log(`  正典: canon_event ${counts.canonEvent}（除外 ${counts.skippedCanonEvent}）` +
    ` / person ${counts.person}（除外 ${counts.skippedPerson}）`)
  console.log(`  共有設問: item ${counts.item}（承認されず除外 ${counts.skippedItem}）` +
    ` / item_kc ${counts.itemKc}`)
  if (counts.item === 0) {
    // ★ 黙って 0 件で終わらせない。これが起きるのは approve が空のときか、
    //   古い作業ツリーで流したときで、どちらも画面には成功に見える
    console.log('\n  ⚠ 共有設問が 1 問も入っていません。1問も出題されません。')
    console.log('    seed/item.csv の approve 列が空のままではありませんか。')
    console.log('    承認済みのはずなら、いま居るディレクトリが古い可能性があります:')
    console.log(`      git -C . log --oneline -1`)
  }

  const after = await snapshot()
  show('投入後', after)
  console.log('\n完了。')
} finally {
  await db.end({ timeout: 10 })
}
