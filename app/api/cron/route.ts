import { NextResponse, type NextRequest } from 'next/server'
import { tryDb } from '@/lib/db/optional'
import { sendReminders } from '@/lib/loop/remind'
import { sendPush } from '@/lib/push/send'
import { pushEnabled } from '@/lib/push/vapid'
import { reapStaleReservations, periodOf } from '@/lib/ai/budget'
import { cronAuthorized } from '@/lib/push/cron-auth'

/**
 * 定時実行（docs/12-nonfunctional.md §10・:172）
 *
 * Vercel Cron から1日1回叩かれる。やることは2つ:
 *   1. その日まだ何もしていない人にリマインドを送る（docs/11 §7）
 *   2. 取り残された予約を解放する（lib/ai/budget.ts の reapStaleReservations）
 *
 * ★ 2 は実装だけ在って**呼び出し元が無かった**。生成の途中で落ちた予約が
 *   reserved のまま残ると、その月の予算がじりじり食われて、最後は
 *   何も生成できなくなる。定時実行はその掃除に一番向いている。
 *
 * ★ 実行のたびに ops_log に残す（docs/12:172「24時間無ければ警告」）。
 *   失敗しても残す。「動いて失敗した」と「そもそも動いていない」は別の障害で、
 *   記録が無ければ後者に気づけない。
 *
 * ────────────────────────────────────────────────
 * なぜ Node ランタイムか
 *   web-push は VAPID の署名（ECDSA P-256）と本文の暗号化に node:crypto を使う。
 *   Edge ランタイムでは動かない。
 * ────────────────────────────────────────────────
 */
export const runtime = 'nodejs'
export const dynamic = 'force-dynamic'

type LogKind = 'remind' | 'reap_reservations'

export async function GET(req: NextRequest) {
  // ★ 確認の中身は lib/push/cron-auth.ts に置いてある（試験できるように）。
  //   既定は閉で、CRON_SECRET が未設定なら誰も通さない
  if (!await cronAuthorized(req.headers.get('authorization'), process.env.CRON_SECRET)) {
    // ★ 401 ではなく 404。docs/10 G2 と同じで、経路の存在自体を見せない
    return new NextResponse(null, { status: 404 })
  }

  const db = tryDb()
  if (!db) return NextResponse.json({ ok: false, reason: 'no_database' }, { status: 503 })

  const now = new Date()
  const log = async (kind: LogKind, ok: boolean, detail: unknown) => {
    await db`INSERT INTO ops_log (kind, ok, detail, ran_at)
             VALUES (${kind}, ${ok}, ${db.json(detail as never)}, ${now})`
  }

  const results: Record<string, unknown> = {}

  // 1. リマインド。鍵が無ければ「送らなかった」として記録する（失敗にはしない）
  try {
    if (!pushEnabled()) {
      results.remind = { skipped: 'no_vapid_keys' }
      await log('remind', true, results.remind)
    } else {
      const r = await sendReminders(db, now, sendPush)
      results.remind = r
      // ★ 1件でも送信に失敗したら ok=false にする。数が残るので原因は追える
      await log('remind', r.failed === 0, r)
    }
  } catch (e) {
    results.remind = { error: String(e) }
    await log('remind', false, results.remind)
  }

  // 2. 取り残された予約の解放
  try {
    const released = await reapStaleReservations(db, periodOf(now))
    results.reap = { released }
    await log('reap_reservations', true, results.reap)
  } catch (e) {
    results.reap = { error: String(e) }
    await log('reap_reservations', false, results.reap)
  }

  return NextResponse.json({ ok: true, ran_at: now.toISOString(), ...results })
}
