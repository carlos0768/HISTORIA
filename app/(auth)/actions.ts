'use server'

/**
 * 認証まわりの Server Action
 *
 * 仕様: docs/03 §7 / docs/10 §3.2 G1・G7 / §5
 *
 * ★ このファイルは 'use server' なので **async 関数しか export できない**。
 *   定数（cookie の名前など）は lib/auth/cookie.ts に置いてある。
 *   ここに混ぜると export が1つも無いモジュールと判定され、build が落ちる。
 */
import { cookies, headers } from 'next/headers'
import { redirect } from 'next/navigation'
import { sql } from '@/lib/db/client'
import { authEnv, createAuthClient } from '@/lib/auth/supabase'
import { checkInvite, inviteError } from '@/lib/auth/invite'
import { checkBirthDate, ageError } from '@/lib/auth/age'
import { signup } from '@/lib/auth/signup'
import { verifySession } from '@/lib/auth/dal'
import { INVITE_COOKIE, INVITE_MAX_AGE, inviteCookieOptions } from '@/lib/auth/cookie'

type ActionResult = { ok: true } | { ok: false; message: string }

/**
 * 招待コードを確かめて cookie に置く。
 *
 * ★ ここでは消し込まない。ログインを終えて生年月日まで入れた人だけが席を取る。
 *   ここで消すと、途中でやめた人のぶんだけ席が死ぬ。
 */
export async function submitInviteAction(code: string): Promise<ActionResult> {
  const db = sql()
  const r = await checkInvite(db, code, new Date())
  if (!r.ok) return { ok: false, message: inviteError(r.reason) }

  ;(await cookies()).set(INVITE_COOKIE, code.trim(), { ...inviteCookieOptions, maxAge: INVITE_MAX_AGE })
  return { ok: true }
}

/** 今のリクエストの生成元。OAuth の戻り先を組み立てるのに使う */
async function origin(): Promise<string> {
  const h = await headers()
  const host = h.get('x-forwarded-host') ?? h.get('host') ?? 'localhost:3000'
  const proto = h.get('x-forwarded-proto') ?? (host.startsWith('localhost') ? 'http' : 'https')
  return `${proto}://${host}`
}

/**
 * cookie を読み書きできる Supabase クライアント。
 * Server Action からは cookie を書けるので setAll を通す。
 */
async function clientWithCookies() {
  const env = authEnv()
  if (!env) return null
  const jar = await cookies()
  return createAuthClient(env, {
    getAll: () => jar.getAll().map(c => ({ name: c.name, value: c.value })),
    setAll: (list) => {
      for (const c of list) jar.set(c.name, c.value, c.options)
    },
  })
}

/**
 * Google の同意画面へ送る。
 *
 * ★ ブラウザから Supabase を呼ばない。ここでURLだけ作り、redirect で送る。
 *   こうすると proxy.ts の CSP（connect-src 'self'）を広げずに済む。
 */
export async function signInWithGoogleAction(): Promise<ActionResult> {
  const supabase = await clientWithCookies()
  if (!supabase) return { ok: false, message: '認証が設定されていません' }

  const { data, error } = await supabase.auth.signInWithOAuth({
    provider: 'google',
    options: { redirectTo: `${await origin()}/auth/callback` },
  })
  if (error || !data.url) return { ok: false, message: 'ログインを開始できませんでした' }
  redirect(data.url)
}

/**
 * メールにログイン用のリンクを送る。
 *
 * ★ Google の OAuth 設定が済むまでの手段として併設する（作者判断・2026-09-02）。
 *   docs/03 §7 は「メール確認の導線は離脱が大きい」として Google を主にしているので、
 *   これはあくまで予備である。
 */
export async function signInWithEmailAction(email: string): Promise<ActionResult> {
  const supabase = await clientWithCookies()
  if (!supabase) return { ok: false, message: '認証が設定されていません' }
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim())) {
    return { ok: false, message: 'メールアドレスの形式が正しくありません' }
  }

  const { error } = await supabase.auth.signInWithOtp({
    email: email.trim(),
    options: { emailRedirectTo: `${await origin()}/auth/callback` },
  })
  if (error) return { ok: false, message: 'メールを送れませんでした' }
  return { ok: true }
}

/**
 * 生年月日と同意を受けて登録を終える。
 *
 * ★ 16歳未満はここで断る（docs/10 §5・作者判断 2026-09-02）。
 *   当初の仕様は保護者の同意を取る流れだったが、受け付けない方に変えた。
 */
export async function completeSignupAction(input: {
  birthDate: string
  displayName?: string
  consent: boolean
}): Promise<ActionResult> {
  const session = await verifySession()
  if (!session) return { ok: false, message: 'ログインし直してください' }
  if (!input.consent) return { ok: false, message: '利用規約とプライバシーポリシーへの同意が必要です' }

  const age = checkBirthDate(input.birthDate, new Date())
  if (!age.ok) return { ok: false, message: ageError(age) }

  const jar = await cookies()
  const code = jar.get(INVITE_COOKIE)?.value
  if (!code) return { ok: false, message: '招待コードが見つかりません。最初からやり直してください' }

  const r = await signup(sql(), {
    userId: session.userId,
    code,
    birthDate: input.birthDate,
    displayName: input.displayName?.trim() || null,
  }, new Date())

  if (!r.ok) {
    if (r.kind === 'age') return { ok: false, message: ageError(r.check) }
    if (r.kind === 'invite') return { ok: false, message: inviteError(r.check.reason) }
    return { ok: false, message: '既に登録されています' }
  }

  // 使い終わった招待コードは残さない
  jar.delete(INVITE_COOKIE)
  return { ok: true }
}

/** ログアウト */
export async function signOutAction(): Promise<void> {
  const supabase = await clientWithCookies()
  if (supabase) await supabase.auth.signOut()
  redirect('/invite')
}
