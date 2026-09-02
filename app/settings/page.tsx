import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { authEnabled } from '@/lib/auth/supabase'
import { DEFAULT_MAX_DAILY } from '@/lib/domain/scheduler'
import { Screen, Card } from '@/components/ui'
import { NotReady } from '@/components/not-ready'
import { SettingsForm } from './form'

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

  const [u] = await db<{ max_daily_items: number; display_name: string | null }[]>`
    SELECT max_daily_items, display_name FROM app_user WHERE id = ${userId}`

  return (
    <Screen title="設定" tab="settings">
      <SettingsForm
        maxDaily={u?.max_daily_items ?? DEFAULT_MAX_DAILY}
        authEnabled={authEnabled()}
      />

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
