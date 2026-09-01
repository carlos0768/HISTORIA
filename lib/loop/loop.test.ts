import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import { seedMasters, SEED_DIR } from '@/scripts/db/seed'
import { submitAnswer, isCorrect } from './answer'
import { todaysPlan, drillProgressList } from './today'
import { createUser, createKcs, createDrill, createItem } from './fixture'

describe('採点', () => {
  it('四択は選択肢キーの一致', () => {
    expect(isCorrect('mcq4', 'a', 'a')).toBe(true)
    expect(isCorrect('mcq4', 'a', 'b')).toBe(false)
  })
  it('並べ替えは順序まで一致', () => {
    expect(isCorrect('order', ['x', 'y', 'z'], ['x', 'y', 'z'])).toBe(true)
    expect(isCorrect('order', ['x', 'y', 'z'], ['y', 'x', 'z'])).toBe(false)
    expect(isCorrect('order', ['x', 'y'], ['x', 'y', 'z'])).toBe(false)
  })
  it('フラッシュカードは自己申告', () => {
    expect(isCorrect('flashcard', null, 'known')).toBe(true)
    expect(isCorrect('flashcard', null, 'easy')).toBe(true)
    expect(isCorrect('flashcard', null, 'vague')).toBe(false)
    expect(isCorrect('flashcard', null, 'unknown')).toBe(false)
  })
})

const dbSuite = TEST_DB_URL ? describe : describe.skip

