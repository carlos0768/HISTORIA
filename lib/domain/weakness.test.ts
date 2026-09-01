import { describe, it, expect } from 'vitest'
import { updateKcState, initialKcState, mastery, masteryStatus, slipRate, type KcState } from './weakness'
import { objectiveGrade, flashcardGrade, SELF_DECEPTION_MS } from './grading'
import { GUESS, SLIP_NORMAL, SLIP_FAST, N_EFF_UNKNOWN, THETA_0 } from './params'

const T0 = new Date('2026-04-01T00:00:00Z')
const DAY = 86_400_000
const base = (over: Partial<KcState> = {}): KcState =>
  ({ pKnow: 0.3, theta: THETA_0, nEff: 0, nObs: 0, lastSeenAt: null, ...over })
const facts = (over: Partial<Parameters<typeof updateKcState>[1]> = {}) =>
  ({ correct: true, latencyMs: 5000, format: 'mcq4' as const, weight: 1, baseDifficulty: 0, answeredAt: T0, ...over })

describe('§1.1 ベイズ更新', () => {
  it('正解で p_know が上がり、誤答で下がる', () => {
    const s = base()
    expect(updateKcState(s, facts({ correct: true })).pKnow).toBeGreaterThan(s.pKnow)
    expect(updateKcState(s, facts({ correct: false, latencyMs: 9000 })).pKnow).toBeLessThan(s.pKnow)
  })

  it('仕様の式どおりに計算する（四択・正解）', () => {
    const s = base({ pKnow: 0.3 })
    const g = GUESS.mcq4, sl = SLIP_NORMAL
    const num = 0.3 * (1 - sl)
    const post = num / (num + 0.7 * g)
    expect(updateKcState(s, facts()).pKnow).toBeCloseTo(post + (1 - post) * 0.1, 12)
  })

  it('guess が低い形式ほど正解の情報量が大きい', () => {
    const s = base()
    const mcq = updateKcState(s, facts({ format: 'mcq4' })).pKnow
    const fc = updateKcState(s, facts({ format: 'flashcard' })).pKnow
    const tf = updateKcState(s, facts({ format: 'tf' })).pKnow
    expect(fc).toBeGreaterThan(mcq)
    expect(mcq).toBeGreaterThan(tf)
  })

  it('p_know は常に (0,1) に収まる', () => {
    let s = base({ pKnow: 0.99 })
    for (let i = 0; i < 50; i++) s = updateKcState(s, facts({ correct: i % 3 !== 0 }))
    expect(s.pKnow).toBeGreaterThan(0)
    expect(s.pKnow).toBeLessThan(1)
  })

  it('遭遇による学習で、誤答しても p_know は 0 に落ち切らない', () => {
    let s = base({ pKnow: 0.5 })
    for (let i = 0; i < 30; i++) s = updateKcState(s, facts({ correct: false, latencyMs: 9000 }))
    expect(s.pKnow).toBeGreaterThan(0.05)
  })
})

describe('§1.1 slip', () => {
  it('即答の誤答はケアレス寄り（slip が上がる）', () => {
    expect(slipRate(false, 900)).toBe(SLIP_FAST)
    expect(slipRate(false, 9000)).toBe(SLIP_NORMAL)
    expect(slipRate(true, 900)).toBe(SLIP_NORMAL)
  })
  it('即答の誤答は p_know を下げすぎない', () => {
    const s = base({ pKnow: 0.6 })
    const fast = updateKcState(s, facts({ correct: false, latencyMs: 500 })).pKnow
    const slow = updateKcState(s, facts({ correct: false, latencyMs: 9000 })).pKnow
    expect(fast).toBeGreaterThan(slow)
  })
})

