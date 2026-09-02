'use server'

import { redirect } from 'next/navigation'
import { revalidatePath } from 'next/cache'
import { sql } from '@/lib/db/client'
import { currentUserId } from '@/lib/auth/dal'
import { clientWithCookies } from '@/lib/auth/server'
import { deleteUserData, describeDeleted, DELETE_CONFIRMATION } from '@/lib/auth/account'
import { MAX_DAILY_MIN, MAX_DAILY_MAX } from '@/lib/domain/scheduler'
import { REMIND_HOUR_MIN, REMIND_HOUR_MAX } from '@/lib/loop/remind'

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

/**
 * 通知の購読を登録する（docs/11-ux.md §7）
 *
 * ★ endpoint はブラウザが発行する一意な URL で、それが主キーである。
 *   同じ端末で許可し直すと同じ endpoint が返るので upsert にする。
 *   別の端末なら別の行になる（携帯と机の両方に届く）。
 *
 * ★ RLS に INSERT ポリシーを置いていない（seed/sql/03_rls.sql）。
 *   購読先を他人の user_id で偽装されると、その人あての通知を横取りできる。
 *   書き込みは必ずここを通す（Server Action は service_role で走る）。
 */
export async function subscribePush(input: {
  endpoint: string
  p256dh: string
  auth: string
  remindHour: number
}): Promise<{ ok: boolean; message: string }> {
  const userId = await currentUserId()
  if (!userId) return { ok: false, message: 'ユーザーが特定できません' }
  if (!/^https:\/\//.test(input.endpoint)) {
    return { ok: false, message: '購読先が正しくありません' }
  }
  if (!Number.isInteger(input.remindHour)
      || input.remindHour < REMIND_HOUR_MIN || input.remindHour > REMIND_HOUR_MAX) {
    return { ok: false, message: `通知の時刻は ${REMIND_HOUR_MIN}〜${REMIND_HOUR_MAX} 時で選んでください` }
  }

  const db = sql()
  await db.begin(async tx => {
    await tx`
      INSERT INTO push_subscription (endpoint, user_id, p256dh, auth)
      VALUES (${input.endpoint}, ${userId}, ${input.p256dh}, ${input.auth})
      ON CONFLICT (endpoint) DO UPDATE SET
        user_id = EXCLUDED.user_id, p256dh = EXCLUDED.p256dh, auth = EXCLUDED.auth,
        -- ★ last_sent_at は消す。端末が変わったのに「今日はもう送った」が
        --   残っていると、その日の通知が届かない
        last_sent_at = NULL`
    await tx`UPDATE app_user SET remind_hour = ${input.remindHour} WHERE id = ${userId}`
  })
  revalidatePath('/settings')
  return { ok: true, message: `${input.remindHour} 時以降に通知します` }
}

/**
 * 通知をやめる。
 *
 * ★ 購読先の行を消すだけでなく `remind_hour` も NULL に戻す。
 *   行だけ消して時刻を残すと、別の端末で許可し直したときに
 *   「切ったはずなのに来る」ことになる。
 */
export async function unsubscribePush(endpoint: string | null): Promise<{ ok: boolean; message: string }> {
  const userId = await currentUserId()
  if (!userId) return { ok: false, message: 'ユーザーが特定できません' }
  const db = sql()
  await db.begin(async tx => {
    if (endpoint) {
      // ★ user_id で絞る。endpoint だけで消せると、他人の購読を消せる
      await tx`DELETE FROM push_subscription WHERE endpoint = ${endpoint} AND user_id = ${userId}`
    }
    await tx`UPDATE app_user SET remind_hour = NULL WHERE id = ${userId}`
  })
  revalidatePath('/settings')
  return { ok: true, message: '通知を止めました' }
}
