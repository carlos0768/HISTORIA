import { NextResponse, type NextRequest } from 'next/server'

/**
 * CSP をリクエストごとの nonce 付きで配る（Next 16 では middleware.ts ではなく proxy.ts）
 *
 * 仕様: docs/12-nonfunctional.md §6
 *
 * Next.js は起動用のスクリプトをインラインで埋め込むため、
 * script-src を 'self' だけにすると**ハイドレーションが起きず画面が動かなくなる**。
 * かといって 'unsafe-inline' を許すと CSP の意味が薄れるので、nonce を使う。
 */
export default function proxy(req: NextRequest) {
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
    'font-src https://fonts.gstatic.com data:',
    // 動画は nocookie ドメインのみ（docs/09b §5）
    'frame-src https://www.youtube-nocookie.com',
    "img-src 'self' data: https://i.ytimg.com",
    "connect-src 'self'",
    "object-src 'none'",
    "base-uri 'self'",
    "form-action 'self'",
    "frame-ancestors 'none'",
  ].join('; ')

  const headers = new Headers(req.headers)
  headers.set('x-nonce', nonce)

  const res = NextResponse.next({ request: { headers } })
  res.headers.set('Content-Security-Policy', csp)
  return res
}

export const config = {
  matcher: [
    // 静的アセットと画像最適化には CSP を付けない
    { source: '/((?!_next/static|_next/image|favicon.ico).*)', missing: [{ type: 'header', key: 'next-router-prefetch' }] },
  ],
}
