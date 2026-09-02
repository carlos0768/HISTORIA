/**
 * 学習のリマインド（docs/11-ux.md §7・docs/12-nonfunctional.md §10）
 *
 * ★ 送る相手は「**今日まだ何もしていない人**」だけである。
 *   もう解いた人に「やりましょう」と送ると、通知が読まれなくなる。
 *   一度そうなると、本当に必要な日の通知も無視されるので、機能ごと死ぬ。
 *
 * ★ 1日1通まで。同じ人の端末が複数あっても、送るのは1回ぶんの内容を全端末へで、
 *   「携帯にも机にも別々の催促が来る」ことにはしない。
 *
 * ────────────────────────────────────────────────
 * cron の回数という制約について（正直に書く）
 *
 * Vercel の Hobby では cron は**1日1回**しか起動しない。
 * そのため「通知時刻」を人ごとに持っていても、実際に配信できる時刻は1つである。
 * ここでは remind_hour を「**この時刻以降なら送ってよい**」と解釈する:
 *
 *   - cron は日本時間 REMIND_CRON_HOUR_JST 時に1回だけ走る
 *   - remind_hour <= その時刻 の人に送る
 *   - 設定画面は REMIND_HOUR_MAX までしか選ばせない（届かない時刻を選ばせない）
 *
 * 有料プランに上げて cron を毎時にすると、**コードは1行も変えずに**
 * remind_hour どおりの時刻に届くようになる（条件が「以降」なので、
 * その人の時刻に達した最初の起動で送られ、1日1通の制限が二重送信を防ぐ）。
 * ────────────────────────────────────────────────
 */
import type { Sql } from 'postgres'
import { jstDate, jstHour, jstDayStart } from '@/lib/domain/jst'

/**
 * cron が走る日本時間の時刻。
 * ★ vercel.json の `crons` と一致していること。ずれを試験で検出する
 *   （lib/loop/remind.test.ts）。片方だけ直すと通知が届かなくなる。
 */
export const REMIND_CRON_HOUR_JST = 20

/** 設定画面で選ばせる範囲。上限は cron の時刻（それより後は届かない） */
export const REMIND_HOUR_MIN = 6
export const REMIND_HOUR_MAX = REMIND_CRON_HOUR_JST

export type PushTarget = {
  endpoint: string
  p256dh: string
  auth: string
}

export type RemindTarget = {
  userId: string
  displayName: string | null
  /** 期限が来ている枚数。本文に入れる */
  dueCount: number
  subscriptions: PushTarget[]
}

/**
 * 今この瞬間に送るべき相手を出す。
 *
 * ★ 「送るかどうか」の判断を全部 SQL に置く。ここを JS で書くと、
 *   条件が増えたときに「読み込んでから落とす」形になり、
 *   利用者が増えたときに全員ぶんの購読先をメモリに載せることになる。
 */
export async function remindTargets(db: Sql, now: Date): Promise<RemindTarget[]> {
  const today = jstDate(now)
  const hour = jstHour(now)
  const dayStart = jstDayStart(today)

  const rows = await db<{
    user_id: string; display_name: string | null; due_count: string
    endpoint: string; p256dh: string; auth: string
  }[]>`
    SELECT u.id AS user_id, u.display_name,
           (SELECT count(*) FROM kc_card c
             WHERE c.user_id = u.id AND NOT c.suspended AND c.due_at <= ${now}) AS due_count,
           s.endpoint, s.p256dh, s.auth
      FROM app_user u
      JOIN push_subscription s ON s.user_id = u.id
     WHERE u.remind_hour IS NOT NULL
       AND u.remind_hour <= ${hour}
       -- 今日もう学習した人には送らない（1問でも解いた・1節でも読んだ）
       AND NOT EXISTS (
             SELECT 1 FROM user_activity a
              WHERE a.user_id = u.id AND a.activity_date = ${today})
       -- 今日もう送った人には送らない（端末が複数でも1日1通）
       AND NOT EXISTS (
             SELECT 1 FROM push_subscription s2
              WHERE s2.user_id = u.id AND s2.last_sent_at >= ${dayStart})
     ORDER BY u.id, s.endpoint`

  const byUser = new Map<string, RemindTarget>()
  for (const r of rows) {
    let t = byUser.get(r.user_id)
    if (!t) {
      t = {
        userId: r.user_id, displayName: r.display_name,
        dueCount: Number(r.due_count), subscriptions: [],
      }
      byUser.set(r.user_id, t)
    }
    t.subscriptions.push({ endpoint: r.endpoint, p256dh: r.p256dh, auth: r.auth })
  }
  return [...byUser.values()]
}

export type Notification = { title: string; body: string; url: string }

/**
 * 本文を作る。
 *
 * ★ 数を出す。「勉強しましょう」だけの通知は情報量が0で、
 *   2日目には見られなくなる。「何問あるのか」は開く判断に使える。
 * ★ 急かさない。0件なら「今日はここまでで大丈夫です」ではなく、
 *   そもそも**送らない**（呼び出し側が dueCount 0 を落とす）。
 */
export function remindMessage(t: RemindTarget): Notification {
  return {
    title: 'HISTORIA',
    body: t.dueCount > 0
      ? `今日の復習が ${t.dueCount} 件あります。5分でひと区切りつきます。`
      : '今日はまだ1問も解いていません。1問だけでも連続は途切れません。',
    url: '/study',
  }
}

/** 送信結果。ops_log に入れる */
export type RemindResult = {
  users: number
  sent: number
  failed: number
  /** 期限切れの購読先として消した件数 */
  pruned: number
}

/**
 * 送信そのもの。
 *
 * ★ 送る手段を引数で受け取る（依存性の注入）。理由は2つある。
 *   1つは web-push が実際にネットワークへ出るため、試験で偽物に差し替えたいこと。
 *   もう1つは、送信の可否を判断する条件（上の SQL）こそが壊れやすい部分で、
 *   そこを実 DB で試験したいこと。
 *
 * ★ 404 / 410 は「その購読先はもう無い」の意味なので**行を消す**。
 *   消さないと、機種変更のたびに死んだ購読先が溜まり、
 *   毎晩そこへ送ろうとして失敗し続ける。
 */
export async function sendReminders(
  db: Sql,
  now: Date,
  send: (target: PushTarget, payload: Notification) => Promise<{ ok: boolean; gone?: boolean }>,
): Promise<RemindResult> {
  const targets = await remindTargets(db, now)
  let sent = 0, failed = 0, pruned = 0

  for (const t of targets) {
    const payload = remindMessage(t)
    const delivered: string[] = []
    for (const s of t.subscriptions) {
      const r = await send(s, payload)
      if (r.ok) { sent++; delivered.push(s.endpoint); continue }
      failed++
      if (r.gone) {
        await db`DELETE FROM push_subscription WHERE endpoint = ${s.endpoint}`
        pruned++
      }
    }
    // ★ 1つでも届いた端末があるときだけ「今日は送った」と記録する。
    //   全滅した人は翌日また対象になる（黙って諦めない）
    if (delivered.length > 0) {
      await db`
        UPDATE push_subscription SET last_sent_at = ${now}
         WHERE endpoint IN ${db(delivered)}`
    }
  }
  return { users: targets.length, sent, failed, pruned }
}
