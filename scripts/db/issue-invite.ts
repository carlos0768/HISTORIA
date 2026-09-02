/**
 * 招待コードを発行する
 *
 *   DATABASE_URL='postgresql://...' npx tsx scripts/db/issue-invite.ts            # 一覧だけ
 *   DATABASE_URL='postgresql://...' npx tsx scripts/db/issue-invite.ts --issue    # 1枚発行
 *   DATABASE_URL='postgresql://...' npx tsx scripts/db/issue-invite.ts --issue --count 3 --days 30
 *
 * ★ invite_code は 0 件で始まる。**この道具が無いと誰もサインアップできない**
 *   （docs/10 G1「招待コードなしにアカウントを作れない」）。
 *
 * ★ 上限10名（G7）は lib/auth/invite.ts の issueInvite() が見る。
 *   「利用者 ＋ 未使用のコード」で数えるので、10枚配ってから
 *   作者自身が入れなくなる、ということが起きない。
 *
 * ★ 引数が無ければ何も書かない。うっかり流しても席が減らない。
 */
import postgres from 'postgres'
import { issueInvite, generateCode, MAX_USERS } from '../../lib/auth/invite'

const url = process.env.DATABASE_URL
if (!url) {
  console.error('DATABASE_URL が未設定です。')
  console.error("  DATABASE_URL='postgresql://...' npx tsx scripts/db/issue-invite.ts --issue")
  process.exit(1)
}

const argv = process.argv.slice(2)
const flag = (name: string, fallback: number): number => {
  const i = argv.indexOf(`--${name}`)
  if (i < 0) return fallback
  const n = Number(argv[i + 1])
  return Number.isFinite(n) && n > 0 ? Math.floor(n) : fallback
}
const issue = argv.includes('--issue')
const count = flag('count', 1)
const days = flag('days', 14)

// パスワードは出さない（migrate.ts / seed-remote.ts と同じ）
const shown = new URL(url)
shown.password = '***'
console.log(`接続先: ${shown.host}${shown.pathname}`)

const db = postgres(url, { prepare: false, max: 1, onnotice: () => {} })

type Row = { code: string; used_by: string | null; expires_at: Date }

try {
  const [has] = await db<{ ok: boolean }[]>`
    SELECT to_regclass('public.invite_code') IS NOT NULL AS ok`
  if (!has?.ok) {
    console.error('\ninvite_code 表がありません。先に docs/schema.sql を流してください。')
    process.exit(1)
  }

  const now = new Date()

  if (issue) {
    const expiresAt = new Date(now.getTime() + days * 24 * 60 * 60 * 1000)
    for (let i = 0; i < count; i++) {
      // 生成したコードが既にあったら引き直す。32^8 なので実際にはまず起きない
      let done = false
      for (let retry = 0; retry < 5 && !done; retry++) {
        const code = generateCode()
        const r = await issueInvite(db, { code, expiresAt })
        if (r.ok) {
          console.log(`発行: ${code}（期限 ${expiresAt.toISOString().slice(0, 10)}）`)
          done = true
        } else if (r.reason === 'full') {
          console.error(`\n上限（${MAX_USERS}名）に達しているため発行しません。`)
          console.error('  「利用者 ＋ 未使用のコード」で数えている（docs/10 G7）。')
          process.exit(1)
        }
        // duplicate なら引き直す
      }
      if (!done) {
        console.error('コードの生成に5回続けて失敗しました。時間をおいて試してください。')
        process.exit(1)
      }
    }
  }

  const rows = await db<Row[]>`
    SELECT code, used_by, expires_at FROM invite_code ORDER BY issued_at`
  const [n] = await db<{ users: string }[]>`SELECT count(*) AS users FROM app_user`

  console.log(`\n利用者 ${n!.users} / ${MAX_USERS}名`)
  if (rows.length === 0) {
    console.log('招待コードはまだありません。--issue を付けると発行します。')
  } else {
    console.log('招待コード:')
    for (const r of rows) {
      const state = r.used_by ? '使用済み'
        : r.expires_at.getTime() <= now.getTime() ? '期限切れ'
        : `未使用（期限 ${r.expires_at.toISOString().slice(0, 10)}）`
      console.log(`  ${r.code}  ${state}`)
    }
  }

  if (!issue) {
    console.log('\n発行するには --issue を付けてください。')
    console.log('  DATABASE_URL=... npx tsx scripts/db/issue-invite.ts --issue --count 3 --days 30')
  }
} finally {
  await db.end({ timeout: 10 })
}
