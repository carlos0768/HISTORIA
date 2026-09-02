/**
 * OAuth ／ メールリンクの戻り先
 *
 * 仕様: docs/03 §7
 *
 * ★ ここだけがブラウザから見える認証の受け口である。proxy.ts はこの経路を素通しする。
 *   認証コードを session に交換する処理は**サーバー側で完結する**ので、
 *   CSP の connect-src 'self' を広げずに済む。
 *
 * ★ 交換に失敗したら入口へ戻す。理由をURLに載せない
 *   （どのコードが無効かを外に教えない）。
 */
import { NextResponse, type NextRequest } from 'next/server'
import { authEnv, createAuthClient } from '@/lib/auth/supabase'
import { sql } from '@/lib/db/client'
import { isRegistered } from '@/lib/auth/signup'

export async function GET(req: NextRequest): Promise<NextResponse> {
  const env = authEnv()
  const code = req.nextUrl.searchParams.get('code')
  const home = new URL('/', req.nextUrl.origin)
  const invite = new URL('/invite', req.nextUrl.origin)

  if (!env || !code) return NextResponse.redirect(invite)

  // cookie の書き込みはこのレスポンスに載せる。
  // @supabase/ssr は setAll を通じて更新後の token を返してくる
  const res = NextResponse.redirect(home)
  const supabase = createAuthClient(env, {
    getAll: () => req.cookies.getAll().map(c => ({ name: c.name, value: c.value })),
    setAll: (list) => {
      for (const c of list) res.cookies.set(c.name, c.value, c.options)
    },
  })

  const { data, error } = await supabase.auth.exchangeCodeForSession(code)
  if (error || !data.user) return NextResponse.redirect(invite)

  // 登録がまだなら生年月日と同意へ。済んでいればホームへ
  let registered = false
  try {
    registered = await isRegistered(sql(), data.user.id)
  } catch {
    // DB に繋がらないときは登録の続きへ送る（そこで理由を出す）
  }
  if (!registered) {
    const profile = new URL('/profile', req.nextUrl.origin)
    const to = NextResponse.redirect(profile)
    for (const c of res.cookies.getAll()) to.cookies.set(c)
    return to
  }
  return res
}
