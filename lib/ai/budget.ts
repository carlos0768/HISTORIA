/**
 * 支出遮断器
 *
 * 仕様: docs/08-ai-architecture.md §7.1
 *
 * 作者の決定「一万円を超えたら即座に処理を停止する」の実装。
 *
 * 支出は呼び出しが返ってきて初めて確定するため、確定額だけを足していく元帳では
 * 必ず飛行中の呼び出しの分だけ超過する。発行前に「上限見積り」を予約することで、
 *     settled_jpy + reserved_jpy <= cap_jpy
 * を不変条件にし、上限を1円も超えないようにする。
 */
import type { Sql } from 'postgres'

/** 為替。保守的に見る。実勢が円高なら安全側に外れる（§7.1） */
export const JPY_PER_USD = 160
/** 未知の課金項目（キャッシュ/推論トークン等）への安全余裕。M24 で実測する */
export const SAFETY_MARGIN = 1.05

export type Purpose =
  | 'generate' | 'factcheck' | 'judge' | 'diagnostic' | 'embed' | 'scope_parse'
  | 'atlas_generate' | 'atlas_verify'

/** USD / MTok */
export type Price = { inputPerMTok: number; outputPerMTok: number }

/**
 * 上限見積り。maxOutputTokens を使うので、実額がこれを超えることはない。
 * この性質が遮断器の不変条件を支えている（§7.1）。
 */
export function estimateJpy(maxInputTokens: number, maxOutputTokens: number, price: Price): number {
  const usd =
    (maxInputTokens / 1_000_000) * price.inputPerMTok + (maxOutputTokens / 1_000_000) * price.outputPerMTok
  return usd * JPY_PER_USD * SAFETY_MARGIN
}

/** 月初（Asia/Tokyo）を集計キーにする */
export function periodOf(now: Date): string {
  const jst = new Date(now.getTime() + 9 * 3_600_000)
  return `${jst.getUTCFullYear()}-${String(jst.getUTCMonth() + 1).padStart(2, '0')}-01`
}

export class BudgetExceededError extends Error {
  constructor(readonly period: string) {
    super(`月の AI 支出上限に達したため呼び出しを停止しました（${period}）`)
    this.name = 'BudgetExceededError'
  }
}

export type Reservation = { spendId: string; estJpy: number; period: string }

/** その月の予算行が無ければ作る。cap は app_setting ではなく行に持たせて履歴を残す */
export async function ensureBudgetRow(db: Sql, period: string): Promise<void> {
  await db`
    INSERT INTO ai_budget (period) VALUES (${period})
    ON CONFLICT (period) DO NOTHING`
}

/**
 * 関門。予約できたら呼び出してよい。できなければ呼び出さない。
 *
 * ★ 単一の UPDATE にするのが要点である。
 *   「SELECT で残高を見てから UPDATE」だと、2つのリクエストが同時に残高を読んで
 *   両方が「足りている」と判断し、両方が発行してしまう。
 *   単一 UPDATE なら READ COMMITTED で行ロック解放後に WHERE が新しい行バージョンに
 *   対して評価し直される（EvalPlanQual）ので、後続は正しく落ちる。
 */
export async function reserve(
  db: Sql,
  args: { estJpy: number; provider: string; model: string; purpose: Purpose; jobId?: string | null; now: Date },
): Promise<Reservation> {
  const period = periodOf(args.now)
  await ensureBudgetRow(db, period)

  const granted = await db`
    UPDATE ai_budget
       SET reserved_jpy = reserved_jpy + ${args.estJpy}
     WHERE period = ${period}
       AND NOT halted
       AND settled_jpy + reserved_jpy + ${args.estJpy} <= cap_jpy
    RETURNING reserved_jpy`

  if (granted.length === 0) {
    await tripIfOverCap(db, period)
    throw new BudgetExceededError(period)
  }

  const rows = await db`
    INSERT INTO ai_spend (period, job_id, provider, model, purpose, est_jpy, jpy_per_usd)
    VALUES (${period}, ${args.jobId ?? null}, ${args.provider}, ${args.model}, ${args.purpose},
            ${args.estJpy}, ${JPY_PER_USD})
    RETURNING id`

  // 予約が通った結果として上限に達した場合もここで停止させる。
  // ここで立てないと、その後 release や settle で使用額が下がったときに枠が再び空き、
  // 「同月内の自動復帰はしない」（§7.1）が破られる。
  await tripIfOverCap(db, period)

  return { spendId: String(rows[0]!.id), estJpy: args.estJpy, period }
}

