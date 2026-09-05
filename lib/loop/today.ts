/**
 * 「今日やること」の組み立て
 *
 * 仕様: docs/05-scheduler.md §4.2・§5.1・§6
 *
 * 夜間バッチを持たない。呼ばれるたびに計算する（docs/05 §7）。
 */
import type { Sql } from 'postgres'
import { dailyQueue, dailyPlan, drillProgress, drillState, DEFAULT_MAX_DAILY,
         type QueueCandidate, type ScheduledKc } from '@/lib/domain/scheduler'
import { mastery, masteryStatus, type KcState, type MasteryStatus } from '@/lib/domain/weakness'
import { newKcCard, type KcCard } from '@/lib/domain/sm2'
import { requiredDwellExpr } from './material'

type Row = {
  kc_id: string
  kc_label: string
  p_know: number | null
  theta: number | null
  n_eff: number | null
  n_obs: number | null
  last_seen_at: Date | null
  n: number | null
  ef: number | null
  interval_days: number | null
  due_at: Date | null
  lapses: number | null
  suspended: boolean | null
  last_review_at: Date | null
  earliest_deadline: Date
  is_misconception: boolean
  distinct_correct_days: number
  has_non_flashcard_correct: boolean
}

/**
 * active な特訓の KC を union で1本に集める（§5.1）。
 * 各特訓が独立にノルマを出すと合計が1日8時間になるため、キューは1本にする。
 */
async function loadCandidates(db: Sql, userId: string): Promise<Row[]> {
  return db<Row[]>`
    WITH active_kc AS (
      SELECT dk.kc_id, min(d.deadline)::timestamptz AS earliest_deadline
        FROM drill d JOIN drill_kc dk ON dk.drill_id = d.id
       WHERE d.user_id = ${userId} AND d.status = 'active'
       GROUP BY dk.kc_id
    )
    SELECT a.kc_id, kc.label AS kc_label, a.earliest_deadline,
           s.p_know, s.theta, s.n_eff, s.n_obs, s.last_seen_at,
           c.n, c.ef, c.interval_days, c.due_at, c.lapses, c.suspended, c.last_review_at,
           EXISTS (SELECT 1 FROM misconception m
                    WHERE m.user_id = ${userId} AND m.kc_id = a.kc_id AND m.resolved_at IS NULL)
             AS is_misconception,
           (SELECT count(DISTINCT date(r.answered_at))
              FROM response r JOIN item_kc ik ON ik.item_id = r.item_id
             WHERE r.user_id = ${userId} AND ik.kc_id = a.kc_id AND r.correct)::int
             AS distinct_correct_days,
           EXISTS (SELECT 1 FROM response r
                     JOIN item_kc ik ON ik.item_id = r.item_id
                     JOIN item i ON i.id = r.item_id
                    WHERE r.user_id = ${userId} AND ik.kc_id = a.kc_id AND r.correct
                      AND i.format <> 'flashcard')
             AS has_non_flashcard_correct
      FROM active_kc a
      JOIN kc ON kc.id = a.kc_id
      LEFT JOIN user_kc_state s ON s.user_id = ${userId} AND s.kc_id = a.kc_id
      LEFT JOIN kc_card       c ON c.user_id = ${userId} AND c.kc_id = a.kc_id`
}

function toCandidate(r: Row, now: Date): QueueCandidate {
  const state: KcState = {
    pKnow: r.p_know ?? 0.25,
    theta: r.theta ?? -0.5,
    nEff: r.n_eff ?? 0,
    nObs: r.n_obs ?? 0,
    lastSeenAt: r.last_seen_at,
  }
  // kc_card がまだ無い KC は「新規学習」。初回は due_at = now で作る（§5.1 (b)）
  const card: KcCard = r.due_at
    ? {
        n: r.n ?? 0, ef: r.ef ?? 2.5, intervalDays: r.interval_days ?? 0,
        dueAt: r.due_at, lapses: r.lapses ?? 0,
        suspended: r.suspended ?? false, lastReviewAt: r.last_review_at,
      }
    : newKcCard(now)

  const m = mastery(state, card.intervalDays, now)
  const status: MasteryStatus = masteryStatus(state, m, {
    distinctCorrectDays: r.distinct_correct_days,
    hasNonFlashcardCorrect: r.has_non_flashcard_correct,
  })
  return {
    kcId: r.kc_id, label: r.kc_label, card, status, earliestDeadline: r.earliest_deadline,
    mastery: m, isMisconception: r.is_misconception, isNew: r.due_at === null,
  }
}

export type Today = {
  /** ホームに出す1つの数字。特訓ごとのノルマは出さない（§5.1） */
  targetCount: number
  /** 今日すでに解いた KC の数。ノルマから差し引く */
  doneToday: number
  queue: QueueCandidate[]
  feasible: boolean
  shortfall: number
  need: number
  daysLeft: number
}

export async function todaysPlan(db: Sql, userId: string, now: Date, maxDaily = DEFAULT_MAX_DAILY): Promise<Today> {
  // 候補と今日の解答数は互いに依存しない。遠隔DBへの往復を直列にしない。
  const [rows, done] = await Promise.all([
    loadCandidates(db, userId),
    db<{ n: string }[]>`
      SELECT count(DISTINCT ik.kc_id) AS n
        FROM response r JOIN item_kc ik ON ik.item_id = r.item_id
       WHERE r.user_id = ${userId} AND date(r.answered_at) = date(${now})`,
  ])
  const candidates = rows.map(r => toCandidate(r, now))
  const scheduled: ScheduledKc[] = candidates.map(c => ({
    kcId: c.kcId, card: c.card, status: c.status, earliestDeadline: c.earliestDeadline,
  }))
  const plan = dailyPlan(scheduled, now, maxDaily)

  // 今日すでに解いた KC を数える。
  // これを引かないと、解いた分だけ新しい KC が補充され続けて
  // 「今日やること」が 0 に到達せず、1日の終わりが定義できない。
  const doneToday = Number(done[0]?.n ?? 0)

  // 復習はノルマの外で必ず出し、新規学習だけをノルマの残りに絞る
  const queue = dailyQueue(candidates, now, Math.max(0, maxDaily - doneToday), Math.max(0, plan.target - doneToday))

  return {
    targetCount: queue.length,
    doneToday,
    queue,
    feasible: plan.feasible,
    shortfall: plan.shortfall,
    need: plan.need,
    daysLeft: plan.daysLeft,
  }
}

