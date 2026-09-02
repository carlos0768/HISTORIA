import { Screen } from '@/components/ui'
import { InviteForm } from './form'

export const dynamic = 'force-dynamic'

/**
 * 招待コードの入力（docs/10 G1）
 *
 * ★ ここは未認証でも開ける数少ない画面である。
 *   他は proxy.ts が 404 を返す（G2）。招待された人はこの URL を直接渡される。
 */
export default function InvitePage() {
  return (
    <Screen title="HISTORIA">
      <div className="hs-stack">
        <p className="lv-body">
          このアプリは招待制です。受け取った招待コードを入れてください。
        </p>
        <InviteForm />
      </div>
    </Screen>
  )
}
