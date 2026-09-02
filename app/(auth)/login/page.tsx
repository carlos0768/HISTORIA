import { cookies } from 'next/headers'
import { redirect } from 'next/navigation'
import { Screen, Empty } from '@/components/ui'
import { authEnabled } from '@/lib/auth/supabase'
import { INVITE_COOKIE } from '@/lib/auth/cookie'
import { LoginForm } from './form'

export const dynamic = 'force-dynamic'

/**
 * ログイン（docs/03 §7）
 *
 * ★ 招待コードを通っていない人はここに来られない。
 *   cookie が無ければ入口へ戻す。G1（招待コードなしにアカウントを作れない）の担保である。
 */
export default async function LoginPage() {
  if (!authEnabled()) {
    return (
      <Screen title="ログイン">
        <Empty>
          <p className="lv-body">認証が設定されていません。</p>
          <p className="lv-caption">
            <code>NEXT_PUBLIC_SUPABASE_URL</code> と
            <code> NEXT_PUBLIC_SUPABASE_ANON_KEY</code> が要ります。
          </p>
        </Empty>
      </Screen>
    )
  }

  const code = (await cookies()).get(INVITE_COOKIE)?.value
  if (!code) redirect('/invite')

  return (
    <Screen title="ログイン">
      <div className="hs-stack">
        <p className="lv-body">招待コードを確認しました。ログインしてください。</p>
        <LoginForm />
      </div>
    </Screen>
  )
}
