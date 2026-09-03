import 'server-only'
import webpush from 'web-push'
import { vapidKeys } from './vapid'
import type { PushTarget, Notification } from '@/lib/loop/remind'

/**
 * Web Push の実際の送信（docs/12-nonfunctional.md §10）
 *
 * ★ ここだけが web-push に触る。lib/loop/remind.ts は送信手段を引数で受け取るので、
 *   条件の試験は偽の送信器で回せる（ネットワークに出ない）。
 *
 * ★ 本文は暗号化されて配信元（FCM など）を通る。配信元は中身を読めないが、
 *   **誰がいつ通知を受けたかは見える**。だから本文に学習内容を書かない。
 *   「復習が N 件あります」までにとどめ、単元名も設問も入れない。
 */

/** 送信の結果。gone = その購読先はもう存在しない（行を消してよい） */
export type SendResult = { ok: boolean; gone?: boolean }

/**
 * 1件送る。
 *
 * ★ 例外を投げない。1台の端末の失敗で、その夜の配信が全部止まるのは筋が悪い。
 *   呼び出し側（sendReminders）が件数として数える。
 */
export async function sendPush(target: PushTarget, payload: Notification): Promise<SendResult> {
  const keys = vapidKeys()
  if (!keys) return { ok: false }

  webpush.setVapidDetails(keys.subject, keys.publicKey, keys.privateKey)
  try {
    await webpush.sendNotification(
      { endpoint: target.endpoint, keys: { p256dh: target.p256dh, auth: target.auth } },
      JSON.stringify(payload),
      { TTL: 6 * 60 * 60 },   // 6時間。翌朝まで残しても、その通知はもう意味を持たない
    )
    return { ok: true }
  } catch (e) {
    // 404 = そんな購読先は無い / 410 = もう失効した。どちらも行を消す合図
    const status = (e as { statusCode?: number }).statusCode
    return { ok: false, gone: status === 404 || status === 410 }
  }
}
