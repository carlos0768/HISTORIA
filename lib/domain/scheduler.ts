/**
 * 締切逆算のスケジューラ
 *
 * 仕様: docs/05-scheduler.md §3〜§6
 *
 * 夜間バッチを使わない。daily_plan はログイン時に毎回計算されるので、
 * サボった翌日は自動的に days_left が減って required が上がる。
 * これが正しい再計画であり、専用の再計画ロジックは持たない（§4）。
 */
import type { KcCard } from './sm2'
import { DEADLINE_BUFFER_DAYS } from './sm2'
import type { MasteryStatus } from './weakness'

/** 1日の出題上限の既定値。app_user.max_daily_items で変更できる（§9.1） */
export const DEFAULT_MAX_DAILY = 80
export const MAX_DAILY_MIN = 10
export const MAX_DAILY_MAX = 300
/** 特訓の完了条件。100% は SM-2 の mastered 条件上そもそも到達できない（§6.1） */
export const DRILL_COMPLETE_PROGRESS = 0.9
/** 新特訓の KC のうちこの割合を超えて既存と重複したら作成前に警告する（§5.3） */
export const OVERLAP_WARN_RATIO = 0.4

const DAY_MS = 86_400_000
export const daysBetween = (from: Date, to: Date) => Math.floor((to.getTime() - from.getTime()) / DAY_MS)

/**
 * 締切までにあと何回この KC を復習する必要があるか（§3）。
 *
 * 締切 D で保持率 R >= 0.90 を満たすには、最後の復習時点の間隔 I が
 * 締切までの残り日数以上である必要がある（R = 0.9^(t/I) より t=I のとき R=0.90）。
 * SM-2 は正答のたび interval を ×EF するので、必要回数は log_EF で求まる。
 */
export function repsLeft(card: KcCard, deadline: Date, today: Date): number {
  const iNeed = daysBetween(today, deadline) - DEADLINE_BUFFER_DAYS
  if (iNeed <= 0) return card.intervalDays === 0 ? 1 : 0
  if (card.intervalDays >= iNeed) return 0
  // ef の下限が 1.3 なので log(ef) > 0 が保証され、ゼロ除算は起きない
  const logEf = Math.log(card.ef)
  if (card.n === 0) return 1 + Math.ceil(Math.log(iNeed / 1) / logEf)
  if (card.n === 1) return 1 + Math.ceil(Math.log(iNeed / 6) / logEf)
  return Math.ceil(Math.log(iNeed / card.intervalDays) / logEf)
}

export type ScheduledKc = {
  kcId: string
  card: KcCard
  status: MasteryStatus
  /** その KC を含む active な特訓のうち最も早い締切 */
  earliestDeadline: Date
}

/**
 * 全 active 特訓の KC を合わせた必要復習回数（§3）。
 *
 * 引数は KC の集合なので、複数の特訓が同じ KC を含んでいても重複計上は起きない。
 * v0.2 にあった「KC単位で1回だけ数える」という但し書きは、スケジューリングの
 * 単位が KC そのものになったことで不要になった。
 */
export function remainingReps(kcs: ScheduledKc[], today: Date): number {
  let total = 0
  for (const k of kcs) {
    if (k.status === 'mastered') continue
    total += repsLeft(k.card, k.earliestDeadline, today)
  }
  return total
}

export type DailyPlan = {
  target: number
  feasible: boolean
  /** 何問分足りないか。feasible なら 0 */
  shortfall: number
  need: number
  daysLeft: number
}

/**
 * 1日のノルマ（§3.1）。
 *
 * 達成不能を黙って MAX_DAILY に丸めない。丸めると「毎日ノルマを達成しているのに
 * 締切に間に合わない」という最悪の体験になる。逆に丸めずに出すと「1日340問」が
 * ホームに出る。どちらも避けるため、上限で打ち切ったうえで不足分を明示する（§3.2）。
 */
export function dailyPlan(kcs: ScheduledKc[], today: Date, maxDaily: number): DailyPlan {
  const need = remainingReps(kcs, today)
  const deadlines = kcs.map(k => k.earliestDeadline.getTime())
  const earliest = deadlines.length ? new Date(Math.min(...deadlines)) : today
  const daysLeft = Math.max(1, daysBetween(today, earliest))
  const required = Math.ceil(need / daysLeft)

  if (required > maxDaily) {
    return { target: maxDaily, feasible: false, shortfall: need - maxDaily * daysLeft, need, daysLeft }
  }
  return { target: required, feasible: true, shortfall: 0, need, daysLeft }
}

