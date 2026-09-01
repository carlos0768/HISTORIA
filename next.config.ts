import type { NextConfig } from 'next'

const nextConfig: NextConfig = {
  reactStrictMode: true,
  // 10-legal-risk.md §3.2 G3: 非公開・招待制。検索エンジンに載せない。
  // 12-nonfunctional.md §6: YouTube は nocookie ドメインのみ許可する。
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          { key: 'X-Robots-Tag', value: 'noindex, nofollow, noarchive' },
          { key: 'Referrer-Policy', value: 'strict-origin-when-cross-origin' },
          { key: 'X-Content-Type-Options', value: 'nosniff' },
          // CSP は middleware.ts が nonce 付きで配る。ここには置かない（二重定義にしない）
        ],
      },
    ]
  },
}

export default nextConfig
