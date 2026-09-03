/**
 * 設問難易度の Elo 較正（docs/04-weakness-engine.md §5.2・docs/04b §1.3）
 *
 * ★ 較正が成立するのは**診断プールだけ**である。
 *   ユーザーごとに生成される設問は同じものが二度と出ないので `elo_n` が溜まらず、
 *   較正が原理的に成立しない（04b §1.3 がそれを理由に較正を廃止した）。
 *   診断プールは全員に同じ item が出るので、そこだけは例外的に溜まる。
 *
 * ★ だから**呼ぶ場所を1つに絞る**。診断で解いたときにしか呼ばない。
 *   ユーザー生成の item にも適用すると、1〜2件の観測で難易度が大きく動き、
 *   その item は二度と出ないまま歪んだ値だけが残る。
 *
 * ★ K を観測数で減衰させる。最初の数件で大きく動かして早く形にし、
 *   溜まってからは動かさない（既に多くの人が解いた item の難易度を、
 *   新しい1人の解答でひっくり返さない）。
 */

/** 最初の1件で動かす幅 */
export const K_MAX = 0.4
/** 観測が溜まったあとの下限 */
export const K_MIN = 0.02
/** K が半分になるまでの観測数 */
export const K_HALFLIFE = 20

/** 難易度の可動域。ここを超えると p が飽和して情報量が0になる */
export const ELO_B_LIMIT = 3

export function stepSize(eloN: number): number {
  const k = K_MAX * (K_HALFLIFE / (K_HALFLIFE + Math.max(0, eloN)))
  return Math.max(K_MIN, k)
}

export type EloUpdate = { eloB: number; eloN: number }

/**
 * 1件の解答で item の難易度を更新する。
 *
 * ★ 向きに注意。**正解されたら難易度を下げる**（elo_b を小さくする）。
 *   `p = g + (1-g)·sigmoid(theta - elo_b)` なので、elo_b が小さいほど易しい。
 *
 * @param expected  そのユーザーのθから見た正答確率（lib/domain/diagnostic.ts の pCorrect）
 */
export function updateElo(
  current: EloUpdate, correct: boolean, expected: number,
): EloUpdate {
  const k = stepSize(current.eloN)
  // 予想より正解されたら易しい、予想より間違えられたら難しい
  const delta = k * ((correct ? 1 : 0) - expected)
  const eloB = Math.max(-ELO_B_LIMIT, Math.min(ELO_B_LIMIT, current.eloB - delta))
  return { eloB, eloN: current.eloN + 1 }
}
