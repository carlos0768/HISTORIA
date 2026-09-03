/**
 * 動いているデータベースが、いまどの状態なのかを読む
 *
 *   DATABASE_URL='postgresql://...' npx tsx scripts/db/check-remote.ts
 *
 * ★ なぜこれが要るのか（2026-09-03）。
 *   作者が本番へ docs/schema.sql を貼って「era がすでに存在する」で止まった。
 *   schema.sql は CREATE TABLE 44本すべてが IF NOT EXISTS 無しなので、
 *   既に流したDBに貼れば必ずそうなる。**それ自体は正しい挙動**である。
 *   困るのは「では本番はいまどこまで入っているのか」を知る手段が無かったこと。
 *   verify-rls.ts は RLS を確かめるが、表や列の有無は見ない。ここを埋める。
 *
 * ★ **読み取りしかしない。** CREATE も ALTER も INSERT も書かない。
 *   判定は scripts/db/inspect.ts に置いてあり、試験が「1行も動かない」ことを見ている。
 */
import postgres from 'postgres'
import { inspect, SEEDED_TABLES } from './inspect'

const url = process.env.DATABASE_URL
if (!url) {
  console.error('DATABASE_URL が未設定です。')
  console.error("  DATABASE_URL='postgresql://...' npx tsx scripts/db/check-remote.ts")
  process.exit(1)
}

// パスワードは出さない（migrate.ts / seed-remote.ts と同じ）
const shown = new URL(url)
shown.password = '***'
console.log(`接続先: ${shown.host}${shown.pathname}\n`)

const db = postgres(url, { prepare: false, max: 1, onnotice: () => {} })

try {
  const r = await inspect(db)

  console.log(`スキーマ: docs/schema.sql が要求する ${r.expectedTables} 表のうち ` +
    `${r.expectedTables - r.missingTables.length} 表が在る`)

  if (r.missingTables.length > 0) {
    console.log(`  ✗ 欠けている表 ${r.missingTables.length}: ${r.missingTables.join(', ')}`)
  }
  if (r.missingColumns.length > 0) {
    console.log(`  ✗ 欠けている列 ${r.missingColumns.length}: ${r.missingColumns.join(', ')}`)
  }

  // ★ 「欠けている」だけでは次に進めない。何を流せばよいかまで言う
  console.log('')
  switch (r.verdict) {
    case 'complete':
      console.log('  ✓ 欠けているものは無い。**差分 SQL を流す必要は無い。**')
      console.log('    docs/schema.sql は貼らないこと（era がすでに存在すると言われて止まる）。')
      break
    case 'empty':
      console.log('  → 空のDBである。docs/schema.sql → seed/sql/03_rls.sql の順にエディタへ貼る。')
      break
    case 'phase3':
      console.log('  → seed/sql/04_phase3.sql を貼れば埋まる（3KB・何度流しても同じ）。')
      console.log('    そのあと seed/sql/03_rls.sql を流し直すこと。')
      break
    case 'unknown_drift':
      console.log('  → 04_phase3.sql では埋まらない差分がある。')
      console.log('    npx tsx scripts/db/dump-migration.ts で差分 SQL を作り直すこと。')
      break
  }

  // ---- seed の入り具合 ----
  console.log('\nseed の行数:')
  let anyEmpty = false
  for (const t of SEEDED_TABLES) {
    const n = r.counts[t]
    if (n === undefined) { console.log(`  ${t.padEnd(16)}      —  （表が無い）`); continue }
    if (n === 0) anyEmpty = true
    console.log(`  ${t.padEnd(16)} ${String(n).padStart(6)} 件${n === 0 ? '  ← 空' : ''}`)
  }

  if (anyEmpty) {
    console.log('')
    console.log('  空の表がある。seed は貼らずに、CSV から直接 INSERT する:')
    console.log("    DATABASE_URL='...' npx tsx scripts/db/seed-remote.ts --apply")
    if (r.counts.item === 0) {
      console.log('  item が0件のままなら、先に承認が要る（承認は作者の判断・docs/02 §5）:')
      console.log('    npx tsx scripts/db/approve-kc.ts --file item --all')
      console.log('    npm run db:dump-sql')
    }
  }
} finally {
  await db.end({ timeout: 5 })
}
