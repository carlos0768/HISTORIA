import { describe, it, expect } from 'vitest'
import {
  repsLeft, remainingReps, dailyPlan, dailyQueue, priority, urgency,
  drillProgress, drillState, overlapRatio, daysBetween,
  DEFAULT_MAX_DAILY, DRILL_COMPLETE_PROGRESS,
  type ScheduledKc, type QueueCandidate,
} from './scheduler'
import { verdict, canRetest, rawScore, RETEST_COOLDOWN_DAYS } from './assessment'
import { newKcCard, type KcCard } from './sm2'
import type { MasteryStatus } from './weakness'

const DAY = 86_400_000
const T0 = new Date('2026-04-01T00:00:00Z')
const day = (i: number) => new Date(T0.getTime() + i * DAY)
const card = (o: Partial<KcCard> = {}): KcCard => ({ ...newKcCard(T0), ...o })

const kc = (id: string, o: Partial<ScheduledKc> = {}): ScheduledKc => ({
  kcId: id, card: card(), status: 'unknown', earliestDeadline: day(30), ...o,
})

describe('§3 reps_left', () => {
  it('新規カードは締切まで日数があるほど多くの復習が要る', () => {
    const near = repsLeft(card(), day(10), T0)
    const far = repsLeft(card(), day(200), T0)
    expect(far).toBeGreaterThan(near)
  })

  it('既に必要な間隔に達していれば 0 回', () => {
    expect(repsLeft(card({ n: 5, intervalDays: 100 }), day(30), T0)).toBe(0)
  })

  it('締切が近すぎる（残り3日以内）なら、未学習は1回・学習済みは0回', () => {
    expect(repsLeft(card({ intervalDays: 0 }), day(2), T0)).toBe(1)
    expect(repsLeft(card({ intervalDays: 6, n: 2 }), day(2), T0)).toBe(0)
  })

  it('EF が低いほど多くの回数が要る（間隔が伸びにくい）', () => {
    const lowEf = repsLeft(card({ ef: 1.3 }), day(100), T0)
    const highEf = repsLeft(card({ ef: 2.5 }), day(100), T0)
    expect(lowEf).toBeGreaterThan(highEf)
  })

  it('EF 下限 1.3 でゼロ除算にならない', () => {
    expect(Number.isFinite(repsLeft(card({ ef: 1.3 }), day(365), T0))).toBe(true)
  })

  it('n の段階で分岐する（1回目は 1 日、2回目は 6 日から始まる）', () => {
    // n=0 は interval 1 から、n=1 は 6 から積み上がるので n=1 の方が少なくて済む
    expect(repsLeft(card({ n: 1 }), day(100), T0)).toBeLessThan(repsLeft(card({ n: 0 }), day(100), T0))
  })
})

describe('§3 remaining_reps', () => {
  it('mastered な KC は数えない', () => {
    const all = remainingReps([kc('a'), kc('b')], T0)
    const one = remainingReps([kc('a'), kc('b', { status: 'mastered' })], T0)
    expect(one).toBeLessThan(all)
  })

  it('複数の特訓が同じ KC を含んでも重複計上しない（集合が KC 単位なので自然に消える）', () => {
    // 呼び出し側が union を渡す前提。同じ kcId を2つ渡すのは呼び出し側のバグだが、
    // 単位が KC であることの意味をここで示す
    const union = [kc('a'), kc('b')]
    const withDup = [kc('a'), kc('b'), kc('a')]
    expect(remainingReps(union, T0)).toBeLessThan(remainingReps(withDup, T0))
  })

  it('KC が無ければ 0', () => {
    expect(remainingReps([], T0)).toBe(0)
  })
})

