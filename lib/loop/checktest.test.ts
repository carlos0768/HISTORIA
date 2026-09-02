import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import { seedMasters, SEED_DIR } from '@/scripts/db/seed'
import { createUser, createKcs, createDrill, createItem, createMaterial } from './fixture'
import { submitAnswer } from './answer'
import {
  testSize, pickKcs, buildCheckTest, gradeCheckTest,
  TEST_MIN, TEST_MAX, WEAK_PICK_RATIO,
} from './checktest'

/** 決まった順で数を返す。Fisher-Yates を決定的にするためのもの */
const seq = (xs: number[]): (() => number) => {
  let i = 0
  return () => xs[i++ % xs.length]!
}

describe('出題数（docs/06 §2.2）', () => {
  it('範囲の35%', () => {
    expect(testSize(40)).toBe(14)
    expect(testSize(60)).toBe(21)
  })

  it('小さい範囲でも下限を割らない', () => {
    expect(testSize(1)).toBe(TEST_MIN)
    expect(testSize(28)).toBe(TEST_MIN)
  })

  /** ★ 上限が無いと、200KC の特訓が70問になって誰も終わらせない */
  it('大きい範囲でも上限を超えない', () => {
    expect(testSize(200)).toBe(TEST_MAX)
    expect(testSize(1000)).toBe(TEST_MAX)
  })
})

describe('層化抽出（docs/06 §2.2）', () => {
  const ranked = Array.from({ length: 20 }, (_, i) => ({ kcId: `kc.${i}`, mastery: i / 20 }))

  /**
   * ★ この試験が §2.1 の主張そのものである。ランダムだと弱点層に寄らない。
   *   0 を返す乱数は Fisher-Yates を恒等写像にするので、選ばれるのは各層の先頭から。
   */
  it('7割を弱点層から引く', () => {
    const picked = pickKcs(ranked, 10, () => 0)
    expect(picked).toHaveLength(10)
    const weak = new Set(ranked.slice(0, 12).map(r => r.kcId))   // 弱い方から60% = 12件
    expect(picked.filter(k => weak.has(k))).toHaveLength(Math.round(10 * WEAK_PICK_RATIO))
  })

  /** ★ 習得層も測らないと「仕上げた」と言えないし、忘却を検出できない */
  it('習得層からも引く', () => {
    const picked = pickKcs(ranked, 10, () => 0)
    const strong = new Set(ranked.slice(12).map(r => r.kcId))
    expect(picked.filter(k => strong.has(k)).length).toBeGreaterThan(0)
  })

  it('同じ KC を2回出さない', () => {
    const picked = pickKcs(ranked, 20, seq([0.1, 0.9, 0.4, 0.7, 0.2]))
    expect(new Set(picked).size).toBe(picked.length)
  })

  /**
   * ★ 片方の層が薄いときに出題数を削らない。
   *   3件しかない特訓で「習得層が1件だから7問」になると、
   *   下限10問という約束が黙って破られる。
   */
  it('層が薄ければもう片方で埋める', () => {
    const thin = [
      { kcId: 'a', mastery: 0.1 }, { kcId: 'b', mastery: 0.2 },
      { kcId: 'c', mastery: 0.3 }, { kcId: 'd', mastery: 0.9 },
    ]
    const picked = pickKcs(thin, 4, () => 0)
    expect(picked).toHaveLength(4)
    expect(new Set(picked).size).toBe(4)
  })

  it('KC が足りなければ、ある分だけ返す（水増ししない）', () => {
    expect(pickKcs([{ kcId: 'a', mastery: 0.5 }], 10, () => 0)).toEqual(['a'])
    expect(pickKcs([], 10, () => 0)).toEqual([])
  })

  /** ★ 乱数を注入できないと「同じ状態で同じテストが出るか」を試験できない */
  it('同じ乱数なら同じ結果', () => {
    const a = pickKcs(ranked, 10, seq([0.3, 0.8, 0.1, 0.6]))
    const b = pickKcs(ranked, 10, seq([0.3, 0.8, 0.1, 0.6]))
    expect(a).toEqual(b)
  })
})

const dbSuite = TEST_DB_URL ? describe : describe.skip

