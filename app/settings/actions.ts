'use server'

import { redirect } from 'next/navigation'
import { revalidatePath } from 'next/cache'
import { sql } from '@/lib/db/client'
import { currentUserId } from '@/lib/auth/dal'
import { clientWithCookies } from '@/lib/auth/server'
import { deleteUserData, describeDeleted, DELETE_CONFIRMATION } from '@/lib/auth/account'
import { MAX_DAILY_MIN, MAX_DAILY_MAX } from '@/lib/domain/scheduler'

/**
 * 1日の上限を変える（docs/05-scheduler.md §9.1）
 *
 * ★ 上限は利用者自身が動かせる。動かせないと、試験前に増やす・部活で減らす
 *   といった当たり前の調整ができず、達成不能の警告だけが出続ける。
 */
export async function setMaxDaily(n: number): Promise<{ ok: boolean; message: string }> {
  const userId = await currentUserId()
  if (!userId) return { ok: false, message: 'ユーザーが特定できません' }
  if (!Number.isInteger(n) || n < MAX_DAILY_MIN || n > MAX_DAILY_MAX) {
    return { ok: false, message: `${MAX_DAILY_MIN}〜${MAX_DAILY_MAX} の範囲で指定してください` }
  }
  await sql()`UPDATE app_user SET max_daily_items = ${n} WHERE id = ${userId}`
  revalidatePath('/')
  revalidatePath('/settings')
  return { ok: true, message: `1日の上限を ${n} 問にしました` }
}

/**
 * アカウントと学習データを全部消す（docs/10-legal-risk.md §5.4）
 *
 * ★ ここは関門だけを持つ。実際に消すのは lib/auth/account.ts で、
 *   実 DB の試験から呼べるようにしてある。
 */
export async function deleteAccount(
  confirmation: string,
): Promise<{ ok: boolean; message: string }> {
  const userId = await currentUserId()
  if (!userId) return { ok: false, message: 'ユーザーが特定できません' }
  if (confirmation !== DELETE_CONFIRMATION) {
    return { ok: false, message: `「${DELETE_CONFIRMATION}」と入力してください` }
  }

  const counts = await deleteUserData(sql(), userId)

  // 認証側の session も落とす。DB から消えても cookie が残ると、
  // 次の要求で「利用者はいるがデータが無い」という中途半端な状態になる
  const supabase = await clientWithCookies()
  if (supabase) await supabase.auth.signOut()

  redirect(`/invite?deleted=${encodeURIComponent(describeDeleted(counts))}`)
}
