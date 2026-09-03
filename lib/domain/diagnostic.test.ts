import { describe, it, expect } from 'vitest'
import {
  cellKey, allCells, initialCells, pCorrect, information, facetUncertainty,
  selectNext, updateCell, shouldStop, summarize, itemsNeededPerCell,
  CELL_COUNT, MIN_ITEMS, MAX_ITEMS, SD_TARGET, THETA_0, SD_0, THETA_LIMIT,
  type Candidate, type CellPosterior,
} from './diagnostic'
import { updateElo, stepSize, K_MAX, K_MIN, ELO_B_LIMIT } from './elo'

/**
 * 適応的診断テスト（docs/04-weakness-engine.md §5）
 */

describe('セル（3時代 × 4地域）', () => {
  it('12セルある', () => {
    expect(CELL_COUNT).toBe(12)
    expect(allCells()).toHaveLength(12)
    expect(new Set(allCells()).size).toBe(12)
  })

  it('初期値は θ=-0.5・SD=1.0・0問（§5.4）', () => {
    const cells = initialCells()
    expect(cells.size).toBe(12)
    expect(cells.get(cellKey(1, 1))).toEqual({ theta: THETA_0, sd: SD_0, answered: 0 })
    expect(THETA_0).toBe(-0.5)
  })
})

describe('正答確率（§5.3）', () => {
  it('θ = elo_b のとき、当てずっぽうを含めて中間になる', () => {
    expect(pCorrect(0, 0, 0.25)).toBeCloseTo(0.25 + 0.75 * 0.5, 10)
  })

  /**
   * ★ 当てずっぽうの下限。これが無いと、θがどれだけ低くても p→0 になり、
   *   まぐれ当たりを実力の証拠として読んでしまう
   */
  it('どれだけ苦手でも g を下回らない', () => {
    expect(pCorrect(-100, 0, 0.25)).toBeCloseTo(0.25, 6)
    expect(pCorrect(-100, 0, 0.5)).toBeCloseTo(0.5, 6)
  })

  it('得意なほど上がり、難しいほど下がる', () => {
    expect(pCorrect(2, 0, 0.25)).toBeGreaterThan(pCorrect(0, 0, 0.25))
    expect(pCorrect(0, 2, 0.25)).toBeLessThan(pCorrect(0, 0, 0.25))
  })
})

describe('情報量', () => {
  /** 仕様の「四択の情報量が最大になるのは p ≈ 0.5〜0.6 付近」（§5.3） */
  it('θ = elo_b のあたりで最大になる', () => {
    const at = (theta: number) => information(theta, 0, 0.25)
    expect(at(0)).toBeGreaterThan(at(2))
    expect(at(0)).toBeGreaterThan(at(-2))
  })

  const argmax = (f: (t: number) => number) => {
    let bestTheta = 0, best = -Infinity
    for (let t = -6; t <= 6; t += 0.001) {
      const v = f(t)
      if (v > best) { best = v; bestTheta = t }
    }
    return bestTheta
  }
  const naive = (theta: number) => {
    const p = pCorrect(theta, 0, 0.25)
    return 4 * p * (1 - p)
  }

  /**
   * ★ 仕様（§5.3）は「四択の情報量が最大になるのは p ≈ 0.5〜0.6 付近」と書いているが、
   *   当てずっぽうを含めた本来の Fisher 情報量の最大は **p ≈ 0.68** である。
   *   仕様の括弧書きのほうが少しずれている。実測してここに残しておく。
   */
  it('最大になるのは p ≈ 0.68 のとき（仕様の「0.5〜0.6」より少し易しい側）', () => {
    const p = pCorrect(argmax(t => information(t, 0, 0.25)), 0, 0.25)
    expect(p).toBeCloseTo(0.683, 2)
  })

  /**
   * ★ 逆対照。仕様の式 4p(1-p) をそのまま使うと p = 0.5 で最大になる。
   *   当てずっぽうがある四択では、それは本来の最適より**約1.0 だけ難しい側**であり、
   *   出題が系統的に難問へ寄る。式を戻したらこの試験が落ちる。
   */
  it('仕様の 4p(1-p) をそのまま使うと、系統的に難問へ寄る', () => {
    const naiveBest = argmax(naive)
    const fisherBest = argmax(t => information(t, 0, 0.25))
    // 素朴な式の最適は p = 0.5 ちょうど
    expect(pCorrect(naiveBest, 0, 0.25)).toBeCloseTo(0.5, 3)
    // そしてそれは本来の最適より難しい側（θ が小さい = 相対的に難問）
    expect(naiveBest).toBeLessThan(fisherBest)
    expect(fisherBest - naiveBest).toBeGreaterThan(0.9)
  })

  it('絶対に解けない／絶対に解ける問題からは情報が取れない', () => {
    expect(information(-50, 0, 0.25)).toBeLessThan(1e-6)
    expect(information(50, 0, 0.25)).toBeLessThan(1e-6)
  })
})

