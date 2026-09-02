import { redirect } from 'next/navigation'
import { cookies } from 'next/headers'
import { Screen, Empty } from '@/components/ui'
import { NotReady } from '@/components/not-ready'
import { verifySession } from '@/lib/auth/dal'
import { authEnabled } from '@/lib/auth/supabase'
import { tryDb } from '@/lib/db/optional'
import { isRegistered } from '@/lib/auth/signup'
import { INVITE_COOKIE } from '@/lib/auth/cookie'
import { ProfileForm } from './form'

export const dynamic = 'force-dynamic'

/**
 * 登録の最後（生年月日と同意）
 *
 * 仕様: docs/03 §7 手順3-4 / docs/10 §5
 *
 * ★ 16歳未満はここで断る（作者判断・2026-09-02）。
 *   当初の仕様（docs/10 §5.3）は保護者の同意を取る流れだった。
 */
export default async function ProfilePage() {
  if (!authEnabled()) {
    return (
      <Screen title="登録">
        <Empty><p className="lv-body">認証が設定されていません。</p></Empty>
      </Screen>
    )
  }

  const session = await verifySession()
  if (!session) redirect('/invite')

  const db = tryDb()
  if (!db) {
    return (
      <Screen title="登録">
        <NotReady />
      </Screen>
    )
  }

  if (await isRegistered(db, session.userId)) redirect('/')

  // 招待コードを通っていない人はここまで来られない（G1）
  if (!(await cookies()).get(INVITE_COOKIE)?.value) redirect('/invite')

  return (
    <Screen title="登録">
      <div className="hs-stack">
        <p className="lv-body">最後に、いくつか確認させてください。</p>
        <ProfileForm email={session.email} />
      </div>
    </Screen>
  )
}
