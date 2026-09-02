/**
 * 診断プールをどのセルに何問足すかを決める（docs/04-weakness-engine.md §5.2）
 *
 * ★ 目標は「12セル × 各20問 = 240問」だが、**既存の408問を数え直してから**
 *   足りないぶんだけ作る（作者の判断: 既存と合流させて648問にする）。
 *   12セルに均等な20問を新規に作ると、すでに厚いセルがさらに厚くなり、
 *   薄いセルは薄いままになる。
 *
 * ★ 配分は純粋な計算にして、ここだけを試験する。生成そのもの
 *   （scripts/measure/generate-diagnostic.ts）は鍵と課金が要るので回せない。
 */
import { allCells, type CellKey } from './diagnostic'

/** 1セルあたりの目標問数（§5.2「12セル × 各20問」） */
export const TARGET_PER_CELL = 20

export type CellCount = { cell: CellKey; have: number }
export type CellPlan = { cell: CellKey; have: number; need: number }

/**
 * 各セルに何問足すかを出す。
 *
 * @param counts  いま各セルに何問あるか
 * @param budget  作ってよい総数。null なら「全セルを目標まで」
 *
 * ★ 予算が足りないときは**水位を上げるように**配る（water-filling）。
 *   毎回「目標から最も遠いセル」に1問ずつ足すので、薄いセルどうしが
 *   同じ高さまで揃ってから次へ進む。均等割り（各セルに budget/12 ずつ）だと、
 *   いちばん測れていないセルが最後まで測れないままになる。
 *
 * ★ round-robin（1周ずつ配る）ではない。1セルだけが極端に薄いときは、
 *   予算をそのセルに集中させるのが正しい。他が19問あるのに1問ずつ足しても、
 *   測定は1つも良くならない。
 */
export function planCells(counts: readonly CellCount[], budget: number | null = null): CellPlan[] {
  const have = new Map(counts.map(c => [c.cell, c.have]))
  const plan = allCells().map(cell => ({ cell, have: have.get(cell) ?? 0, need: 0 }))

  const room = (p: CellPlan) => Math.max(0, TARGET_PER_CELL - p.have - p.need)
  let left = budget ?? plan.reduce((s, p) => s + room(p), 0)

  while (left > 0) {
    // 目標までの隔たりが最も大きいセルへ1問。同点は cell の順で決める（乱数を使わない）
    const target = plan
      .filter(p => room(p) > 0)
      .sort((a, b) => room(b) - room(a) || (a.cell < b.cell ? -1 : 1))[0]
    if (!target) break
    target.need++
    left--
  }
  return plan
}

/** 作る総数 */
export const totalToGenerate = (plan: readonly CellPlan[]): number =>
  plan.reduce((s, p) => s + p.need, 0)
