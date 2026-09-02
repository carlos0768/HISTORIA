import 'server-only'
import { cookies } from 'next/headers'
import { authEnv, createAuthClient } from './supabase'

/**
 * cookie を書ける Supabase クライアント。
 *
 * ★ Server Action と Route Handler からしか使えない。
 *   Server Component からは cookie を書けないので、読むだけの
 *   `lib/auth/dal.ts` の readOnlyStore とは別物である。
 *
 * ★ もとは app/(auth)/actions.ts の中の private な関数だった。
 *   設定画面のログアウトと退会でも要るので、ここへ出した。
 *   'use server' のファイルは async 関数しか export できないため、
 *   この手の道具は lib 側に置く（docs/12 §10.4 と同じ理由）。
 */
export async function clientWithCookies() {
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
