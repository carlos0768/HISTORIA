import { describe, it, expect } from 'vitest'
import {
  sm2Update, newKcCard, jitterFromSeed, retrievability,
  MAX_INTERVAL_DAYS, MIN_EF, LEECH_THRESHOLD,
  type KcCard, type Grade,
} from './sm2'

const DAY = 86_400_000
const T0 = new Date('2026-04-01T00:00:00Z')
const day = (i: number) => new Date(T0.getTime() + i * DAY)

/** 締切もゆらぎも無い素の連続適用。docs/04b §8 の前提に合わせる */
function run(grades: Grade[], card: KcCard = newKcCard(T0)) {
  const rows: Array<{ q: Grade; n: number; ef: number; intervalDays: number; lapses: number; suspended: boolean }> = []
  let c = card
  grades.forEach((q, i) => {
    c = sm2Update({ card: c, q, deadline: null, today: day(i), jitter: 0 }).card
    rows.push({ q, n: c.n, ef: Math.round(c.ef * 100) / 100, intervalDays: c.intervalDays, lapses: c.lapses, suspended: c.suspended })
  })
  return rows
}

// ---- docs/04b-spaced-repetition.md §8「この表の通りに実装されていること」----

describe('§8 ケース1: 全問 q=4', () => {
  const rows = run(Array(8).fill(4) as Grade[])
  const expected = [
    { n: 1, ef: 2.5, intervalDays: 1 },
    { n: 2, ef: 2.5, intervalDays: 6 },
    { n: 3, ef: 2.5, intervalDays: 15 },
    { n: 4, ef: 2.5, intervalDays: 38 },
    { n: 5, ef: 2.5, intervalDays: 95 },
    { n: 6, ef: 2.5, intervalDays: 238 },
    { n: 7, ef: 2.5, intervalDays: 365 },
    { n: 8, ef: 2.5, intervalDays: 365 },
  ]
  expected.forEach((e, i) => {
    it(`${i + 1}回目 → n=${e.n} EF=${e.ef} interval=${e.intervalDays}`, () => {
      expect(rows[i]).toMatchObject(e)
    })
  })
  it('7回目で上限 365 にクリップされる', () => {
    expect(rows[6]!.intervalDays).toBe(MAX_INTERVAL_DAYS)
  })
})

describe('§8 ケース2: q=4 と q=2 の交互（ease hell）', () => {
  const rows = run([4, 2, 4, 2, 4, 2, 4, 2] as Grade[])
  const expected = [
    { n: 1, ef: 2.5, intervalDays: 1, lapses: 0 },
    { n: 0, ef: 2.18, intervalDays: 1, lapses: 1 },
    { n: 1, ef: 2.18, intervalDays: 1, lapses: 1 },
    { n: 0, ef: 1.86, intervalDays: 1, lapses: 2 },
    { n: 1, ef: 1.86, intervalDays: 1, lapses: 2 },
    { n: 0, ef: 1.54, intervalDays: 1, lapses: 3 },
    { n: 1, ef: 1.54, intervalDays: 1, lapses: 3 },
    { n: 0, ef: 1.3, intervalDays: 1, lapses: 4 },
  ]
  expected.forEach((e, i) => {
    it(`${i + 1}回目 → n=${e.n} EF=${e.ef} lapses=${e.lapses}`, () => {
      expect(rows[i]).toMatchObject(e)
    })
  })
  it('n が 2 に到達しないため間隔が永久に 1 日から伸びない', () => {
    expect(rows.every(r => r.intervalDays === 1)).toBe(true)
    expect(Math.max(...rows.map(r => r.n))).toBe(1)
  })
  it('8回目は素の値 1.22 が下限 1.30 にクリップされる', () => {
    expect(rows[7]!.ef).toBe(MIN_EF)
  })
})

describe('§8 ケース3: 連続失敗（全問 q=1）', () => {
  const rows = run(Array(8).fill(1) as Grade[])
  it('1回目 EF=1.96', () => expect(rows[0]).toMatchObject({ n: 0, ef: 1.96, lapses: 1, suspended: false }))
  it('2回目 EF=1.42', () => expect(rows[1]).toMatchObject({ n: 0, ef: 1.42, lapses: 2, suspended: false }))
  it('3回目 素の値 0.88 が 1.30 にクリップ', () => expect(rows[2]).toMatchObject({ n: 0, ef: 1.3, lapses: 3, suspended: false }))
  it('4〜7回目は 1.30 のまま suspended にならない', () => {
    for (let i = 3; i <= 6; i++) expect(rows[i]).toMatchObject({ ef: 1.3, lapses: i + 1, suspended: false })
  })
  it(`8回目で lapses=${LEECH_THRESHOLD} に達し suspended になる`, () => {
    expect(rows[7]).toMatchObject({ lapses: LEECH_THRESHOLD, suspended: true })
  })
})

// ---- §3 EF の増減値 ----

describe('§3 EF の増減値', () => {
  const table: Array<[Grade, number]> = [[5, 0.1], [4, 0], [3, -0.14], [2, -0.32], [1, -0.54], [0, -0.8]]
  for (const [q, delta] of table) {
    it(`q=${q} → ΔEF=${delta}`, () => {
      // 下限クリップに当たらないよう EF に余裕を持たせる
      const card = { ...newKcCard(T0), ef: 2.5 }
      const { card: next } = sm2Update({ card, q, deadline: null, today: T0, jitter: 0 })
      expect(next.ef).toBeCloseTo(2.5 + delta, 10)
    })
  }
})

