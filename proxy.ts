import { NextResponse, type NextRequest } from 'next/server'
import { createServerClient } from '@supabase/ssr'

/**
 * CSP と、未認証の遮断（Next 16 では middleware.ts ではなく proxy.ts）
 *
 * 仕様: docs/12-nonfunctional.md §6（CSP）／docs/10-legal-risk.md §3.2 G2（未認証は404）
 *
 * Next.js は起動用のスクリプトをインラインで埋め込むため、
 * script-src を 'self' だけにすると**ハイドレーションが起きず画面が動かなくなる**。
 * かといって 'unsafe-inline' を許すと CSP の意味が薄れるので、nonce を使う。
 */

/**
 * 未認証でも開ける経路。
 *
 * ★ ここに載っていない全ての経路は、未認証なら 404 になる。
 *   docs/10 G2 は「リダイレクト」ではなく「404」と定めている。
 *   公衆送信性を下げるのが目的なので、ログイン画面の存在すら見せない。
 *   招待された人には /invite の URL を作者が直接渡す。
 */
const PUBLIC_PATHS = ['/invite', '/login', '/auth/callback']

const isPublic = (path: string): boolean =>
  PUBLIC_PATHS.some(p => path === p || path.startsWith(`${p}/`))

/**
 * cookie を見るだけの楽観的な確認。
 *
 * ★ ここでDBを見ない。proxy は先読みを含む全ての経路で走るため、
 *   重い確認を入れると全体が遅くなる（Next の作法書 §Authorization）。
 *   本当の防御は lib/auth/dal.ts が担う。
 *
 * ★ ただし session の更新はここでしかできない。@supabase/ssr が
 *   「更新した token を書き戻せる場所が無いと、突然ログアウトする」と警告している。
 */
async function authorize(req: NextRequest, res: NextResponse): Promise<boolean> {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL
  const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
  // ★ 環境変数が無ければ関門ごと素通りさせる。lib/db/optional.ts の tryDb() と同じ作法。
  //   そうしないと DB も鍵も無い Vercel のプレビューが全ページ 404 になり、
  //   意匠の確認ができなくなる（docs/11b の検証がプレビュー頼み）
  if (!url || !anonKey) return true

  const supabase = createServerClient(url, anonKey, {
    cookies: {
      getAll: () => req.cookies.getAll().map(c => ({ name: c.name, value: c.value })),
      setAll: (list) => {
        for (const c of list) res.cookies.set(c.name, c.value, c.options)
      },
    },
  })
  const { data } = await supabase.auth.getUser()
  return data.user !== null
}

export default async function proxy(req: NextRequest) {
  const nonce = Buffer.from(crypto.randomUUID()).toString('base64')
  const dev = process.env.NODE_ENV === 'development'

  const csp = [
    "default-src 'self'",
    // 'strict-dynamic' があると nonce 付きスクリプトが読み込む子スクリプトも通る。
    // 開発時は eval を使うため 'unsafe-eval' を足す。
    `script-src 'self' 'nonce-${nonce}' 'strict-dynamic'${dev ? " 'unsafe-eval'" : ''}`,
    // 意匠は docs/design/litverse.css が Google Fonts を @import している。
    // 自前配信（next/font）に切り替えるかは M15（初回転送量の実測）と合わせて判断する。
    "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com",
    // 'self' が要る。開発オーバーレイの字体が同一オリジンから来るほか、
    // 将来 next/font で自前配信に切り替えたときに黙って落ちないようにするため。
    "font-src 'self' https://fonts.gstatic.com data:",
    // 動画は nocookie ドメインのみ（docs/09b §5）
    'frame-src https://www.youtube-nocookie.com',
    "img-src 'self' data: https://i.ytimg.com",
    "connect-src 'self'",
    // ★ 明示する。未指定でも default-src に落ちて動くが、
    //   Service Worker を登録するという意図が読めない（docs/12 §10）。
    //   manifest-src も同じ理由で書く。
    "worker-src 'self'",
    "manifest-src 'self'",
    "object-src 'none'",
    "base-uri 'self'",
    "form-action 'self'",
    "frame-ancestors 'none'",
  ].join('; ')

  const headers = new Headers(req.headers)
  headers.set('x-nonce', nonce)

  const res = NextResponse.next({ request: { headers } })
  res.headers.set('Content-Security-Policy', csp)

  // ★ CSP を付けてから遮断する。404 のページにも CSP は要る
  if (!isPublic(req.nextUrl.pathname) && !(await authorize(req, res))) {
    const denied = new NextResponse(null, { status: 404 })
    denied.headers.set('Content-Security-Policy', csp)
    // 更新された session の cookie は捨てない（次の要求でログインし直させない）
    for (const c of res.cookies.getAll()) denied.cookies.set(c)
    return denied
  }
  return res
}

export const config = {
  matcher: [
    // 静的アセットと画像最適化には CSP を付けない
    { source: '/((?!_next/static|_next/image|favicon.ico).*)', missing: [{ type: 'header', key: 'next-router-prefetch' }] },
  ],
}
