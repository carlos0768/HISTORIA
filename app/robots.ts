import type { MetadataRoute } from 'next'

/**
 * 全面 Disallow（docs/10-legal-risk.md §3.2 G3）
 *
 * ★ 非公開・招待制のアプリなので、検索エンジンに拾わせない。
 *   noindex は app/layout.tsx の metadata で別に出している。
 *   robots.txt だけでは既に知られた URL のインデックスを防げないため、両方要る。
 */
export default function robots(): MetadataRoute.Robots {
  return {
    rules: [{ userAgent: '*', disallow: '/' }],
  }
}