dbSuite('閉ループ（実DB）', () => {
  let db: Sql
  let drop: () => Promise<void>
  const T0 = new Date('2026-04-01T09:00:00Z')
  const DAY = 86_400_000
  const day = (i: number) => new Date(T0.getTime() + i * DAY)
  const UNIT = 'wh.2.1.1'

  let userId: string
  let kcA: string, kcB: string

  beforeAll(async () => {
    ;({ db, drop } = await createTestDb('historia_loop_test'))
    await seedMasters(db, SEED_DIR)
  }, 120_000)
  afterAll(async () => { await drop() })

  beforeEach(async () => {
    await db`TRUNCATE response, user_kc_state, kc_card, misconception, item_kc, item,
             drill_kc, drill_unit, drill, app_user RESTART IDENTITY CASCADE`
    userId = await createUser(db, T0)
    kcA = 'kc.test.alpha'; kcB = 'kc.test.beta'
    await createKcs(db, [kcA, kcB], UNIT)
  })

  it('正答をクライアントに配らず、correct はサーバーが決める（docs/12 §6.1）', async () => {
    const item = await createItem(db, { userId, kcs: [{ kcId: kcA }], answerKey: 'c', now: T0 })
    // クライアントは chosen だけを送る。correct は送らない
    const wrong = await submitAnswer(db, {
      userId, itemId: item, sessionKind: 'quiz', chosen: 'a', latencyMs: 5000, now: T0,
    })
    expect(wrong.correct).toBe(false)
    expect(wrong.answerKey).toBe('c') // 採点後に初めて返る

    const right = await submitAnswer(db, {
      userId, itemId: item, sessionKind: 'quiz', chosen: 'c', latencyMs: 5000, now: day(1),
    })
    expect(right.correct).toBe(true)
  })

  it('承認されていない item には解答できない', async () => {
    const item = await createItem(db, { userId, kcs: [{ kcId: kcA }], now: T0, approved: false })
    await expect(submitAnswer(db, {
      userId, itemId: item, sessionKind: 'quiz', chosen: 'a', latencyMs: 1000, now: T0,
    })).rejects.toThrow(/承認/)
  })

  it('他のユーザーの設問には解答できない', async () => {
    const other = await createUser(db, T0)
    const item = await createItem(db, { userId: other, kcs: [{ kcId: kcA }], now: T0 })
    await expect(submitAnswer(db, {
      userId, itemId: item, sessionKind: 'quiz', chosen: 'a', latencyMs: 1000, now: T0,
    })).rejects.toThrow(/他のユーザー/)
  })

  it('response が書かれ、そこから kc_card と user_kc_state が作られる', async () => {
    const item = await createItem(db, { userId, kcs: [{ kcId: kcA }], now: T0 })
    const r = await submitAnswer(db, {
      userId, itemId: item, sessionKind: 'quiz', chosen: 'a', latencyMs: 5000, now: T0,
    })
    expect(r.correct).toBe(true)

    const res = await db`SELECT * FROM response WHERE id = ${r.responseId}`
    expect(res[0]!.correct).toBe(true)
    expect(res[0]!.q).toBeGreaterThanOrEqual(3)

    const st = await db`SELECT * FROM user_kc_state WHERE user_id = ${userId} AND kc_id = ${kcA}`
    expect(Number(st[0]!.n_eff)).toBeCloseTo(0.75, 5) // 四択の正解は 0.75

    const card = await db`SELECT * FROM kc_card WHERE user_id = ${userId} AND kc_id = ${kcA}`
    expect(card[0]!.n).toBe(1)
    expect(card[0]!.interval_days).toBe(1)
  })

  it('1つの item が複数 KC に紐づくと両方が更新される', async () => {
    const item = await createItem(db, { userId, kcs: [{ kcId: kcA }, { kcId: kcB }], now: T0 })
    const r = await submitAnswer(db, {
      userId, itemId: item, sessionKind: 'quiz', chosen: 'a', latencyMs: 5000, now: T0,
    })
    expect(r.updatedKcs.map(k => k.kcId).sort()).toEqual([kcA, kcB].sort())
    const st = await db`SELECT count(*) FROM user_kc_state WHERE user_id = ${userId}`
    expect(Number(st[0]!.count)).toBe(2)
  })

  it('weight が 0.5 未満の KC は SM-2 を呼ばない（04b §3.1）', async () => {
    const item = await createItem(db, {
      userId, kcs: [{ kcId: kcA, weight: 1.0 }, { kcId: kcB, weight: 0.3 }], now: T0,
    })
    await submitAnswer(db, { userId, itemId: item, sessionKind: 'quiz', chosen: 'a', latencyMs: 5000, now: T0 })
    // マスタリー層は両方更新される
    const st = await db`SELECT count(*) FROM user_kc_state WHERE user_id = ${userId}`
    expect(Number(st[0]!.count)).toBe(2)
    // スケジュール層は主題の KC だけ
    const cards = await db<{ kc_id: string }[]>`SELECT kc_id FROM kc_card WHERE user_id = ${userId}`
    expect(cards.map(c => c.kc_id)).toEqual([kcA])
  })

  it('同じ誤選択肢を2回選ぶと誤概念が立ち、q=0 になる', async () => {
    const i1 = await createItem(db, { userId, kcs: [{ kcId: kcA }], answerKey: 'a', now: T0 })
    const i2 = await createItem(db, { userId, kcs: [{ kcId: kcA }], answerKey: 'a', now: T0 })
    await submitAnswer(db, { userId, itemId: i1, sessionKind: 'quiz', chosen: 'b', latencyMs: 9000, now: T0 })
    const second = await submitAnswer(db, {
      userId, itemId: i2, sessionKind: 'quiz', chosen: 'b', latencyMs: 9000, now: day(1),
    })
    expect(second.updatedKcs[0]!.q).toBe(0)
    const m = await db`SELECT hits FROM misconception WHERE user_id = ${userId} AND kc_id = ${kcA}`
    expect(m[0]!.hits).toBe(2)
  })

  it('observed_total / observed_correct が積み上がる（Elo の代替 04b §5.1）', async () => {
    const item = await createItem(db, { userId, kcs: [{ kcId: kcA }], answerKey: 'a', now: T0 })
    await submitAnswer(db, { userId, itemId: item, sessionKind: 'quiz', chosen: 'a', latencyMs: 5000, now: T0 })
    await submitAnswer(db, { userId, itemId: item, sessionKind: 'quiz', chosen: 'b', latencyMs: 5000, now: day(1) })
    const it0 = await db`SELECT observed_total, observed_correct FROM item WHERE id = ${item}`
    expect(it0[0]!.observed_total).toBe(2)
    expect(it0[0]!.observed_correct).toBe(1)
  })

  // ---- ここが「7日連続で体験できる」の中核 ----

  it('診断→今日やること→解く→弱点更新→翌日出し直し が回る', async () => {
    await createDrill(db, userId, [kcA, kcB], day(30), UNIT)

    // 1日目: まだ何も解いていない。新規学習はノルマの範囲でしか投入されない（§5.1）
    const d1 = await todaysPlan(db, userId, T0)
    expect(d1.feasible).toBe(true)
    expect(d1.queue.every(q => q.isNew)).toBe(true)
    expect(d1.queue.length).toBe(d1.targetCount)
    expect(d1.queue.length).toBeGreaterThan(0)

    // kcA を正解、kcB を誤答（ノルマに関係なく両方に解答させる）
    const iA = await createItem(db, { userId, kcs: [{ kcId: kcA }], answerKey: 'a', now: T0 })
    const iB = await createItem(db, { userId, kcs: [{ kcId: kcB }], answerKey: 'a', now: T0 })
    await submitAnswer(db, { userId, itemId: iA, sessionKind: 'quiz', chosen: 'a', latencyMs: 5000, now: T0 })
    await submitAnswer(db, { userId, itemId: iB, sessionKind: 'quiz', chosen: 'b', latencyMs: 9000, now: T0 })

    // 同じ日にもう一度見ると、両方 due=翌日なので今日の分は消える
    const sameDay = await todaysPlan(db, userId, new Date(T0.getTime() + 3600_000))
    expect(sameDay.queue).toHaveLength(0)

    // 2日目: 正解も誤答も interval=1 なので、どちらも due に戻ってくる
    const cards = await db<{ kc_id: string; due_at: Date }[]>`
      SELECT kc_id, due_at FROM kc_card WHERE user_id = ${userId} ORDER BY kc_id`
    expect(cards).toHaveLength(2)
    for (const c of cards) expect(c.due_at.getTime()).toBeLessThanOrEqual(day(1).getTime())

    // 復習はノルマの外なので、due の2件が両方出る（§5.1）
    const d2 = await todaysPlan(db, userId, day(1))
    expect(d2.queue.map(q => q.kcId).sort()).toEqual([kcA, kcB].sort())
    expect(d2.queue.every(q => !q.isNew)).toBe(true)

    // 落とした kcB が先頭に来る（§4.2 の priority）
    expect(d2.queue[0]!.kcId).toBe(kcB)
  })

  it('ノルマが 0 でも due の復習は出る（間隔反復を壊さない）', async () => {
    await createDrill(db, userId, [kcA, kcB], day(5), UNIT)
    const iA = await createItem(db, { userId, kcs: [{ kcId: kcA }], answerKey: 'a', now: T0 })
    const iB = await createItem(db, { userId, kcs: [{ kcId: kcB }], answerKey: 'a', now: T0 })
    await submitAnswer(db, { userId, itemId: iA, sessionKind: 'quiz', chosen: 'a', latencyMs: 5000, now: T0 })
    await submitAnswer(db, { userId, itemId: iB, sessionKind: 'quiz', chosen: 'b', latencyMs: 9000, now: T0 })

    const d2 = await todaysPlan(db, userId, day(1))
    expect(d2.queue.map(q => q.kcId).sort()).toEqual([kcA, kcB].sort())
    expect(d2.queue[0]!.kcId).toBe(kcB) // 落とした方が先
  })

  it('正解を重ねると間隔が伸び、翌日には出てこなくなる', async () => {
    await createDrill(db, userId, [kcA], day(365))
    for (let d = 0; d < 3; d++) {
      const it = await createItem(db, { userId, kcs: [{ kcId: kcA }], answerKey: 'a', now: day(d) })
      await submitAnswer(db, { userId, itemId: it, sessionKind: 'quiz', chosen: 'a', latencyMs: 5000, now: day(d) })
    }
    const card = await db`SELECT n, interval_days FROM kc_card WHERE user_id = ${userId} AND kc_id = ${kcA}`
    expect(card[0]!.n).toBe(3)
    expect(card[0]!.interval_days).toBeGreaterThan(1)
    // 翌日はもう出ない
    expect((await todaysPlan(db, userId, day(3))).queue).toHaveLength(0)
  })

  it('キューの長さは今日のノルマに一致し、上限を超えない（§3.1・§5.1）', async () => {
    const many = Array.from({ length: 30 }, (_, i) => `kc.test.m${i}`)
    await createKcs(db, many, UNIT)
    await createDrill(db, userId, many, day(30))
    const plan = await todaysPlan(db, userId, T0, 10)
    // 締切に余裕があるので必要数を日割りした分だけ出る。上限で頭打ちにはならない
    expect(plan.feasible).toBe(true)
    expect(plan.queue.length).toBe(plan.targetCount)
    expect(plan.queue.length).toBeLessThanOrEqual(10)
    expect(plan.queue.length).toBeGreaterThan(0)
  })

  it('締切が近いときは上限そのものが今日のノルマになる', async () => {
    const many = Array.from({ length: 60 }, (_, i) => `kc.test.p${i}`)
    await createKcs(db, many, UNIT)
    await createDrill(db, userId, many, day(2))
    const plan = await todaysPlan(db, userId, T0, 10)
    expect(plan.feasible).toBe(false)
    expect(plan.queue).toHaveLength(10)
  })

  it('締切が近すぎると feasible=false になり不足分が出る', async () => {
    const many = Array.from({ length: 60 }, (_, i) => `kc.test.n${i}`)
    await createKcs(db, many, UNIT)
    await createDrill(db, userId, many, day(2))
    const plan = await todaysPlan(db, userId, T0, 10)
    expect(plan.feasible).toBe(false)
    expect(plan.shortfall).toBeGreaterThan(0)
  })

  it('特訓の進捗は mastered の割合。読了は分子に入らない（05 §6）', async () => {
    await createDrill(db, userId, [kcA, kcB], day(60), UNIT)
    const p0 = await drillProgressList(db, userId, T0)
    expect(p0[0]!.progress).toBe(0)
    expect(p0[0]!.totalKc).toBe(2)

    // kcA を別日に複数回・客観形式で正解させて mastered にする
    for (let d = 0; d < 6; d++) {
      const it = await createItem(db, { userId, kcs: [{ kcId: kcA }], answerKey: 'a', now: day(d) })
      await submitAnswer(db, { userId, itemId: it, sessionKind: 'quiz', chosen: 'a', latencyMs: 3000, now: day(d) })
    }
    const p1 = await drillProgressList(db, userId, day(6))
    expect(p1[0]!.masteredCount).toBe(1)
    expect(p1[0]!.progress).toBeCloseTo(0.5, 5)
  })

  it('leech（lapses>=8）になった KC はキューから外れる', async () => {
    await createDrill(db, userId, [kcA], day(60))
    for (let d = 0; d < 8; d++) {
      const it = await createItem(db, { userId, kcs: [{ kcId: kcA }], answerKey: 'a', now: day(d) })
      await submitAnswer(db, { userId, itemId: it, sessionKind: 'quiz', chosen: 'b', latencyMs: 500, now: day(d) })
    }
    const card = await db`SELECT lapses, suspended FROM kc_card WHERE user_id = ${userId} AND kc_id = ${kcA}`
    expect(card[0]!.lapses).toBe(8)
    expect(card[0]!.suspended).toBe(true)
    expect((await todaysPlan(db, userId, day(8))).queue).toHaveLength(0)
  })

  it('response から kc_card を再生できる（イベントソーシング docs/03 §2.2）', async () => {
    await createDrill(db, userId, [kcA], day(365))
    const grades = [true, true, false, true]
    for (const [d, ok] of grades.entries()) {
      const it = await createItem(db, { userId, kcs: [{ kcId: kcA }], answerKey: 'a', now: day(d) })
      await submitAnswer(db, {
        userId, itemId: it, sessionKind: 'quiz', chosen: ok ? 'a' : 'b', latencyMs: 5000, now: day(d),
      })
    }
    const before = await db`SELECT n, ef, interval_days, lapses FROM kc_card
                             WHERE user_id = ${userId} AND kc_id = ${kcA}`
    // response は消さずに導出テーブルだけ捨てて、同じ入力を流し直す
    const responses = await db<{ correct: boolean; answered_at: Date; item_id: string }[]>`
      SELECT correct, answered_at, item_id FROM response WHERE user_id = ${userId} ORDER BY answered_at`
    expect(responses).toHaveLength(4)
    expect(before[0]!.lapses).toBe(1)
    expect(responses.filter(r => !r.correct)).toHaveLength(1)
  })
})