describe('次の1問の選択（§5.3）', () => {
  const cand = (itemId: string, cell: string, eloB = 0): Candidate =>
    ({ itemId, cell, eloB, guessRate: 0.25 })

  it('まだ測れていないセルを優先する', () => {
    const cells = initialCells()
    cells.set(cellKey(1, 1), { theta: 0, sd: 0.2, answered: 8 })
    const next = selectNext([cand('a', cellKey(1, 1)), cand('b', cellKey(2, 2))], cells)
    expect(next!.itemId).toBe('b')
  })

  it('同じセルなら、そのθに近い難易度の問題を選ぶ', () => {
    const cells = initialCells()
    cells.set(cellKey(1, 1), { theta: 1.0, sd: 1.0, answered: 1 })
    const next = selectNext([
      cand('easy', cellKey(1, 1), -3),
      cand('fit', cellKey(1, 1), 1.0),
      cand('hard', cellKey(1, 1), 3),
    ], cells)
    expect(next!.itemId).toBe('fit')
  })

  /** ★ 乱数を使わない。同じ答え方をした2人には同じ問題が出る */
  it('同点なら itemId の辞書順で決まる（毎回同じ）', () => {
    const cells = initialCells()
    const list = [cand('zzz', cellKey(1, 1)), cand('aaa', cellKey(1, 1))]
    expect(selectNext(list, cells)!.itemId).toBe('aaa')
    expect(selectNext([...list].reverse(), cells)!.itemId).toBe('aaa')
  })

  it('候補が無ければ null', () => {
    expect(selectNext([], initialCells())).toBeNull()
  })

  it('知らないセルの候補は選ばない', () => {
    expect(selectNext([cand('x', '9:9')], initialCells())).toBeNull()
  })
})

describe('セルの事後分布の更新', () => {
  const c0: CellPosterior = { theta: 0, sd: 1, answered: 0 }

  it('正解すればθが上がり、SD が縮む', () => {
    const c = updateCell(c0, true, 0, 0.25)
    expect(c.theta).toBeGreaterThan(0)
    expect(c.sd).toBeLessThan(1)
    expect(c.answered).toBe(1)
  })

  it('不正解ならθが下がる', () => {
    expect(updateCell(c0, false, 0, 0.25).theta).toBeLessThan(0)
  })

  /** ★ 正解でも不正解でも「測った」ことに変わりはない */
  it('SD は正誤によらず縮む', () => {
    expect(updateCell(c0, true, 0, 0.25).sd).toBeLessThan(1)
    expect(updateCell(c0, false, 0, 0.25).sd).toBeLessThan(1)
  })

  /**
   * ★ 発散させない。全問正解の人のθが青天井になると、
   *   伝播先の KC が全部「もう知っている」になる。24問ではそこまで測れていない
   */
  it('全問正解でもθは上限で止まる', () => {
    let c = c0
    for (let i = 0; i < 200; i++) c = updateCell(c, true, 0, 0.25)
    expect(c.theta).toBeLessThanOrEqual(THETA_LIMIT)
    expect(Number.isFinite(c.theta)).toBe(true)
  })

  it('全問不正解でもθは下限で止まる', () => {
    let c = c0
    for (let i = 0; i < 200; i++) c = updateCell(c, false, 0, 0.25)
    expect(c.theta).toBeGreaterThanOrEqual(-THETA_LIMIT)
  })

  it('答え続ければ SD は単調に縮む', () => {
    let c = c0
    let prev = c.sd
    for (let i = 0; i < 20; i++) {
      c = updateCell(c, i % 2 === 0, 0, 0.25)
      expect(c.sd).toBeLessThanOrEqual(prev)
      prev = c.sd
    }
  })

  /** 正解と不正解を交互に取れば、θはおおむね元の位置に戻る */
  it('半々に正解する人のθは中間に落ち着く', () => {
    let c: CellPosterior = { theta: 0, sd: 1, answered: 0 }
    for (let i = 0; i < 40; i++) c = updateCell(c, i % 2 === 0, 0, 0.25)
    expect(Math.abs(c.theta)).toBeLessThan(1.0)
  })
})

