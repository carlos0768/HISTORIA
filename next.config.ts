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
          {
            key: 'Content-Security-Policy',
            value: [
              "default-src 'self'",
              "frame-src https://www.youtube-nocookie.com",
              "img-src 'self' data: https://i.ytimg.com",
              "style-src 'self' 'unsafe-inline'",
              "font-src 'self' data:",
              "object-src 'none'",
              "base-uri 'self'",
              "form-action 'self'",
            ].join('; '),
          },
        ],
      },
    ]
  },
}

export default nextConfig
