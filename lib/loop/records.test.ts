import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import { seedMasters, SEED_DIR } from '@/scripts/db/seed'
import { createUser, createKcs, createItem } from './fixture'
import { submitAnswer } from './answer'
import { weakKcs, streak, buildEvidence } from './records'

describe('根拠の文面（docs/04 §4.3）', () => {
  const base = {
    kc_id: 'kc.x.y', label: 'X', p_know: null, theta: null, n_eff: null, n_obs: null,
    last_seen_at: null, interval_days: null, last_review_at: null, suspended: null,
    distinct_correct_days: 0, has_non_flashcard_correct: false,
    attempts: 0, wrong: 0, top_wrong: null, top_wrong_n: 0,
    last_correct_at: null, material_id: null,
  }
  const NOW = new Date('2026-09-15T00:00:00Z')

  it('偏った誤答は選択肢を名指しする', () => {
    const e = buildEvidence({ ...base, attempts: 12, wrong: 9, top_wrong: 'アッバース朝', top_wrong_n: 2 }, NOW)
    expect(e[0]!.text).toBe('12問中9問で誤答。うち2回は「アッバース朝」を選択')
  })

  it('偏りが1回だけなら名指ししない（1回では傾向と言えない）', () => {
    const e = buildEvidence({ ...base, attempts: 4, wrong: 1, top_wrong: 'ウマイヤ朝', top_wrong_n: 1 }, NOW)
    expect(e[0]!.text).toBe('4問中1問で誤答')
  })

  it('最後の正解からの経過と保持率を出す', () => {
    const e = buildEvidence({
      ...base, attempts: 5, wrong: 2, interval_days: 30,
      last_correct_at: new Date('2026-09-04T00:00:00Z'),   // 11日前
    }, NOW)
    expect(e[1]!.text).toMatch(/^最後に正解してから11日（保持率の推定 \d+%）$/)
  })

  it('interval が無ければ保持率を書かない（推定できないものを書かない）', () => {
    const e = buildEvidence({
      ...base, attempts: 5, wrong: 2, last_correct_at: new Date('2026-09-04T00:00:00Z'),
    }, NOW)
    expect(e[1]!.text).toBe('最後に正解してから11日')
  })

  it('一度も正解していないことを言う', () => {
    const e = buildEvidence({ ...base, attempts: 3, wrong: 3 }, NOW)
    expect(e.map(x => x.text)).toContain('まだ一度も正解していない')
  })

  it('暗記カードでしか正解していないことを言う（docs/04 の mastered 条件）', () => {
    const e = buildEvidence({
      ...base, attempts: 6, wrong: 2, distinct_correct_days: 2,
      has_non_flashcard_correct: false, last_correct_at: NOW,
    }, NOW)
    expect(e.map(x => x.text)).toContain('正解はすべて暗記カード（四択・並べ替えでは未正解）')
  })

  it('解答が無ければ根拠を作らない（水増ししない）', () => {
    expect(buildEvidence(base, NOW)).toEqual([])
  })
})

const dbSuite = TEST_DB_URL ? describe : describe.skip

