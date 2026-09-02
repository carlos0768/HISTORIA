/**
 * Supabase Auth のサーバー側クライアント
 *
 * 仕様: docs/03 §7（Supabase Auth ＋ Google ログイン、加えて招待制）
 *
 * ★ ブラウザには Supabase を触らせない。
 *   OAuth のやり取りは Route Handler の中だけで完結させる。こうすると
 *   proxy.ts の CSP（connect-src 'self'）を広げずに認証を入れられる。
 *   createBrowserClient をこのプロジェクトで使ってはいけない。
 *
 * ★ getAll と setAll は必ず両方を渡す。
 *   @supabase/ssr の注意書きが「片方だけだと、突然ログアウトする・
 *   セッションが早期に切れる・リフレッシュ要求が増える、といった
 *   原因の掴みにくい不具合になる」と名指しで警告している。
 */
import 'server-only'
import { createServerClient } from '@supabase/ssr'
import type { SupabaseClient } from '@supabase/supabase-js'

export type AuthEnv = { url: string; anonKey: string }

/**
 * 環境変数が揃っているかを返す。
 *
 * ★ 揃っていなくても落とさない。lib/db/optional.ts の tryDb() と同じ作法である。
 *   DB も鍵も無い Vercel のプレビューで全ページが 404 になると、
 *   意匠の確認ができなくなる（docs/11b の検証がプレビュー頼み）。
 */
export function authEnv(): AuthEnv | null {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL
  const anonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY
  if (!url || !anonKey) return null
  return { url, anonKey }
}

/** 認証を有効にするか。環境変数が無ければ関門ごと素通りさせる */
export const authEnabled = (): boolean => authEnv() !== null

export type CookieRecord = { name: string; value: string }
export type CookieToSet = CookieRecord & { options?: Record<string, unknown> }

/**
 * cookie の読み書きだけを外から差し替えられるようにしてある。
 * Server Component / Route Handler / proxy で cookie の触り方が違うためである。
 */
export type CookieStore = {
  getAll(): CookieRecord[]
  setAll(cookies: CookieToSet[]): void
}

/**
 * リクエストごとに新しく作る。**使い回してはいけない**。
 * @supabase/ssr が「サーバー描画のたびに作り、リクエストをまたいで共有しない」と定めている。
 */
export function createAuthClient(env: AuthEnv, store: CookieStore): SupabaseClient {
  return createServerClient(env.url, env.anonKey, {
    cookies: {
      getAll: () => store.getAll(),
      setAll: (cookies) => store.setAll(cookies as CookieToSet[]),
    },
  })
}
