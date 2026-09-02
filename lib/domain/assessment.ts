/**
 * 確認テストの合否判定
 *
 * 仕様: docs/06-assessment.md §3
 */
import { drillProgress } from './scheduler'
import type { MasteryStatus } from './weakness'

export const VERDICT_PASS = 0.85
export const VERDICT_ALMOST = 0.6
/** 再テストはこの日数以上空ける。連続受験は「さっきの問題を覚えているか」の測定になる（§3.2） */
export const RETEST_COOLDOWN_DAYS = 3

export type Verdict = 'pass' | 'almost' | 'retry'

/**
 * 合否（§3.1）。
 *
 * 四択は25%で当たるため素点では判定しない。表示は素点、判定は mastery で行う。
 *
 * ★ 分母は特訓全体の KC ではなく、そのテストが出題対象とした KC に限る。
 *   特訓全体を分母にすると、10単元の特訓で1単元めを満点で通しても進捗率は
 *   最大 0.10 にしかならず、1回のテストでは構造的に合格に到達できない。
 *   計算式は 05 §6 と同一で、違うのは分母に取る KC 集合だけである。
 */
export function verdict(testedKcStatuses: MasteryStatus[]): Verdict {
  const p = drillProgress(testedKcStatuses)
  if (p >= VERDICT_PASS) return 'pass'
  if (p >= VERDICT_ALMOST) return 'almost'
  return 'retry'
}

export function canRetest(lastTestAt: Date | null, now: Date): boolean {
  if (!lastTestAt) return true
  return now.getTime() - lastTestAt.getTime() >= RETEST_COOLDOWN_DAYS * 86_400_000
}

/** 素点。表示にのみ使い、判定には使わない（§3.1） */
export function rawScore(correctCount: number, total: number): number {
  return total === 0 ? 0 : correctCount / total
}