dbSuite('記録タブ（実DB）', () => {
  let db: Sql
  let drop: () => Promise<void>
  const NOW = new Date('2026-09-15T03:00:00Z')
  const UNIT = 'wh.2.1.1'
  let userId: string

  beforeAll(async () => {
    ({ db, drop } = await createTestDb('historia_records_test'))
    await seedMasters(db, SEED_DIR)
  }, 120_000)
  afterAll(async () => { await drop() })

  beforeEach(async () => {
    await db`TRUNCATE response, user_kc_state, kc_card, item_kc, item, kc_syllabus_unit, kc,
                      app_user RESTART IDENTITY CASCADE`
    userId = await createUser(db, NOW)
  })

  const answer = async (itemId: string, chosen: string, at: Date) =>
    submitAnswer(db, {
      userId, itemId, sessionKind: 'quiz', drillId: null,
      chosen, latencyMs: 4000, msSinceReveal: null, now: at,
    })

  it('誤答が多い KC が根拠つきで出る', async () => {
    await createKcs(db, ['kc.t.weak'], UNIT)
    const item = await createItem(db, { userId: null, kcs: [{ kcId: 'kc.t.weak' }], answerKey: 'a', now: NOW })
    for (let i = 0; i < 4; i++) {
      await answer(item, 'b', new Date(NOW.getTime() - (i + 1) * 86_400_000))
    }

    const weak = await weakKcs(db, userId, NOW)
    expect(weak).toHaveLength(1)
    expect(weak[0]!.kcId).toBe('kc.t.weak')
    // 「4問中4問で誤答。うち4回は「B」を選択」
    expect(weak[0]!.evidence[0]!.text).toContain('4問中4問で誤答')
    expect(weak[0]!.evidence[0]!.text).toContain('「b」')
    expect(weak[0]!.evidence.map(e => e.text)).toContain('まだ一度も正解していない')
  })

  /**
   * ★ この試験が本題である。`mastered` を記録タブに出すと、
   *   「できているもの」で画面が埋まって行動が変わらなくなる。
   */
  it('できている KC は出さない', async () => {
    await createKcs(db, ['kc.t.ok'], UNIT)
    const item = await createItem(db, { userId: null, kcs: [{ kcId: 'kc.t.ok' }], answerKey: 'a', now: NOW })
    // 別日に何度も正解させて mastered に寄せる
    for (let i = 0; i < 8; i++) {
      await answer(item, 'a', new Date(NOW.getTime() - (i + 1) * 86_400_000))
    }
    const weak = await weakKcs(db, userId, NOW)
    expect(weak.every(w => w.status !== 'mastered')).toBe(true)
  })

  it('解答していない KC は出さない（状態が無いものを弱点と言わない）', async () => {
    await createKcs(db, ['kc.t.untouched'], UNIT)
    expect(await weakKcs(db, userId, NOW)).toHaveLength(0)
  })

  it('弱い順に並ぶ', async () => {
    await createKcs(db, ['kc.t.a', 'kc.t.b'], UNIT)
    const a = await createItem(db, { userId: null, kcs: [{ kcId: 'kc.t.a' }], answerKey: 'a', now: NOW })
    const b = await createItem(db, { userId: null, kcs: [{ kcId: 'kc.t.b' }], answerKey: 'a', now: NOW })
    for (let i = 0; i < 4; i++) {
      await answer(a, 'b', new Date(NOW.getTime() - (i + 1) * 86_400_000))          // 全部誤答
      await answer(b, i < 2 ? 'a' : 'b', new Date(NOW.getTime() - (i + 1) * 86_400_000))
    }
    const weak = await weakKcs(db, userId, NOW)
    expect(weak.length).toBeGreaterThanOrEqual(2)
    expect(weak[0]!.mastery).toBeLessThanOrEqual(weak[1]!.mastery)
  })

  it('他人の解答が混ざらない（v_weakness_evidence は security_invoker）', async () => {
    await createKcs(db, ['kc.t.shared'], UNIT)
    const item = await createItem(db, { userId: null, kcs: [{ kcId: 'kc.t.shared' }], answerKey: 'a', now: NOW })
    const other = await createUser(db, NOW)
    for (let i = 0; i < 4; i++) {
      await submitAnswer(db, {
        userId: other, itemId: item, sessionKind: 'quiz', drillId: null,
        chosen: 'b', latencyMs: 4000, msSinceReveal: null,
        now: new Date(NOW.getTime() - (i + 1) * 86_400_000),
      })
    }
    // 自分は1問も解いていないので、弱点は出ない
    expect(await weakKcs(db, userId, NOW)).toHaveLength(0)
  })

  describe('ストリーク', () => {
    const setup = async () => {
      await createKcs(db, ['kc.t.s'], UNIT)
      return createItem(db, { userId: null, kcs: [{ kcId: 'kc.t.s' }], answerKey: 'a', now: NOW })
    }

    it('解答が無ければ0', async () => {
      expect(await streak(db, userId, NOW))
        .toEqual({ current: 0, longest: 0, days: 0, protectionsLeft: 2 })
    })

    /**
     * ★ ここが「user_activity から数える」に切り替えた効き目である。
     *   以前は response を UTC の date() で数えていたので、
     *   日本時間の深夜0〜9時に解いた分が前日に落ちていた。
     *   「日付が変わる前に1問やった」が連続に効かない、という壊れ方をする。
     */
    it('日本時間の深夜に解いた分が、その日に入る（UTC では前日になる時刻）', async () => {
      const item = await setup()
      // JST 9/15 00:30 = UTC 9/14 15:30
      await answer(item, 'a', new Date('2026-09-14T15:30:00Z'))
      const [row] = await db<{ d: string }[]>`
        SELECT to_char(activity_date, 'YYYY-MM-DD') AS d
          FROM user_activity WHERE user_id = ${userId}`
      expect(row!.d).toBe('2026-09-15')
      expect((await streak(db, userId, new Date('2026-09-15T03:00:00Z'))).current).toBe(1)
    })

    it('同じ日に2回解いても user_activity は1行のまま（回数だけ増える）', async () => {
      const item = await setup()
      await answer(item, 'a', NOW)
      await answer(item, 'b', new Date(NOW.getTime() + 60_000))
      const rows = await db<{ responses: number }[]>`
        SELECT responses FROM user_activity WHERE user_id = ${userId}`
      expect(rows).toHaveLength(1)
      expect(rows[0]!.responses).toBe(2)
      expect((await streak(db, userId, NOW)).days).toBe(1)
    })

    /** docs/11-ux.md §7.1「1日空いた場合はストリーク保護を月2回まで自動適用する」 */
    it('1日空いても連続が切れない（ストリーク保護）', async () => {
      const item = await setup()
      for (const d of [0, 1, 3, 4]) {          // 2日前だけ空ける
        await answer(item, 'a', new Date(NOW.getTime() - d * 86_400_000))
      }
      const s = await streak(db, userId, NOW)
      expect(s.current).toBe(4)                // 休んだ日は数に入れない
      expect(s.protectionsLeft).toBe(1)
    })

    it('教材を読んだだけの日は連続に数えない（仕様は「1問以上解いた」）', async () => {
      const item = await setup()
      await answer(item, 'a', NOW)
      // 昨日ぶんの読了だけを入れる（解答は無い）
      await db`
        INSERT INTO user_activity (user_id, activity_date, responses, sections_read)
        VALUES (${userId}, '2026-09-14', 0, 3)`
      const s = await streak(db, userId, NOW)
      expect(s.current).toBe(1)
      expect(s.days).toBe(1)
    })

    it('連続した日を数える', async () => {
      const item = await setup()
      for (const d of [0, 1, 2]) {
        await answer(item, 'a', new Date(NOW.getTime() - d * 86_400_000))
      }
      const s = await streak(db, userId, NOW)
      expect(s.current).toBe(3)
      expect(s.days).toBe(3)
    })

    /** ★ 今日まだ解いていなくても連続は途切れていない。夜に開いて絶望させない */
    it('今日まだ解いていなくても、昨日まで続いていれば途切れない', async () => {
      const item = await setup()
      for (const d of [1, 2, 3]) {
        await answer(item, 'a', new Date(NOW.getTime() - d * 86_400_000))
      }
      expect((await streak(db, userId, NOW)).current).toBe(3)
    })

    it('間が空いたら現在の連続は切れるが、最長は残る', async () => {
      const item = await setup()
      for (const d of [0, 5, 6, 7, 8]) {
        await answer(item, 'a', new Date(NOW.getTime() - d * 86_400_000))
      }
      const s = await streak(db, userId, NOW)
      expect(s.current).toBe(1)
      expect(s.longest).toBe(4)
      expect(s.days).toBe(5)
    })
  })
})
