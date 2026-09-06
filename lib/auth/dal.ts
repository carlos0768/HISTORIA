/**
 * 認証のデータアクセス層（DAL）
 *
 * 仕様: docs/03 §7 / docs/10 §5・G2
 * 作法: node_modules/next/dist/docs/01-app/02-guides/authentication.md §Authorization
 *
 * ★ 本当の防御はここに置く。proxy.ts の関門は「楽観的な確認」でしかない。
 *   Next の作法書が「proxy は最初の確認には使えるが、唯一の防御にしてはいけない。
 *   検査はデータ源のできるだけ近くで行う」と定めている。
 *
 * ★ currentUserId() が利用者を特定する唯一の入口である。
 *   以前あった demoUserId()（環境変数から1人返すだけのもの）は廃止した。
 *   画面と Server Action は必ずここを通す。
 */
import 'server-only'
import { cache } from 'react'
import { cookies } from 'next/headers'
import { authEnv, createAuthClient, type CookieToSet } from './supabase'

export type Session = {
  /** auth.users.id と同じ uuid。app_user.id もこれに合わせる（schema.sql §3 のコメント） */
  userId: string
  email: string | null
}

/**
 * cookie を読むだけの入れ物。
 *
 * ★ Server Component からは cookie を書けない（Next の制約）。
 *   書き込みは proxy.ts と Route Handler が受け持つので、ここでは捨てる。
 *   @supabase/ssr はこの構成を想定しており、書けない場でも setAll は渡しておく。
 */
async function readOnlyStore() {
  const jar = await cookies()
  return {
    getAll: () => jar.getAll().map(c => ({ name: c.name, value: c.value })),
    setAll: (_: CookieToSet[]) => { /* Server Component からは書けない。proxy が書く */ },
  }
}

/**
 * ログインしている利用者を返す。していなければ null。
 *
 * ★ getSession() ではなく getClaims() を使う。
 *   getSession() は cookie を読むだけで署名を検証しないため、サーバー側で信用してはいけない。
 *   getClaims() は JWT の署名を公開鍵（JWKS）で検証してから claims を返す。
 *
 * ★ getUser() から getClaims() に替えた理由は速さである。
 *   getUser() は**画面を描くたび・Server Action を呼ぶたび**に認証サーバーへ往復していた。
 *   proxy.ts でも同じ往復をしていたので、1 回の遷移で 2 往復、
 *   出題では 1 問答えるごとに 1 往復ぶん待たされていた。
 *   getClaims() は署名をその場で検証する。JWKS は @supabase/auth-js が
 *   プロセス全体で 10 分キャッシュするので、往復は 10 分に 1 回で済む。
 *   鍵が対称（旧来の HS256）なら getUser() に自動で落ちるので、正しさは変わらない。
 *
 * ★ React の cache() で1回の描画のあいだ記憶する。
 *   1画面から何度呼んでも検証は1回で済む。
 */
export const verifySession = cache(async (): Promise<Session | null> => {
  const env = authEnv()
  if (!env) return null              // 環境変数が無い＝認証を使わない構成
  const supabase = createAuthClient(env, await readOnlyStore())
  const { data, error } = await supabase.auth.getClaims()
  if (error || !data) return null
  const { sub, email } = data.claims
  if (typeof sub !== 'string' || sub === '') return null
  return { userId: sub, email: typeof email === 'string' ? email : null }
})

/**
 * 画面と Server Action が使う入口。
 *
 * ★ 認証が無効な構成（環境変数が無い）では DEMO_USER_ID を返す。
 *   これは開発とプレビューのための逃げ道であり、
 *   NEXT_PUBLIC_SUPABASE_URL を設定した瞬間に効かなくなる。
 *   本番で誤って有効にならないよう、authEnv() が優先である。
 */
export async function currentUserId(): Promise<string | null> {
  const env = authEnv()
  if (!env) return process.env.DEMO_USER_ID ?? null
  return (await verifySession())?.userId ?? null
}
