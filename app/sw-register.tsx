'use client'

import { useEffect } from 'react'

/**
 * Service Worker の登録（docs/12 §10）
 *
 * ★ インラインの <script> を書かない。クライアント境界にすれば、
 *   このコンポーネントの JS は Next が nonce 付きで読み込むので、
 *   CSP の 'strict-dynamic' をそのまま通る。nonce を自分で配線する必要はない。
 *
 * ★ 失敗を握りつぶす。/sw.js は proxy の matcher に入っているので、
 *   未認証（/invite・/login）では 404 になり register が reject する。
 *   招待制の帰結であって不具合ではない。ログイン後の描画でもう一度走り、そこで登録される。
 */
export function SwRegister() {
  useEffect(() => {
    if (!('serviceWorker' in navigator)) return
    navigator.serviceWorker.register('/sw.js').catch(() => {})
  }, [])
  return null
}
