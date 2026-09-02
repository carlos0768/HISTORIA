import type { MetadataRoute } from 'next'

/**
 * Web App Manifest（docs/12-nonfunctional.md §10）
 *
 * ★ 未認証では 404 になる。manifest も proxy の matcher に入っているので、
 *   招待されていない人が「ホーム画面に追加」しても中身は取れない（docs/10 G2）。
 *   これは不具合ではなく、非公開・招待制の帰結である。
 *
 * ★ robots の noindex と両立する（docs/10 G3）。manifest は検索とは無関係で、
 *   インストールの見た目だけを決める。
 */
export default function manifest(): MetadataRoute.Manifest {
  return {
    name: 'HISTORIA',
    short_name: 'HISTORIA',
    description: '受験世界史の弱点を測って、そこだけを出し直す',
    lang: 'ja',
    start_url: '/',
    scope: '/',
    // ブラウザの chrome を消す。フッタの3タブが下端に来るので、
    // アドレスバーの分だけ縦が稼げる（docs/11 §9）
    display: 'standalone',
    orientation: 'portrait',
    background_color: '#FCF6E8', // 紙
    theme_color: '#FCF6E8',
    icons: [
      { src: '/icon-192.png', sizes: '192x192', type: 'image/png', purpose: 'any' },
      { src: '/icon-512.png', sizes: '512x512', type: 'image/png', purpose: 'any' },
      // ★ maskable は別に作る。Android は円や角丸に切り抜くので、
      //   同じ絵を使い回すと枠線と字が切り落とされる（安全域は約20%）
      { src: '/icon-maskable-512.png', sizes: '512x512', type: 'image/png', purpose: 'maskable' },
    ],
  }
}