describe('§3.1 1日のノルマ', () => {
  it('必要数を残り日数で割る', () => {
    const kcs = Array.from({ length: 10 }, (_, i) => kc(`k${i}`, { earliestDeadline: day(30) }))
    const p = dailyPlan(kcs, T0, DEFAULT_MAX_DAILY)
    expect(p.target).toBe(Math.ceil(p.need / p.daysLeft))
    expect(p.feasible).toBe(true)
  })

  it('上限を超えたら feasible=false にして不足分を出す（黙って丸めない §3.2）', () => {
    const kcs = Array.from({ length: 400 }, (_, i) => kc(`k${i}`, { earliestDeadline: day(4) }))
    const p = dailyPlan(kcs, T0, DEFAULT_MAX_DAILY)
    expect(p.feasible).toBe(false)
    expect(p.target).toBe(DEFAULT_MAX_DAILY)
    expect(p.shortfall).toBeGreaterThan(0)
    expect(p.shortfall).toBe(p.need - DEFAULT_MAX_DAILY * p.daysLeft)
  })

  it('max_daily_items を上げると feasible になりうる（§9.1 の可変上限）', () => {
    const kcs = Array.from({ length: 120 }, (_, i) => kc(`k${i}`, { earliestDeadline: day(10) }))
    expect(dailyPlan(kcs, T0, 10).feasible).toBe(false)
    expect(dailyPlan(kcs, T0, 300).feasible).toBe(true)
  })

  it('サボった翌日は days_left が減って required が上がる（§4 これが再計画）', () => {
    const kcs = Array.from({ length: 30 }, (_, i) => kc(`k${i}`, { earliestDeadline: day(30) }))
    const d0 = dailyPlan(kcs, T0, DEFAULT_MAX_DAILY)
    const d10 = dailyPlan(kcs, day(10), DEFAULT_MAX_DAILY)
    expect(d10.daysLeft).toBeLessThan(d0.daysLeft)
    expect(d10.target).toBeGreaterThan(d0.target)
  })

  it('締切当日でも days_left は最低 1（ゼロ除算にしない）', () => {
    const p = dailyPlan([kc('a', { earliestDeadline: T0 })], T0, DEFAULT_MAX_DAILY)
    expect(p.daysLeft).toBe(1)
  })
})

describe('§4.2 overdue の山崩し', () => {
  const cand = (id: string, o: Partial<QueueCandidate> = {}): QueueCandidate => ({
    kcId: id, card: card({ dueAt: T0 }), status: 'weak', earliestDeadline: day(30),
    mastery: 0.5, isMisconception: false, ...o,
  })

  it('常に MAX_DAILY 件で打ち切る（初日に300問並べない）', () => {
    const cs = Array.from({ length: 300 }, (_, i) => cand(`k${i}`))
    expect(dailyQueue(cs, T0, DEFAULT_MAX_DAILY)).toHaveLength(DEFAULT_MAX_DAILY)
  })

  it('due が来ていないカードは出さない', () => {
    const cs = [cand('a', { card: card({ dueAt: day(5) }) }), cand('b')]
    expect(dailyQueue(cs, T0, 80).map(c => c.kcId)).toEqual(['b'])
  })

  it('suspended（leech）は出さない', () => {
    const cs = [cand('a', { card: card({ dueAt: T0, suspended: true }) }), cand('b')]
    expect(dailyQueue(cs, T0, 80).map(c => c.kcId)).toEqual(['b'])
  })

  it('誤概念が最優先', () => {
    const cs = [cand('plain'), cand('misc', { isMisconception: true })]
    expect(dailyQueue(cs, T0, 80)[0]!.kcId).toBe('misc')
  })

  it('締切が近いものが優先される', () => {
    const cs = [cand('far', { earliestDeadline: day(60) }), cand('near', { earliestDeadline: day(1) })]
    expect(dailyQueue(cs, T0, 80)[0]!.kcId).toBe('near')
  })

  it('mastery が低いものが優先される', () => {
    const cs = [cand('strong', { mastery: 0.9 }), cand('weak', { mastery: 0.1 })]
    expect(dailyQueue(cs, T0, 80)[0]!.kcId).toBe('weak')
  })

  it('最も昔にサボった簡単なカードが先頭に来ない（overdue 日数だけで並べない）', () => {
    const old = cand('old-easy', { card: card({ dueAt: day(-200) }), mastery: 0.84, earliestDeadline: day(60) })
    const fresh = cand('new-hard', { card: card({ dueAt: T0 }), mastery: 0.05, earliestDeadline: day(2) })
    expect(dailyQueue([old, fresh], T0, 80)[0]!.kcId).toBe('new-hard')
  })

  it('overdue の寄与は 14 日で頭打ち', () => {
    const a = priority(cand('a', { card: card({ dueAt: day(-14) }) }), T0)
    const b = priority(cand('b', { card: card({ dueAt: day(-200) }) }), T0)
    expect(a).toBeCloseTo(b, 10)
  })

  it('同点なら kcId で決定的に並ぶ（再実行で順序が変わらない）', () => {
    const cs = [cand('z'), cand('a'), cand('m')]
    expect(dailyQueue(cs, T0, 80).map(c => c.kcId)).toEqual(['a', 'm', 'z'])
  })

  it('urgency は締切超過で 1、14 日以上先で 0', () => {
    expect(urgency(day(-1), T0)).toBe(1)
    expect(urgency(T0, T0)).toBe(1)
    expect(urgency(day(14), T0)).toBe(0)
    expect(urgency(day(100), T0)).toBe(0)
  })
})