// ---- §3 締切クランプ ----

describe('§3 締切クランプ', () => {
  const card: KcCard = { n: 5, ef: 2.5, intervalDays: 95, dueAt: T0, lapses: 0, suspended: false, lastReviewAt: null }

  it('自然な次回が締切-3日を越えるとクランプされる', () => {
    const r = sm2Update({ card, q: 4, deadline: day(30), today: T0, jitter: 0 })
    expect(r.clamped).toBe(true)
    expect(r.card.dueAt.getTime()).toBe(day(27).getTime()) // 締切 30日目 の3日前
  })

  it('クランプ時は interval も ef も更新しない（§6）', () => {
    const r = sm2Update({ card, q: 3, deadline: day(30), today: T0, jitter: 0 })
    expect(r.clamped).toBe(true)
    expect(r.card.intervalDays).toBe(card.intervalDays)
    expect(r.card.ef).toBe(card.ef) // q=3 なら本来 -0.14 されるところ
  })

  it('クランプ後の due が今日以前にならない（締切を過ぎていても翌日に出す）', () => {
    const r = sm2Update({ card, q: 4, deadline: day(1), today: day(10), jitter: 0 })
    expect(r.card.dueAt.getTime()).toBe(day(11).getTime())
  })

  it('締切に余裕があればクランプしない', () => {
    const r = sm2Update({ card, q: 4, deadline: day(3650), today: T0, jitter: 0 })
    expect(r.clamped).toBe(false)
    expect(r.card.intervalDays).toBe(238)
  })

  it('n と lapses はクランプ時も更新する（想起の事実は記録する）', () => {
    const r = sm2Update({ card, q: 2, deadline: day(30), today: T0, jitter: 0 })
    expect(r.card.n).toBe(0)
    expect(r.card.lapses).toBe(1)
  })
})

// ---- §3 ゆらぎ ----

describe('§3 ゆらぎ', () => {
  it('同じ種からは常に同じ値が出る（再計算で due_at がぶれない）', () => {
    expect(jitterFromSeed(12345)).toBe(jitterFromSeed(12345))
    expect(jitterFromSeed('abc')).toBe(jitterFromSeed('abc'))
  })
  it('[-0.05, +0.05] に収まる', () => {
    for (let i = 0; i < 2000; i++) {
      const j = jitterFromSeed(i)
      expect(j).toBeGreaterThanOrEqual(-0.05)
      expect(j).toBeLessThanOrEqual(0.05)
    }
  })
  it('種が違えば散らばる（同じ日に山積みにならない）', () => {
    const vals = new Set(Array.from({ length: 500 }, (_, i) => jitterFromSeed(i)))
    expect(vals.size).toBeGreaterThan(450)
  })
  it('ゆらぎは interval_days には影響せず due_at だけを動かす', () => {
    const card: KcCard = { n: 2, ef: 2.5, intervalDays: 6, dueAt: T0, lapses: 0, suspended: false, lastReviewAt: null }
    const a = sm2Update({ card, q: 4, deadline: null, today: T0, jitter: 0.05 })
    const b = sm2Update({ card, q: 4, deadline: null, today: T0, jitter: -0.05 })
    expect(a.card.intervalDays).toBe(b.card.intervalDays)
    expect(a.card.dueAt.getTime()).not.toBe(b.card.dueAt.getTime())
  })
})

// ---- §6 忘却曲線 ----

describe('§6 忘却曲線', () => {
  it('間隔ちょうどで想起確率 0.9', () => {
    expect(retrievability(10, 10)).toBeCloseTo(0.9, 10)
  })
  it('解いた直後は 1.0', () => {
    expect(retrievability(10, 0)).toBe(1)
  })
  it('時間が経つほど単調に下がる', () => {
    let prev = 1
    for (let d = 1; d <= 60; d++) {
      const r = retrievability(10, d)
      expect(r).toBeLessThan(prev)
      prev = r
    }
  })
})

// ---- §9 実装上の注意 ----

describe('§9 実装上の注意', () => {
  it('引数の card を書き換えない（response からの再生が壊れないこと）', () => {
    const card = newKcCard(T0)
    const before = { ...card }
    sm2Update({ card, q: 5, deadline: null, today: T0, jitter: 0 })
    expect(card).toEqual(before)
  })

  it('response を昇順に再生すると同じ状態になる', () => {
    const grades: Grade[] = [4, 5, 2, 4, 3, 1, 4, 4]
    const replay = (gs: Grade[]) => {
      let c = newKcCard(T0)
      gs.forEach((q, i) => { c = sm2Update({ card: c, q, deadline: null, today: day(i), jitter: jitterFromSeed(i) }).card })
      return c
    }
    expect(replay(grades)).toEqual(replay(grades))
  })

  it('一度 suspended になったら以降の解答で解除されない（教材への導線は別経路）', () => {
    let c: KcCard = { ...newKcCard(T0), lapses: 7 }
    c = sm2Update({ card: c, q: 1, deadline: null, today: T0, jitter: 0 }).card
    expect(c.suspended).toBe(true)
    c = sm2Update({ card: c, q: 5, deadline: null, today: day(1), jitter: 0 }).card
    expect(c.suspended).toBe(true)
  })
})