describe('§1.2 n_eff — 推測正解の割引', () => {
  it('四択の正解は 0.75 しか増えない', () => {
    expect(updateKcState(base(), facts({ format: 'mcq4' })).nEff).toBeCloseTo(0.75, 12)
  })
  it('フラッシュカードの正解は 0.98 増える', () => {
    expect(updateKcState(base(), facts({ format: 'flashcard' })).nEff).toBeCloseTo(0.98, 12)
  })
  it('正誤判定の正解は 0.5 しか増えない', () => {
    expect(updateKcState(base(), facts({ format: 'tf' })).nEff).toBeCloseTo(0.5, 12)
  })
  it('誤答は形式によらず満額の証拠', () => {
    for (const format of ['mcq4', 'flashcard', 'tf'] as const) {
      expect(updateKcState(base(), facts({ correct: false, format, latencyMs: 9000 })).nEff).toBeCloseTo(1, 12)
    }
  })
  it('weight が効く（副次的な KC は証拠も少ない）', () => {
    expect(updateKcState(base(), facts({ weight: 0.5 })).nEff).toBeCloseTo(0.375, 12)
  })
  it('四択の正解だけでは mastered に必要な n_eff=3 に4回かかる', () => {
    let s = base()
    for (let i = 0; i < 3; i++) s = updateKcState(s, facts())
    expect(s.nEff).toBeLessThan(3) // 2.25
    s = updateKcState(s, facts())
    expect(s.nEff).toBeGreaterThanOrEqual(3)
  })
})

describe('§1.1 Elo（θ のみ）', () => {
  it('正解で θ が上がり、誤答で下がる', () => {
    const s = base()
    expect(updateKcState(s, facts({ correct: true })).theta).toBeGreaterThan(s.theta)
    expect(updateKcState(s, facts({ correct: false, latencyMs: 9000 })).theta).toBeLessThan(s.theta)
  })
  it('K が観測数で減衰する（初期は速く動き後で安定）', () => {
    const early = updateKcState(base({ nObs: 0 }), facts()).theta - THETA_0
    const late = updateKcState(base({ nObs: 100 }), facts()).theta - THETA_0
    expect(Math.abs(early)).toBeGreaterThan(Math.abs(late) * 3)
  })
  it('難しい KC を正解したときの方が θ が大きく動く', () => {
    const easy = updateKcState(base(), facts({ baseDifficulty: -2 })).theta
    const hard = updateKcState(base(), facts({ baseDifficulty: 2 })).theta
    expect(hard).toBeGreaterThan(easy)
  })
})

describe('§2 マスタリーの4状態', () => {
  const ev = { distinctCorrectDays: 2, hasNonFlashcardCorrect: true }

  it('n_eff が閾値未満なら unknown（初日に弱点120件を並べないため）', () => {
    const s = base({ nEff: N_EFF_UNKNOWN - 0.01, lastSeenAt: T0 })
    expect(masteryStatus(s, 0.99, ev)).toBe('unknown')
    expect(masteryStatus(s, 0.1, ev)).toBe('unknown')
  })

  it('mastery で weak / shaky / mastered に分かれる', () => {
    const s = base({ nEff: 5, lastSeenAt: T0 })
    expect(masteryStatus(s, 0.5, ev)).toBe('weak')
    expect(masteryStatus(s, 0.7, ev)).toBe('shaky')
    expect(masteryStatus(s, 0.9, ev)).toBe('mastered')
  })

  it('別日2回の条件を満たさなければ mastered にならない（分散学習）', () => {
    const s = base({ nEff: 5, lastSeenAt: T0 })
    expect(masteryStatus(s, 0.95, { ...ev, distinctCorrectDays: 1 })).toBe('shaky')
  })

  it('フラッシュカードだけでは mastered にならない（「わかった」連打対策）', () => {
    const s = base({ nEff: 5, lastSeenAt: T0 })
    expect(masteryStatus(s, 0.95, { ...ev, hasNonFlashcardCorrect: false })).toBe('shaky')
  })

  it('n_eff が 3 未満なら mastered にならない', () => {
    const s = base({ nEff: 2.9, lastSeenAt: T0 })
    expect(masteryStatus(s, 0.95, ev)).toBe('shaky')
  })

  it('忘却で mastery が下がる', () => {
    const s = base({ pKnow: 0.95, lastSeenAt: T0 })
    const now = new Date(T0.getTime() + 30 * DAY)
    expect(mastery(s, 10, now)).toBeLessThan(mastery(s, 10, T0))
  })

  it('一度も解いていなければ p_know がそのまま mastery になる', () => {
    expect(mastery(base({ pKnow: 0.42 }), 0, T0)).toBe(0.42)
  })
})

