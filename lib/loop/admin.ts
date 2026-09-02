/**
 * 管理ビューが読むもの（docs/12-nonfunctional.md §7.1）
 *
 * ★ 利用者向けの機能ではない。作者ひとりが「いま何が壊れているか」を
 *   1画面で見るためのものである。
 *
 * ★ 集計は全部ここに置く。画面（app/admin/page.tsx）には SQL を書かない。
 *   実 DB の試験から呼べる形にしておかないと、この画面だけ検証されないまま残る。
 *
 * ★ 誰が管理者かはここでは決めない。関門は app/admin/page.tsx が持つ
 *   （lib/auth/admin.ts）。集計そのものは誰が呼んでも同じ答えを返す純粋な読み取りにする。
 */
import type { Sql } from 'postgres'
import { jstDate, jstDayStart } from '@/lib/domain/jst'

/** Gemini 無料枠の1日あたりリクエスト数（docs/08 §2 の表） */
export const RPD_LIMIT = 1500

/** cron がこれだけ音沙汰無ければ警告（docs/12:172） */
export const CRON_SILENCE_HOURS = 24

export type GenerationToday = {
  /** 当日のリクエスト数（生成ジョブの件数） */
  requests: number
  /** RPD に対する消費率（0〜1） */
  usage: number
  failed: number
  running: number
}

/**
 * 当日の生成の状況。
 *
 * ★ 日付は日本時間で切る。UTC で切ると、日本時間の朝9時に「昨日ぶん」が
 *   混ざったまま残り、消費率が実際より高く見える。
 */
export async function generationToday(db: Sql, now: Date): Promise<GenerationToday> {
  const dayStart = jstDayStart(jstDate(now))
  const [row] = await db<{ requests: string; failed: string; running: string }[]>`
    SELECT count(*)                                        AS requests,
           count(*) FILTER (WHERE status = 'failed')       AS failed,
           count(*) FILTER (WHERE status = 'running')      AS running
      FROM generation_job
     WHERE created_at >= ${dayStart}`
  const requests = Number(row?.requests ?? 0)
  return {
    requests,
    usage: requests / RPD_LIMIT,
    failed: Number(row?.failed ?? 0),
    running: Number(row?.running ?? 0),
  }
}

export type BlockedMaterial = {
  id: string
  unitId: string
  reason: string | null
  createdAt: Date
}

/** 配信できなかった教材（docs/12 §7.1）。ここが増え続けるなら層3が厳しすぎる */
export async function blockedMaterials(db: Sql, limit = 30): Promise<BlockedMaterial[]> {
  // ★ 列名は generated_at。material に created_at は無い（docs/schema.sql）
  const rows = await db<{
    id: string; unit_id: string; blocked_reason: string | null; generated_at: Date
  }[]>`
    SELECT id, unit_id, blocked_reason, generated_at
      FROM material WHERE status = 'blocked'
     ORDER BY generated_at DESC LIMIT ${limit}`
  return rows.map(r => ({
    id: String(r.id), unitId: r.unit_id,
    reason: r.blocked_reason === null ? null : r.blocked_reason.slice(0, 200),
    createdAt: r.generated_at,
  }))
}

export type SpendByPurpose = {
  purpose: string
  /** 予約中（まだ確定していない） */
  reservedJpy: number
  /** 確定した実額 */
  settledJpy: number
  count: number
}

/**
 * 当月の支出を purpose 別に出す（docs/12 §7.1）。
 *
 * ★ released は数えない。解放された予約は「使わなかった」ものである。
 * ★ 確定分は actual_jpy を使う。est_jpy は上限額なので、実額より必ず大きい。
 */
export async function spendByPurpose(db: Sql, period: string): Promise<SpendByPurpose[]> {
  const rows = await db<{
    purpose: string; reserved: string; settled: string; n: string
  }[]>`
    SELECT purpose,
           coalesce(sum(est_jpy)    FILTER (WHERE state = 'reserved'), 0) AS reserved,
           coalesce(sum(actual_jpy) FILTER (WHERE state = 'settled'),  0) AS settled,
           count(*) FILTER (WHERE state <> 'released')                    AS n
      FROM ai_spend
     WHERE period = ${period}
     GROUP BY purpose
     -- ★ 解放しかされていない purpose は行ごと落とす。
     --   GROUP BY だけだと「0円の generate」が並び、支出があるように見える
     HAVING count(*) FILTER (WHERE state <> 'released') > 0
     ORDER BY 3 DESC, 1`
  return rows.map(r => ({
    purpose: r.purpose,
    reservedJpy: Number(r.reserved),
    settledJpy: Number(r.settled),
    count: Number(r.n),
  }))
}

export type VerificationSpend = {
  /** 二次照合（factcheck + judge）の実行回数 */
  runs: number
  /** その概算金額（確定分は実額、予約中は見積り） */
  jpy: number
}

/** 検証の課金（docs/12 §7.1）。無料枠ではなく課金モデルを使う唯一の場所 */
export async function verificationSpend(db: Sql, period: string): Promise<VerificationSpend> {
  const [row] = await db<{ runs: string; jpy: string }[]>`
    SELECT count(*) AS runs,
           coalesce(sum(coalesce(actual_jpy, est_jpy)), 0) AS jpy
      FROM ai_spend
     WHERE period = ${period} AND state <> 'released'
       AND purpose IN ('factcheck', 'judge')`
  return { runs: Number(row?.runs ?? 0), jpy: Number(row?.jpy ?? 0) }
}

export type CronHealth = {
  kind: string
  lastRunAt: Date | null
  lastOk: boolean | null
  /** 24時間以上記録が無い。cron が止まっている疑い */
  stale: boolean
}

/**
 * cron の生存（docs/12:172「最終実行時刻。24時間記録がなければ警告」）
 *
 * ★ 一度も走っていない種別も **stale として出す**。行が無いことを
 *   「まだ動かしていないだけ」と黙って許すと、設定を忘れたまま
 *   何ヶ月も通知が来ないことに気づけない。
 */
export async function cronHealth(db: Sql, now: Date, kinds = ['remind', 'reap_reservations']): Promise<CronHealth[]> {
  const rows = await db<{ kind: string; ran_at: Date; ok: boolean }[]>`
    SELECT DISTINCT ON (kind) kind, ran_at, ok
      FROM ops_log ORDER BY kind, ran_at DESC`
  const byKind = new Map(rows.map(r => [r.kind, r]))
  const limit = now.getTime() - CRON_SILENCE_HOURS * 3_600_000
  return kinds.map(kind => {
    const r = byKind.get(kind)
    return {
      kind,
      lastRunAt: r?.ran_at ?? null,
      lastOk: r?.ok ?? null,
      stale: !r || r.ran_at.getTime() < limit,
    }
  })
}

/**
 * 遮断器を解除する（docs/12 §7.2「halted の解除は作者だけができる」）
 *
 * ★ 上限そのものは動かさない。上限に達したから止まったのに、
 *   解除と同時に上限も上げられると、遮断器の意味が無くなる。
 *   上限を変えたいときは setCap を別に呼ぶ（意図を2回に分ける）。
 *
 * ★ 使用額が上限以上のまま解除しても、次の予約で tripIfOverCap が
 *   また止める。それは正しい挙動なので、ここでは防がない。
 */
export async function resumeBudget(db: Sql, period: string): Promise<{ resumed: boolean }> {
  const rows = await db`
    UPDATE ai_budget
       SET halted = false, halted_at = NULL, halted_reason = NULL
     WHERE period = ${period} AND halted
    RETURNING period`
  return { resumed: rows.length > 0 }
}