dbSuite('確認テスト（実DB）', () => {
  let db: Sql
  let drop: () => Promise<void>
  const NOW = new Date('2026-09-15T03:00:00Z')
  const DEADLINE = new Date('2026-10-31T00:00:00Z')
  const UNIT = 'wh.2.1.1'
  let userId: string

  beforeAll(async () => {
    ({ db, drop } = await createTestDb('historia_checktest_test'))
    await seedMasters(db, SEED_DIR)
  }, 120_000)
  afterAll(async () => { await drop() })

  beforeEach(async () => {
    await db`TRUNCATE check_test, response, user_kc_state, kc_card, item_kc, item,
                      material_section, material, drill_kc, drill_unit, drill,
                      kc_syllabus_unit, kc, app_user RESTART IDENTITY CASCADE`
    userId = await createUser(db, NOW)
  })

  /** KC を n 件・それぞれに設問1本・教材1本を持つ特訓を作る */
  const setup = async (n: number, mode: 'ai_material' | 'self_study' = 'ai_material') => {
    const kcIds = Array.from({ length: n }, (_, i) => `kc.t.${i}`)
    await createKcs(db, kcIds, UNIT)
    await createMaterial(db, { userId: null, unitId: UNIT })
    const drillId = await createDrill(db, userId, kcIds, DEADLINE, UNIT, mode)
    const items: Record<string, string> = {}
    for (const kcId of kcIds) {
      items[kcId] = await createItem(db, { userId: null, kcs: [{ kcId }], answerKey: 'a', now: NOW })
    }
    return { drillId, kcIds, items }
  }

  it('開いた時点で item_ids が固定される', async () => {
    const { drillId } = await setup(12)
    const built = await buildCheckTest(db, userId, drillId, NOW, () => 0)
    expect(built.ok).toBe(true)
    if (!built.ok) return

    const [row] = await db<{ item_ids: string[]; total: number }[]>`
      SELECT item_ids, total FROM check_test WHERE id = ${built.testId}`
    expect(row!.item_ids).toEqual(built.itemIds)
    expect(row!.total).toBe(built.itemIds.length)
  })

  /**
   * ★ 出題順を混ぜる（§2.2 の shuffle）。混ぜないと弱点層→習得層の順に並び、
   *   「後半は易しい」と読めてしまう。
   */
  it('出題順は弱点層→習得層の並びのままではない', async () => {
    const { drillId, kcIds, items } = await setup(20)
    // ★ 弱点層は「弱い方から60%」＝20件中12件。ちょうど12件を誤答で弱くしておくと、
    //   層の境界と誤答の境界が一致し、「7問が弱点層・3問が習得層」に確定する。
    //   ここを10件にすると層の境界がずれ、混ぜていなくても順が入り交じって
    //   この試験が何も検出しなくなる（逆対照で確認済み）。
    const WEAK = 12
    for (const kcId of kcIds.slice(0, WEAK)) {
      for (let i = 0; i < 4; i++) {
        await submitAnswer(db, {
          userId, itemId: items[kcId]!, sessionKind: 'quiz', drillId: null,
          chosen: 'b', latencyMs: 4000, msSinceReveal: null,
          now: new Date(NOW.getTime() - (i + 20) * 86_400_000),
        })
      }
    }
    const byItem = new Map(Object.entries(items).map(([kc, item]) => [item, kc]))
    const built = await buildCheckTest(db, userId, drillId, NOW, seq([0.9, 0.2, 0.6, 0.1, 0.5]))
    expect(built.ok).toBe(true)
    if (!built.ok) return

    const weakFirst = built.itemIds.map(id => kcIds.indexOf(byItem.get(id)!) < WEAK)
    expect(weakFirst.filter(Boolean)).toHaveLength(7)   // 10問中7問が弱点層
    // 「弱点層が全部並んでから習得層」ではないこと
    const firstStrong = weakFirst.indexOf(false)
    expect(firstStrong).toBeGreaterThanOrEqual(0)
    expect(weakFirst.slice(firstStrong).includes(true)).toBe(true)
  })

  it('14日以内に解いた設問は出さない（docs/04b §5）', async () => {
    const { drillId, kcIds, items } = await setup(12)
    // 全部を昨日解いておく
    for (const kcId of kcIds) {
      await submitAnswer(db, {
        userId, itemId: items[kcId]!, sessionKind: 'quiz', drillId: null,
        chosen: 'a', latencyMs: 4000, msSinceReveal: null,
        now: new Date(NOW.getTime() - 86_400_000),
      })
    }
    const built = await buildCheckTest(db, userId, drillId, NOW, () => 0)
    expect(built.ok).toBe(false)
    if (built.ok) return
    expect(built.reason).toBe('no_items')
  })

  it('15日前に解いた設問は出してよい', async () => {
    const { drillId, kcIds, items } = await setup(12)
    for (const kcId of kcIds) {
      await submitAnswer(db, {
        userId, itemId: items[kcId]!, sessionKind: 'quiz', drillId: null,
        chosen: 'a', latencyMs: 4000, msSinceReveal: null,
        now: new Date(NOW.getTime() - 15 * 86_400_000),
      })
    }
    const built = await buildCheckTest(db, userId, drillId, NOW, () => 0)
    expect(built.ok).toBe(true)
  })

  /**
   * ★ 連続受験を許すと「さっきの問題を覚えているか」の測定になる（docs/06 §3.2）。
   */
  it('終わった直後は受けられない', async () => {
    const { drillId } = await setup(12)
    const first = await buildCheckTest(db, userId, drillId, NOW, () => 0)
    expect(first.ok).toBe(true)
    if (!first.ok) return
    await gradeCheckTest(db, userId, first.testId, NOW)

    const again = await buildCheckTest(db, userId, drillId, new Date(NOW.getTime() + 86_400_000), () => 0)
    expect(again.ok).toBe(false)
    if (again.ok) return
    expect(again.reason).toBe('cooldown')
    expect(again.nextAt!.getTime()).toBe(NOW.getTime() + 3 * 86_400_000)
  })

  it('3日空けば受けられる', async () => {
    const { drillId } = await setup(12)
    const first = await buildCheckTest(db, userId, drillId, NOW, () => 0)
    if (!first.ok) throw new Error('作れなかった')
    await gradeCheckTest(db, userId, first.testId, NOW)

    const later = new Date(NOW.getTime() + 3 * 86_400_000)
    expect((await buildCheckTest(db, userId, drillId, later, () => 0)).ok).toBe(true)
  })

  /** ★ 終わっていないテストは締切にしない。中断しただけで3日待たされる筋合いはない */
  it('終わっていないテストは待ち時間を作らない', async () => {
    const { drillId } = await setup(12)
    expect((await buildCheckTest(db, userId, drillId, NOW, () => 0)).ok).toBe(true)
    expect((await buildCheckTest(db, userId, drillId, NOW, () => 0)).ok).toBe(true)
  })

  /**
   * ★ ai_material は「教材が出来ている KC」だけを問う（docs/06 §2.2）。
   *   配っていない範囲を問うと、読んでいないものを問うことになる。
   */
  it('ai_material は教材の無い範囲を出さない', async () => {
    const kcIds = Array.from({ length: 12 }, (_, i) => `kc.t.${i}`)
    await createKcs(db, kcIds, UNIT)
    const drillId = await createDrill(db, userId, kcIds, DEADLINE, UNIT, 'ai_material')
    for (const kcId of kcIds) {
      await createItem(db, { userId: null, kcs: [{ kcId }], answerKey: 'a', now: NOW })
    }
    const built = await buildCheckTest(db, userId, drillId, NOW, () => 0)
    expect(built.ok).toBe(false)
  })

  it('自学（self_study）は教材が無くても出す', async () => {
    const kcIds = Array.from({ length: 12 }, (_, i) => `kc.t.${i}`)
    await createKcs(db, kcIds, UNIT)
    const drillId = await createDrill(db, userId, kcIds, DEADLINE, UNIT, 'self_study')
    for (const kcId of kcIds) {
      await createItem(db, { userId: null, kcs: [{ kcId }], answerKey: 'a', now: NOW })
    }
    expect((await buildCheckTest(db, userId, drillId, NOW, () => 0)).ok).toBe(true)
  })

  it('他人の特訓は作れない', async () => {
    const { drillId } = await setup(12)
    const other = await createUser(db, NOW)
    expect((await buildCheckTest(db, other, drillId, NOW, () => 0)).ok).toBe(false)
  })

  describe('採点', () => {
    const take = async (drillId: string, correctRatio: number, at = NOW) => {
      const built = await buildCheckTest(db, userId, drillId, at, () => 0)
      if (!built.ok) throw new Error(`作れなかった: ${built.reason}`)
      const n = Math.round(built.itemIds.length * correctRatio)
      for (const [i, itemId] of built.itemIds.entries()) {
        await submitAnswer(db, {
          userId, itemId, sessionKind: 'checktest', drillId: null,
          chosen: i < n ? 'a' : 'b', latencyMs: 4000, msSinceReveal: null, now: at,
        })
      }
      return built
    }

    it('素点は正解数、判定は mastery で出す（同じ数字を2つの式で出さない）', async () => {
      const { drillId } = await setup(12)
      const built = await take(drillId, 1)
      const g = (await gradeCheckTest(db, userId, built.testId, NOW))!
      expect(g.correct).toBe(built.itemIds.length)
      expect(g.rawScore).toBe(1)
      // 1日1回・1問正解しただけでは mastered にならない（docs/04 の条件）ので合格しない
      expect(g.verdict).toBe('retry')
    })

    /**
     * ★ 判定の分母は「このテストが出題対象とした KC」であって、特訓全体ではない
     *   （docs/06 §3.1）。全体を分母にすると、10単元の特訓の1単元めを満点で通しても
     *   進捗は 0.1 にしかならず、1回のテストでは構造的に合格に到達できない。
     */
    it('分母は出題した KC 集合であって、特訓全体ではない', async () => {
      const { drillId, kcIds, items } = await setup(40)
      // 出題対象に入りうる全 KC を、別日に何度も正解させて mastered に寄せる
      for (const kcId of kcIds) {
        for (let i = 0; i < 8; i++) {
          await submitAnswer(db, {
            userId, itemId: items[kcId]!, sessionKind: 'quiz', drillId: null,
            chosen: 'a', latencyMs: 4000, msSinceReveal: null,
            now: new Date(NOW.getTime() - (i + 20) * 86_400_000),
          })
        }
      }
      const built = await take(drillId, 1)
      const g = (await gradeCheckTest(db, userId, built.testId, NOW))!

      // 出題は40KC 中14問。特訓全体を分母にすれば progress は 0.35 止まりで
      // 'retry' にしかならないが、出題した KC だけを見れば合格になる
      expect(built.itemIds.length).toBeLessThan(kcIds.length)
      expect(g.progressAfter).toBeGreaterThan(0.85)
      expect(g.verdict).toBe('pass')
    })

    it('落とした KC を返す（翌日のキュー先頭に来る）', async () => {
      const { drillId } = await setup(12)
      const built = await take(drillId, 0)
      const g = (await gradeCheckTest(db, userId, built.testId, NOW))!
      expect(g.correct).toBe(0)
      expect(g.missedKcs).toHaveLength(built.itemIds.length)
      expect(g.missedKcs[0]!.label).toBeTruthy()
    })

    /** ★ 日々の出題（quiz）を確認テストの点に混ぜない。混ざると素点が水増しされる */
    it('quiz の解答は素点に入らない', async () => {
      const { drillId } = await setup(12)
      const built = await buildCheckTest(db, userId, drillId, NOW, () => 0)
      if (!built.ok) throw new Error('作れなかった')
      for (const itemId of built.itemIds) {
        await submitAnswer(db, {
          userId, itemId, sessionKind: 'quiz', drillId: null,
          chosen: 'a', latencyMs: 4000, msSinceReveal: null, now: NOW,
        })
      }
      const g = (await gradeCheckTest(db, userId, built.testId, NOW))!
      expect(g.correct).toBe(0)
    })

    /**
     * ★ 設問は14日経てば再出題されうる。item_id だけで解答を拾うと、
     *   前回の確認テストの解答が今回の点に混ざり、素点が total を超えることさえある。
     */
    it('前回の確認テストの解答を今回の点に数えない', async () => {
      const { drillId } = await setup(12)
      const first = await take(drillId, 0)                       // 全問誤答
      await gradeCheckTest(db, userId, first.testId, NOW)

      const later = new Date(NOW.getTime() + 20 * 86_400_000)    // 再出題禁止も冷却も明ける
      const second = await take(drillId, 1, later)               // 全問正解
      expect(second.itemIds.some(id => first.itemIds.includes(id))).toBe(true)

      const g = (await gradeCheckTest(db, userId, second.testId, later))!
      expect(g.correct).toBe(second.itemIds.length)
      expect(g.missedKcs).toHaveLength(0)
    })

    it('採点すると finished_at が入る', async () => {
      const { drillId } = await setup(12)
      const built = await take(drillId, 0.5)
      await gradeCheckTest(db, userId, built.testId, NOW)
      const [row] = await db<{ finished_at: Date | null; verdict: string | null }[]>`
        SELECT finished_at, verdict FROM check_test WHERE id = ${built.testId}`
      expect(row!.finished_at).not.toBeNull()
      expect(row!.verdict).not.toBeNull()
    })

    it('他人のテストは採点できない', async () => {
      const { drillId } = await setup(12)
      const built = await take(drillId, 1)
      const other = await createUser(db, NOW)
      expect(await gradeCheckTest(db, other, built.testId, NOW)).toBeNull()
    })
  })
})