describe('§6 進捗の定義', () => {
  const st = (n: number, s: MasteryStatus): MasteryStatus[] => Array(n).fill(s)

  it('mastered の割合。教材の読了は分子に入らない', () => {
    expect(drillProgress([...st(3, 'mastered'), ...st(7, 'weak')])).toBeCloseTo(0.3, 10)
  })
  it('shaky は分子に入らない', () => {
    expect(drillProgress(st(10, 'shaky'))).toBe(0)
  })
  it('KC が無ければ 0（ゼロ除算にしない）', () => {
    expect(drillProgress([])).toBe(0)
  })

  it('0.90 以上かつ締切前で completed（100% は要求しない §6.1）', () => {
    expect(drillState(DRILL_COMPLETE_PROGRESS, day(30), T0)).toBe('completed')
    expect(drillState(0.89, day(30), T0)).toBe('active')
  })
  it('締切を過ぎたら completed にせず overdue（履歴を消さない）', () => {
    expect(drillState(0.5, day(-1), T0)).toBe('overdue')
    expect(drillState(0.95, day(-1), T0)).toBe('overdue')
  })
})

describe('§5.3 重複警告', () => {
  it('重複割合を返す', () => {
    expect(overlapRatio(['a', 'b', 'c', 'd'], new Set(['a', 'b']))).toBe(0.5)
  })
  it('空なら 0', () => {
    expect(overlapRatio([], new Set(['a']))).toBe(0)
  })
})

describe('06 §3 確認テストの合否', () => {
  const st = (mastered: number, total: number): MasteryStatus[] =>
    [...Array(mastered).fill('mastered'), ...Array(total - mastered).fill('weak')]

  it('0.85 以上で合格', () => expect(verdict(st(85, 100))).toBe('pass'))
  it('0.60 以上 0.85 未満でもう少し', () => {
    expect(verdict(st(60, 100))).toBe('almost')
    expect(verdict(st(84, 100))).toBe('almost')
  })
  it('0.60 未満で要復習', () => expect(verdict(st(59, 100))).toBe('retry'))

  it('1単元めのテストを満点で通せば合格になる（分母がテスト対象KCに限られている）', () => {
    // 特訓は 10 単元 × 5KC = 50KC。テストは1単元 5KC。全部 mastered にした
    const testedKcs = st(5, 5)
    expect(verdict(testedKcs)).toBe('pass')
    // 特訓全体を分母にすると 5/50 = 0.10 で永久に合格できない
    expect(drillProgress([...st(5, 5), ...Array(45).fill('unknown')])).toBeCloseTo(0.1, 10)
  })

  it('合格(0.85)と特訓の完了(0.90)は別物。0.85〜0.90 は合格だが未完了', () => {
    const s = st(87, 100)
    expect(verdict(s)).toBe('pass')
    expect(drillState(drillProgress(s), day(30), T0)).toBe('active')
  })

  it('素点は表示専用で判定には使わない', () => {
    expect(rawScore(18, 22)).toBeCloseTo(0.818, 3)
    expect(rawScore(0, 0)).toBe(0)
  })

  it(`再テストは ${RETEST_COOLDOWN_DAYS} 日空ける`, () => {
    expect(canRetest(null, T0)).toBe(true)
    expect(canRetest(T0, day(2))).toBe(false)
    expect(canRetest(T0, day(3))).toBe(true)
  })
})

describe('daysBetween', () => {
  it('日数差を切り捨てで返す', () => {
    expect(daysBetween(T0, day(5))).toBe(5)
    expect(daysBetween(T0, new Date(T0.getTime() + 5 * DAY + 3600_000))).toBe(5)
    expect(daysBetween(day(5), T0)).toBe(-5)
  })
})
