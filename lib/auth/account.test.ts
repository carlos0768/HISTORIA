import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import { seedMasters, SEED_DIR } from '@/scripts/db/seed'
import { createUser, createKcs, createDrill, createItem, createMaterial } from '@/lib/loop/fixture'
import { submitAnswer } from '@/lib/loop/answer'
import { deleteUserData, describeDeleted, DELETE_CONFIRMATION } from './account'

describe('削除の合言葉', () => {
  /** ★ 押し間違いで戻せないものを消させない */
  it('「削除します」でなければ一致しない', () => {
    const typed = (s: string) => s === DELETE_CONFIRMATION
    expect(DELETE_CONFIRMATION).toBe('削除します')
    expect(typed('削除')).toBe(false)
    expect(typed('はい')).toBe(false)
    expect(typed(' 削除します ')).toBe(false)   // 前後の空白も通さない
  })

  it('消した件数を読める文にする', () => {
    const s = describeDeleted({
      response: 12, drill: 1, checkTest: 2, material: 3,
      kcCard: 4, userKcState: 5, materialRead: 6,
    })
    expect(s).toContain('解答 12件')
    expect(s).toContain('確認テスト 2件')
  })
})

const dbSuite = TEST_DB_URL ? describe : describe.skip

dbSuite('アカウント削除（実DB・docs/10 §5.4）', () => {
  let db: Sql
  let drop: () => Promise<void>
  const NOW = new Date('2026-09-15T03:00:00Z')
  const UNIT = 'wh.2.1.1'
  let me: string
  let other: string

  beforeAll(async () => {
    ({ db, drop } = await createTestDb('historia_account_test'))
    await seedMasters(db, SEED_DIR)
  }, 120_000)
  afterAll(async () => { await drop() })

  /** 2人ぶんの学習データを作る。片方を消して、もう片方が残ることを見る */
  const setup = async (userId: string) => {
    const drillId = await createDrill(db, userId, ['kc.t.a'], new Date('2026-10-31'), UNIT)
    await createMaterial(db, { userId, unitId: UNIT })
    const item = await createItem(db, { userId: null, kcs: [{ kcId: 'kc.t.a' }], answerKey: 'a', now: NOW })
    await submitAnswer(db, {
      userId, itemId: item, sessionKind: 'quiz', drillId: null,
      chosen: 'b', latencyMs: 4000, msSinceReveal: null, now: NOW,
    })
    await db`
      INSERT INTO check_test (id, user_id, drill_id, item_ids, total, started_at)
      VALUES (gen_random_uuid(), ${userId}, ${drillId}, ${[item]}, 1, ${NOW})`
  }

  beforeEach(async () => {
    await db`TRUNCATE check_test, response, user_kc_state, kc_card, item_kc, item,
                      material_section, material, drill_kc, drill_unit, drill,
                      kc_syllabus_unit, kc, app_user RESTART IDENTITY CASCADE`
    await createKcs(db, ['kc.t.a'], UNIT)
    me = await createUser(db, NOW)
    other = await createUser(db, NOW)
    await setup(me)
    await setup(other)
  })

  const count = async (t: string, userId: string) => {
    const r = await db<{ n: string }[]>`SELECT count(*) AS n FROM ${db(t)} WHERE user_id = ${userId}`
    return Number(r[0]!.n)
  }

  it('自分のデータが全部消える（論理削除ではない）', async () => {
    const n = await deleteUserData(db, me)
    expect(n.response).toBe(1)
    expect(n.drill).toBe(1)
    expect(n.checkTest).toBe(1)
    expect(n.material).toBe(1)

    for (const t of ['response', 'drill', 'check_test', 'material', 'user_kc_state', 'kc_card']) {
      expect(await count(t, me)).toBe(0)
    }
    const u = await db<{ n: string }[]>`SELECT count(*) AS n FROM app_user WHERE id = ${me}`
    expect(Number(u[0]!.n)).toBe(0)
  })

  /**
   * ★ この試験が本題である。CASCADE の張り方を間違えると、
   *   1人の退会で他人の学習データまで消える。取り返しがつかない。
   */
  it('他人のデータは1件も消えない', async () => {
    await deleteUserData(db, me)
    expect(await count('response', other)).toBe(1)
    expect(await count('drill', other)).toBe(1)
    expect(await count('check_test', other)).toBe(1)
    expect(await count('material', other)).toBe(1)
    const u = await db<{ n: string }[]>`SELECT count(*) AS n FROM app_user WHERE id = ${other}`
    expect(Number(u[0]!.n)).toBe(1)
  })

  /** ★ 共有の設問（user_id IS NULL）は消さない。全員のものである */
  it('共有の設問は消えない', async () => {
    const shared = async () => {
      const r = await db<{ n: string }[]>`SELECT count(*) AS n FROM item WHERE user_id IS NULL`
      return Number(r[0]!.n)
    }
    const before = await shared()
    expect(before).toBeGreaterThan(0)
    await deleteUserData(db, me)
    expect(await shared()).toBe(before)
  })

  /** ★ 件数は消す前に数える。後で数えると必ず 0 になり、報告が嘘になる */
  it('件数は消す前の実数である', async () => {
    const before = await count('response', me)
    const n = await deleteUserData(db, me)
    expect(n.response).toBe(before)
    expect(n.response).toBeGreaterThan(0)
  })

  it('いない利用者を消しても落ちない（0件で返る）', async () => {
    const gone = await deleteUserData(db, me)
    expect(gone.response).toBe(1)
    const again = await deleteUserData(db, me)
    expect(again.response).toBe(0)
  })
})