export type QueueCandidate = ScheduledKc & {
  mastery: number
  isMisconception: boolean
  /** kc_card がまだ無い KC。新規学習であり、復習ではない（§5.1 (b)） */
  isNew: boolean
}

/** 締切が近いほど大きい。14日で 0 に落ちる線形 */
export function urgency(deadline: Date, today: Date): number {
  const d = daysBetween(today, deadline)
  if (d <= 0) return 1
  return Math.max(0, 1 - d / 14)
}

/**
 * overdue の並び順（§4.2）。
 *
 * overdue 日数の降順にすると、最も昔にサボった簡単なカードが延々と先頭に来る。
 * 締切と弱さを優先する。
 */
export function priority(c: QueueCandidate, today: Date): number {
  const overdueDays = Math.max(0, daysBetween(c.card.dueAt, today))
  return (
    2.0 * (c.isMisconception ? 1 : 0) +
    1.5 * urgency(c.earliestDeadline, today) +
    1.0 * (1 - c.mastery) +
    0.5 * Math.min(overdueDays / 14, 1)
  )
}

/**
 * 今日の出題キュー（§5.1）。
 *
 * 1日の出題キューは全特訓の union で1本にする。各特訓が独立にノルマを出すと
 * 合計が1日8時間になるため。ホームに出す数字も1つだけにする。
 *
 * ★ 復習と新規学習で扱いを分ける。
 *
 *   復習（due になった kc_card）は **ノルマの外**として必ず出す。
 *   SM-2 が「今日思い出さないと忘れる」と言っている分であり、
 *   締切逆算のノルマが少ないからといって飛ばすと間隔反復が壊れる。
 *
 *   新規学習（kc_card がまだ無い KC）は **ノルマの範囲で**投入する。
 *   ここを絞らないと初日に全 KC が投入され、翌日から due の山が崩れなくなる。
 *
 * どちらも合わせて MAX_DAILY で打ち切る。
 * この区別が無いと、(a) ノルマ 0 の日に due のカードが1枚も出ない、
 * (b) 初日に新規を投入し尽くす、のどちらかが必ず起きる。
 */
export function dailyQueue(
  candidates: QueueCandidate[],
  today: Date,
  maxDaily: number,
  targetNew = maxDaily,
): QueueCandidate[] {
  const live = candidates.filter(c => !c.card.suspended) // leech は出さない（04b §7）
  const byPriority = (a: QueueCandidate, b: QueueCandidate) => {
    const d = priority(b, today) - priority(a, today)
    return d !== 0 ? d : a.kcId.localeCompare(b.kcId)
  }

  const reviews = live
    .filter(c => !c.isNew && c.card.dueAt.getTime() <= today.getTime())
    .sort(byPriority)
  const fresh = live.filter(c => c.isNew).sort(byPriority)

  const room = Math.max(0, maxDaily - reviews.length)
  return [...reviews.slice(0, maxDaily), ...fresh.slice(0, Math.min(room, Math.max(0, targetNew)))]
}

/**
 * 特訓の進捗率（§6）。
 *
 * 「教材を読んだ」は分子に入れない。読んだだけで100%になるなら、このアプリは
 * 「単なる暗記アプリ」ですらない。読了率は別のバーとして並べて見せる。
 */
export function drillProgress(statuses: MasteryStatus[]): number {
  if (statuses.length === 0) return 0
  return statuses.filter(s => s === 'mastered').length / statuses.length
}

export type DrillState = 'active' | 'completed' | 'overdue'

/** 特訓の状態（§6.1）。締切超過でも abandoned にせず active のまま残す */
export function drillState(progress: number, deadline: Date, today: Date): DrillState {
  const past = today.getTime() > deadline.getTime()
  if (progress >= DRILL_COMPLETE_PROGRESS && !past) return 'completed'
  return past ? 'overdue' : 'active'
}

/** 新特訓の重複警告（§5.3） */
export function overlapRatio(newKcIds: string[], existingKcIds: Set<string>): number {
  if (newKcIds.length === 0) return 0
  return newKcIds.filter(id => existingKcIds.has(id)).length / newKcIds.length
}
