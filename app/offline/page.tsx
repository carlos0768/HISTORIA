import Link from 'next/link'
import { Screen, Card } from '@/components/ui'

/**
 * オフラインのときの行き先（docs/12 §10）
 *
 * ★ force-dynamic にする。CSP が 'strict-dynamic' + nonce なので、
 *   ビルド時に生成した静的ページには nonce が入らず、
 *   自分のスクリプトが CSP に弾かれてハイドレーションが起きない。
 *   Service Worker はこの応答をそのまま（CSP ヘッダごと）保存するので、
 *   キャッシュから出しても nonce とヘッダの対応は保たれる。
 *
 * ★ ここで「解けます」と言わない。オフラインでは出題しない。理由は sw.js に書いた。
 */
export const dynamic = 'force-dynamic'

export default function Offline() {
  return (
    <Screen title="オフライン">
      <Card>
        <span className="lv-label">通信できていません</span>
        <p className="lv-body">
          電波が戻ると、いつもどおり使えます。
        </p>
        <p className="lv-caption">
          読んだことのある教材と、最後に見た記録は、オフラインでも開けます。
          出題だけは電波が要ります（採点をサーバーで行うため、
          正解を端末に置かない設計にしています）。
        </p>
      </Card>

      <Card>
        <span className="lv-label">いま開けるもの</span>
        <Link className="lv-btn lv-btn--block" href="/records">記録を見る</Link>
        <Link className="lv-btn lv-btn--block" href="/">もう一度ためす</Link>
      </Card>
    </Screen>
  )
}
