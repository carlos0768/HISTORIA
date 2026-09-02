import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { authEnabled } from '@/lib/auth/supabase'
import { DEFAULT_MAX_DAILY } from '@/lib/domain/scheduler'
import { Screen, Card } from '@/components/ui'
import { NotReady } from '@/components/not-ready'
import { SettingsForm } from './form'
import { PushToggle } from '@/components/push-toggle'
import { publicVapidKey } from '@/lib/push/vapid'
import { subscribePush, unsubscribePush } from './actions'
import { isAdmin } from '@/lib/auth/admin'

export const dynamic = 'force-dynamic'

/**
 * 設定（docs/11-ux.md §10 の画面12）
 *
 * ★ タブには入れない。docs/11 §9 が3タブと定めているので、
 *   デスクトップはサイドバーの「アカウント」から、モバイルは記録タブの末尾から入る。
 */
export default async function Settings() {
  const db = tryDb()
  const userId = await currentUserId()

  if (!db || !userId) {
    return (
      <Screen title="設定" tab="settings">
        <NotReady />
      </Screen>
    )
  }

  const [u] = await db<{
    max_daily_items: number; display_name: string | null; remind_hour: number | null
  }[]>`
    SELECT max_daily_items, display_name, remind_hour FROM app_user WHERE id = ${userId}`

  // ★ 鍵が無ければ通知の枠ごと出さない（lib/push/vapid.ts の作法）。
  //   「押しても何も起きないボタン」を置かない
  const vapid = publicVapidKey()

  return (
    <Screen title="設定" tab="settings">
      <SettingsForm
        maxDaily={u?.max_daily_items ?? DEFAULT_MAX_DAILY}
        authEnabled={authEnabled()}
      />

      {vapid && (
        <PushToggle
          vapidPublicKey={vapid}
          remindHour={u?.remind_hour ?? null}
          subscribe={subscribePush}
          unsubscribe={unsubscribePush}
        />
      )}

      {/* ★ 管理画面への入口。タブには足さない（components/nav.test.ts が3タブを固定しており、
           あれは「増やすな」という意図の防壁である）。作者以外にはこの行ごと出ない */}
      {isAdmin(userId) && (
        <Card>
          <span className="lv-label">管理</span>
          <p className="lv-caption">生成の状況・支出・未処理の報告・定時実行の生存。</p>
          <a className="lv-btn lv-btn--block" href="/admin">管理画面をひらく</a>
        </Card>
      )}

      <Card>
        <span className="lv-label">この端末に残っているもの</span>
        <p className="lv-caption">
          オフラインで読めるように、読んだ教材と最後に見た記録をこの端末に保存しています。
          出題と確認テストは保存していません（正解を端末に置かないため）。
          ログアウトすると保存したものは消えます。
        </p>
      </Card>
    </Screen>
  )
}