export type DrillProgress = {
  drillId: string
  title: string
  deadline: Date
  progress: number
  state: ReturnType<typeof drillState>
  masteredCount: number
  totalKc: number
  /** 読了率は進捗率とは別のバーで見せる（§6） */
  materialsRead: number
  materialsTotal: number
}

export async function drillProgressList(
  db: Sql,
  userId: string,
  now: Date,
  onlyDrillId?: string,
): Promise<DrillProgress[]> {
  const only = onlyDrillId ? db`AND d.id = ${onlyDrillId}` : db``

  // 以前は「一覧1回 + 特訓ごとにKC1回・教材1回」を直列で実行していた。
  // 遠隔DBでは特訓数に比例して遷移が遅くなるため、全件を3本の並列問い合わせで集める。
  const [drills, kcRows, materialRows] = await Promise.all([
    db<{ id: string; title: string; deadline: Date }[]>`
      SELECT d.id, d.title, d.deadline::timestamptz AS deadline
        FROM drill d
       WHERE d.user_id = ${userId} AND d.status = 'active' ${only}
       ORDER BY d.deadline`,
    db<(Row & { drill_id: string })[]>`
      WITH evidence AS (
        SELECT ik.kc_id,
               count(DISTINCT date(r.answered_at)) FILTER (WHERE r.correct)::int
                 AS distinct_correct_days,
               bool_or(r.correct AND i.format <> 'flashcard')
                 AS has_non_flashcard_correct
          FROM response r
          JOIN item i ON i.id = r.item_id
          JOIN item_kc ik ON ik.item_id = r.item_id
         WHERE r.user_id = ${userId}
         GROUP BY ik.kc_id
      )
      SELECT d.id AS drill_id, dk.kc_id, kc.label AS kc_label,
             d.deadline::timestamptz AS earliest_deadline,
             s.p_know, s.theta, s.n_eff, s.n_obs, s.last_seen_at,
             c.n, c.ef, c.interval_days, c.due_at, c.lapses, c.suspended, c.last_review_at,
             false AS is_misconception,
             coalesce(e.distinct_correct_days, 0) AS distinct_correct_days,
             coalesce(e.has_non_flashcard_correct, false) AS has_non_flashcard_correct
        FROM drill d
        JOIN drill_kc dk ON dk.drill_id = d.id
        JOIN kc ON kc.id = dk.kc_id
        LEFT JOIN evidence e ON e.kc_id = dk.kc_id
        LEFT JOIN user_kc_state s ON s.user_id = ${userId} AND s.kc_id = dk.kc_id
        LEFT JOIN kc_card c ON c.user_id = ${userId} AND c.kc_id = dk.kc_id
       WHERE d.user_id = ${userId} AND d.status = 'active' ${only}
       ORDER BY d.deadline, d.id, dk.kc_id`,
    db<{ drill_id: string; total: string; read: string }[]>`
      SELECT d.id AS drill_id,
             count(m.id) AS total,
             count(m.id) FILTER (
               WHERE EXISTS (SELECT 1 FROM material_section s WHERE s.material_id = m.id)
                 AND NOT EXISTS (
                   SELECT 1 FROM material_section s
                    WHERE s.material_id = m.id
                      AND NOT EXISTS (
                        SELECT 1 FROM material_read mr
                         WHERE mr.section_id = s.id AND mr.user_id = ${userId}
                           AND mr.dwell_ms >= ${requiredDwellExpr(db)}
                      )
                 )
             ) AS read
        FROM drill d
        LEFT JOIN drill_unit du ON du.drill_id = d.id
        LEFT JOIN material m ON m.unit_id = du.unit_id
         AND (m.user_id = ${userId} OR m.user_id IS NULL) AND m.status = 'ready'
       WHERE d.user_id = ${userId} AND d.status = 'active' ${only}
       GROUP BY d.id`,
  ])

  const kcsByDrill = new Map<string, Row[]>()
  for (const row of kcRows) {
    const rows = kcsByDrill.get(row.drill_id)
    if (rows) rows.push(row)
    else kcsByDrill.set(row.drill_id, [row])
  }
  const materialsByDrill = new Map(materialRows.map(row => [row.drill_id, row]))

  return drills.map(d => {
    const statuses = (kcsByDrill.get(d.id) ?? []).map(row => toCandidate(row, now).status)
    const progress = drillProgress(statuses)
    const material = materialsByDrill.get(d.id)
    return {
      drillId: d.id,
      title: d.title,
      deadline: d.deadline,
      progress,
      state: drillState(progress, d.deadline, now),
      masteredCount: statuses.filter(status => status === 'mastered').length,
      totalKc: statuses.length,
      materialsRead: Number(material?.read ?? 0),
      materialsTotal: Number(material?.total ?? 0),
    }
  })
}

export async function drillProgressFor(
  db: Sql,
  userId: string,
  drillId: string,
  now: Date,
): Promise<DrillProgress | null> {
  return (await drillProgressList(db, userId, now, drillId))[0] ?? null
}