describe('§5.4 冷スタートの事前分布', () => {
  it('exam_weight が高いほど事前の p_know も高い', () => {
    expect(initialKcState(1).pKnow).toBeGreaterThan(initialKcState(0).pKnow)
  })
  it('[0.10, 0.45] にクリップされる', () => {
    for (const w of [-5, 0, 0.5, 1, 5]) {
      const p = initialKcState(w).pKnow
      expect(p).toBeGreaterThanOrEqual(0.1)
      expect(p).toBeLessThanOrEqual(0.45)
    }
  })
  it('診断直後は n_eff=0 なので全 KC が unknown（測っていないものを断定しない §5.5）', () => {
    const s = initialKcState(1)
    expect(s.nEff).toBe(0)
    expect(masteryStatus(s, 0.9, { distinctCorrectDays: 9, hasNonFlashcardCorrect: true })).toBe('unknown')
  })
})

describe('04b §4.1 客観形式の q', () => {
  const o = (over: Partial<Parameters<typeof objectiveGrade>[0]> = {}) =>
    objectiveGrade({ correct: true, latencyMs: 5000, pKnowBefore: 0.5, misconceptionHit: false, format: 'mcq4', ...over })

  it('p_know が低い KC の正解は推測を疑って q=3 に留める', () => {
    expect(o({ pKnowBefore: 0.1 })).toBe(3)
    expect(o({ pKnowBefore: 0.24 })).toBe(3)
  })
  it('中間は q=4', () => {
    expect(o({ pKnowBefore: 0.25 })).toBe(4)
    expect(o({ pKnowBefore: 0.5 })).toBe(4)
    expect(o({ pKnowBefore: 0.74 })).toBe(4)
  })
  it('p_know が高い KC の正解は強い証拠 q=5', () => {
    // round は半数切り上げなので p=0.75 で 2p=1.5 → +2 となり境界はここ
    expect(o({ pKnowBefore: 0.75 })).toBe(5)
    expect(o({ pKnowBefore: 1 })).toBe(5)
  })
  it('中央値の1.5倍より遅い正解は1段下げる（3を下回らない）', () => {
    expect(o({ pKnowBefore: 0.9, latencyMs: 20_000 })).toBe(4)
    expect(o({ pKnowBefore: 0.1, latencyMs: 20_000 })).toBe(3)
  })
  it('誤概念の再発は q=0（最も強い EF 減衰）', () => {
    expect(o({ correct: false, misconceptionHit: true, latencyMs: 9000 })).toBe(0)
  })
  it('即答の誤りは q=1', () => {
    expect(o({ correct: false, latencyMs: 900 })).toBe(1)
  })
  it('通常の誤答は q=2', () => {
    expect(o({ correct: false, latencyMs: 9000 })).toBe(2)
  })
  it('誤概念は即答判定より優先される', () => {
    expect(o({ correct: false, misconceptionHit: true, latencyMs: 100 })).toBe(0)
  })
})

describe('04b §4.2 フラッシュカードの q', () => {
  it('4ボタンが 1/3/4/5 に対応する', () => {
    expect(flashcardGrade('unknown', 5000)).toBe(1)
    expect(flashcardGrade('vague', 5000)).toBe(3)
    expect(flashcardGrade('known', 5000)).toBe(4)
    expect(flashcardGrade('easy', 5000)).toBe(5)
  })
  it('答えを見て 800ms 未満の「わかった／余裕」は q=3 に丸める', () => {
    expect(flashcardGrade('known', SELF_DECEPTION_MS - 1)).toBe(3)
    expect(flashcardGrade('easy', 100)).toBe(3)
  })
  it('「わからない／あいまい」は丸めの対象外', () => {
    expect(flashcardGrade('unknown', 100)).toBe(1)
    expect(flashcardGrade('vague', 100)).toBe(3)
  })
})

describe('報酬ハック耐性（設計の要）', () => {
  it('四択を正解し続けても、mastered までに複数日と複数形式が要る', () => {
    let s = base()
    for (let i = 0; i < 20; i++) s = updateKcState(s, facts())
    const m = mastery(s, 6, T0)
    expect(m).toBeGreaterThan(0.85)
    // 四択だけ・1日だけでは mastered にならない
    expect(masteryStatus(s, m, { distinctCorrectDays: 1, hasNonFlashcardCorrect: true })).toBe('shaky')
    expect(masteryStatus(s, m, { distinctCorrectDays: 5, hasNonFlashcardCorrect: false })).toBe('shaky')
    expect(masteryStatus(s, m, { distinctCorrectDays: 5, hasNonFlashcardCorrect: true })).toBe('mastered')
  })
})