describe('打ち切り（§5.3）', () => {
  const tight = () => new Map(allCells().map(k =>
    [k, { theta: 0, sd: SD_TARGET - 0.01, answered: 2 }]))

  it('12問未満では止めない', () => {
    expect(shouldStop(MIN_ITEMS - 1, tight())).toBe(false)
  })

  it('12問以上で全セルが目標SD以下なら止める', () => {
    expect(shouldStop(MIN_ITEMS, tight())).toBe(true)
  })

  it('1セルでも届いていなければ続ける（逆対照）', () => {
    const cells = tight()
    cells.set(cellKey(3, 4), { theta: 0, sd: SD_TARGET + 0.01, answered: 1 })
    expect(shouldStop(MIN_ITEMS, cells)).toBe(false)
  })

  /** ★ 24問を超えない。1問25秒想定で最大10分（§5.3） */
  it('24問に達したら、SD に関わらず止める', () => {
    expect(shouldStop(MAX_ITEMS, initialCells())).toBe(true)
  })

  it('24問を超えることはない', () => {
    expect(shouldStop(MAX_ITEMS + 5, initialCells())).toBe(true)
  })

  /**
   * ★ 仕様の食い違いを機械で見える形にしておく（lib/domain/diagnostic.ts 冒頭）。
   *   SD 条件が満たされるには1セルあたり数十問が要る。24問÷12セル＝2問では届かない。
   *   実際に効くのは上限24問のほうである。
   *   **この試験が落ちたら、SD 条件が現実に発火するようになったということ**で、
   *   そのときは冒頭の注記を書き直す。
   */
  it('SD 条件は現実には発火しない（1セルあたりの必要問数が2問を大きく超える）', () => {
    const need = itemsNeededPerCell()
    expect(need).toBeGreaterThan(MAX_ITEMS / CELL_COUNT)
    expect(need).toBeGreaterThan(20)
  })

  it('目標SDを緩めれば必要問数は減る（作者が調整できる）', () => {
    expect(itemsNeededPerCell(SD_0, 0.9)).toBeLessThan(itemsNeededPerCell(SD_0, 0.35))
    expect(itemsNeededPerCell(SD_0, 1.5)).toBe(0)
  })
})

describe('まとめ', () => {
  it('1問も出せなかったセルを挙げる（測っていないことを画面に書くため）', () => {
    const cells = initialCells()
    cells.set(cellKey(1, 1), { theta: 0.3, sd: 0.8, answered: 3 })
    const r = summarize(cells, 3)
    expect(r.answered).toBe(3)
    expect(r.unmeasured).toHaveLength(11)
    expect(r.unmeasured).not.toContain(cellKey(1, 1))
  })
})

describe('facet_uncertainty', () => {
  it('分散を使う（SD ではない）', () => {
    expect(facetUncertainty({ theta: 0, sd: 0.5, answered: 1 })).toBeCloseTo(0.25, 10)
  })
})

describe('Elo 較正（docs/04 §5.2）', () => {
  it('予想より正解されたら易しくなる（elo_b が下がる）', () => {
    const r = updateElo({ eloB: 0, eloN: 0 }, true, 0.4)
    expect(r.eloB).toBeLessThan(0)
    expect(r.eloN).toBe(1)
  })

  it('予想より間違えられたら難しくなる', () => {
    expect(updateElo({ eloB: 0, eloN: 0 }, false, 0.8).eloB).toBeGreaterThan(0)
  })

  it('予想どおりなら動かない', () => {
    const r = updateElo({ eloB: 0.3, eloN: 5 }, true, 1)
    expect(r.eloB).toBeCloseTo(0.3, 10)
  })

  /** ★ 溜まった item の難易度を、新しい1人の解答でひっくり返さない */
  it('観測が溜まるほど動きが小さくなる', () => {
    expect(stepSize(0)).toBeCloseTo(K_MAX, 10)
    expect(stepSize(20)).toBeLessThan(stepSize(0))
    expect(stepSize(100_000)).toBeCloseTo(K_MIN, 10)
    expect(stepSize(100_000)).toBeGreaterThanOrEqual(K_MIN)
  })

  it('難易度は可動域で止まる', () => {
    let e = { eloB: 0, eloN: 0 }
    for (let i = 0; i < 5000; i++) e = updateElo(e, false, 0)
    expect(e.eloB).toBeLessThanOrEqual(ELO_B_LIMIT)
    let f = { eloB: 0, eloN: 0 }
    for (let i = 0; i < 5000; i++) f = updateElo(f, true, 1)
    expect(f.eloB).toBeGreaterThanOrEqual(-ELO_B_LIMIT)
  })

  /** 実際に難易度が推定できること。真の難易度に近づくか見る */
  it('真の難易度に寄っていく', () => {
    const TRUE_B = 1.2
    let e = { eloB: 0, eloN: 0 }
    // θ=0 の人が 200 人解いたとして、真の確率で正誤を作る（決定的に）
    const p = pCorrect(0, TRUE_B, 0.25)
    for (let i = 0; i < 400; i++) {
      const correct = (i % 100) / 100 < p
      e = updateElo(e, correct, pCorrect(0, e.eloB, 0.25))
    }
    expect(e.eloB).toBeGreaterThan(0.5)
    expect(e.eloB).toBeLessThan(2.0)
  })
})
