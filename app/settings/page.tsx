import Link from 'next/link'
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
import { hasDiagnostic } from '@/lib/loop/diagnostic'

export const dynamic = 'force-dynamic'

/**
 * 設定（docs/11-ux.md §10 の画面12）
 *
 * ★ 主要タブには入れない。デスクトップはサイドバーの「アカウント」から入る。
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

  const [[u], tookDiagnostic] = await Promise.all([
    db<{
      max_daily_items: number; display_name: string | null; remind_hour: number | null
    }[]>`
      SELECT max_daily_items, display_name, remind_hour FROM app_user WHERE id = ${userId}`,
    hasDiagnostic(db, userId),
  ])

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

      <Card>
        <span className="lv-label">診断テスト</span>
        {tookDiagnostic ? (
          <>
            <p className="lv-caption">診断結果の確認と、必要なときの受け直しができます。</p>
            <Link className="lv-btn lv-btn--block" href="/diagnostic/result">結果を見る</Link>
            <Link className="lv-btn lv-btn--block" href="/diagnostic">受け直す</Link>
          </>
        ) : (
          <>
            <p className="lv-caption">最大24問・10分ほど。点数は付きません。</p>
            <Link className="lv-btn lv-btn--block" href="/diagnostic">診断テストを受ける</Link>
          </>
        )}
      </Card>

      {/* ★ 管理画面への入口。主要タブには足さず、作者以外にはこの行ごと出さない */}
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
          オフラインで読めるように、読んだ教材と最後に見た教科書をこの端末に保存しています。
          出題と確認テストは保存していません（正解を端末に置かないため）。
          ログアウトすると保存したものは消えます。
        </p>
      </Card>
    </Screen>
  )
}