/** 確定。実額に置き換え、見積りとの差額を枠に戻す */
export async function settle(
  db: Sql,
  r: Reservation,
  usage: { inputTokens: number; outputTokens: number; actualJpy: number },
): Promise<void> {
  // 実額が見積りを超えることは設計上ありえない。起きたら見積り式のバグなので
  // ai_spend の CHECK が INSERT を落とす。ここでも念のため丸めない
  await db.begin(async tx => {
    await tx`
      UPDATE ai_spend
         SET state = 'settled', actual_jpy = ${usage.actualJpy}, settled_at = now(),
             input_tokens = ${usage.inputTokens}, output_tokens = ${usage.outputTokens}
       WHERE id = ${r.spendId} AND state = 'reserved'`
    await tx`
      UPDATE ai_budget
         SET reserved_jpy = greatest(0, reserved_jpy - ${r.estJpy}),
             settled_jpy  = settled_jpy + ${usage.actualJpy}
       WHERE period = ${r.period}`
  })
  await tripIfOverCap(db, r.period)
}

/** 呼び出しが失敗した場合に予約を解放する */
export async function release(db: Sql, r: Reservation): Promise<void> {
  await db.begin(async tx => {
    const updated = await tx`
      UPDATE ai_spend SET state = 'released' WHERE id = ${r.spendId} AND state = 'reserved'
      RETURNING id`
    if (updated.length > 0) {
      await tx`
        UPDATE ai_budget SET reserved_jpy = greatest(0, reserved_jpy - ${r.estJpy})
         WHERE period = ${r.period}`
    }
  })
}

/** 予約したまま確定していない行の回収。プロセス異常終了で予約が漏れるため（§7.1 ④） */
export const STALE_RESERVATION_MINUTES = 15

export async function reapStaleReservations(db: Sql, period: string): Promise<number> {
  const rows = await db`
    WITH stale AS (
      UPDATE ai_spend SET state = 'released'
       WHERE period = ${period} AND state = 'reserved'
         AND created_at < now() - (${STALE_RESERVATION_MINUTES} || ' minutes')::interval
      RETURNING est_jpy
    ), total AS (SELECT coalesce(sum(est_jpy), 0) AS s, count(*) AS n FROM stale)
    UPDATE ai_budget b
       SET reserved_jpy = greatest(0, b.reserved_jpy - (SELECT s FROM total))
      FROM total
     WHERE b.period = ${period}
    RETURNING (SELECT n FROM total) AS n`
  return Number(rows[0]?.n ?? 0)
}

/** 上限に達したら停止フラグを立てる。同月内の自動復帰はしない */
async function tripIfOverCap(db: Sql, period: string): Promise<void> {
  await db`
    UPDATE ai_budget
       SET halted = true, halted_at = now(), halted_reason = 'cap_exceeded'
     WHERE period = ${period} AND NOT halted
       AND settled_jpy + reserved_jpy >= cap_jpy`
}

/**
 * 上限額を変更する（管理画面用・docs/12 §7.2）。
 *
 * schema には CHECK (warn_jpy <= degrade_jpy <= cap_jpy) があるため、
 * cap だけを下げる UPDATE は制約違反で落ちる。警告と縮退の閾値を
 * 現在の比率のまま追随させて、3つを1文で更新する。
 */
export async function setCap(db: Sql, period: string, capJpy: number): Promise<void> {
  if (!(capJpy > 0)) throw new Error('cap_jpy は正の数である必要があります')
  await ensureBudgetRow(db, period)
  await db`
    UPDATE ai_budget
       SET cap_jpy     = ${capJpy},
           degrade_jpy = least(degrade_jpy, ${capJpy}),
           warn_jpy    = least(warn_jpy, least(degrade_jpy, ${capJpy}))
     WHERE period = ${period}`
}

export type BudgetStatus = {
  period: string
  capJpy: number
  warnJpy: number
  degradeJpy: number
  usedJpy: number
  remainingJpy: number
  halted: boolean
  /** 8,000円到達。judge と先読み生成を止める。利用者の体験は落とさない */
  degraded: boolean
  /** 5,000円到達。作者に通知するだけ */
  warned: boolean
}

export async function budgetStatus(db: Sql, now: Date): Promise<BudgetStatus> {
  const period = periodOf(now)
  await ensureBudgetRow(db, period)
  const [row] = await db<
    { cap_jpy: string; warn_jpy: string; degrade_jpy: string; reserved_jpy: string; settled_jpy: string; halted: boolean }[]
  >`SELECT cap_jpy, warn_jpy, degrade_jpy, reserved_jpy, settled_jpy, halted
      FROM ai_budget WHERE period = ${period}`
  if (!row) throw new Error(`ai_budget の行が作れませんでした（${period}）`)

  const cap = Number(row.cap_jpy)
  const used = Number(row.reserved_jpy) + Number(row.settled_jpy)
  return {
    period,
    capJpy: cap,
    warnJpy: Number(row.warn_jpy),
    degradeJpy: Number(row.degrade_jpy),
    usedJpy: used,
    remainingJpy: Math.max(0, cap - used),
    halted: row.halted,
    degraded: row.halted || used >= Number(row.degrade_jpy),
    warned: used >= Number(row.warn_jpy),
  }
}
