import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest'
import { readFileSync } from 'node:fs'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import { seedMasters, SEED_DIR } from '@/scripts/db/seed'
import { createUser, createItem } from './fixture'
import {
  diagnosticState, nextQuestion, answerDiagnostic, finishDiagnostic, hasDiagnostic,
} from './diagnostic'
import { MAX_ITEMS, MIN_ITEMS, cellKey, THETA_0 } from '@/lib/domain/diagnostic'
import { submitAnswer } from './answer'

/**
 * 診断テストの進行（docs/04-weakness-engine.md §5）
 *
 * ★ ここで守りたい一線は「**診断で弱点を確定させない**」ことである（§5.5）。
 *   `n_eff` が 0 のままでなければ、24問で 800〜900 の KC を判定したことになる。
 */

describe('画面の文言（§5.5）', () => {
  /**
   * ★ **コメントを外してから見る。** 画面のコメントには
   *   「❌『あなたの弱点はこれです』と書かないこと」という注意そのものが書いてある。
   *   本文をそのまま検索すると、禁止事項を書いた注意書きを違反として拾ってしまう。
   *   （最初にそれで落ちた。見るべきは**描かれる文字**である）
   */
  const rendered = (path: string) =>
    readFileSync(path, 'utf8')
      .replace(/\/\*[\s\S]*?\*\//g, '')
      .replace(/^\s*\/\/.*$/gm, '')

  const result = rendered('app/diagnostic/result/page.tsx')
  const quiz = rendered('app/diagnostic/quiz.tsx')
  const intro = rendered('app/diagnostic/page.tsx')

  /**
   * ★ 仕様が文言まで定めている:
   *     ✅「まずここから測っていきます」
   *     ❌「あなたの弱点はこれです」
   */
  it('「まずここから測っていきます」と書く', () => {
    expect(result).toContain('まずここから測っていきます')
  })

  it('弱点として断定しない', () => {
    expect(result).not.toContain('あなたの弱点')
    expect(result).not.toContain('苦手な分野')
    expect(result).not.toContain('あなたは')
    // 断定しない旨は、はっきり書く
    expect(result).toContain('判定ではありません')
    expect(result).toContain('まだ測っていない')
  })

  it('点数を出さない', () => {
    // ★ 「点」の1文字では見ない。「いまの時点では」まで拾ってしまう（実際に落ちた）。
    //   点数として読まれる語だけを挙げる
    for (const word of ['点数', '得点', '正解数', '正答率', '点満点', 'スコア']) {
      expect(result, `結果画面に「${word}」が出ている`).not.toContain(word)
    }
    // 「点数は付きません」は診断を始める前に言う（あとで言っても遅い）
    expect(intro).toContain('点数は付きません')
  })

  it('測っていないセルは「まだ測っていません」と書く（空欄にしない）', () => {
    expect(result).toContain('まだ測っていません')
  })

  it('出題画面は途中で正誤を出さない', () => {
    expect(quiz).toContain('正誤はまとめて最後に出ます')
    expect(quiz).not.toContain('正解です')
    expect(quiz).not.toContain('不正解')
    // actions が correct を返していない
    const actions = readFileSync('app/diagnostic/actions.ts', 'utf8')
    expect(actions).toContain('return { done: r.done, answered: r.answered }')
    expect(actions).not.toContain('correct: r.correct')
  })

  it('「わからない」を置く（当てずっぽうを強いない）', () => {
    expect(quiz).toContain('わからない')
  })

  /**
   * ★ 導線が1本しか無いと、受けたあと辿り着けなくなる。
   *   ホームの案内は `!hasDiagnostic` の分岐の中にあるので、
   *   一度受けると消える。記録タブに常設の入口を置いてある。
   */
  it('記録タブから受け直しと結果の見返しができる', () => {
    const records = rendered('app/records/page.tsx')
    expect(records).toContain('href="/diagnostic/result"')
    expect(records).toContain('href="/diagnostic"')
    // 受けたかどうかで文言を出し分けている（受けていない人に「結果を見る」を出さない）
    expect(records).toContain('tookDiagnostic')
  })

  it('進捗を出す（終わりが見えない測定は投げ出される）', () => {
    expect(quiz).toContain('{q.index} / {q.total} 問目')
  })
})

const dbSuite = TEST_DB_URL ? describe : describe.skip

dbSuite('診断テスト（実DB）', () => {
  let db: Sql
  let drop: () => Promise<void>
  let userId: string
  const NOW = new Date('2026-09-15T03:00:00Z')
  const UNIT = 'wh.2.1.1'

  beforeAll(async () => {
    ({ db, drop } = await createTestDb('historia_diagnostic_test'))
    await seedMasters(db, SEED_DIR)
  }, 120_000)
  afterAll(async () => { await drop() })

  beforeEach(async () => {
    for (const t of ['response', 'user_activity', 'misconception', 'kc_card', 'user_kc_state',
                     'item_kc', 'item', 'kc_syllabus_unit', 'kc_region', 'kc', 'app_user']) {
      await db.unsafe(`DELETE FROM ${t}`)
    }
    userId = await createUser(db, NOW)
  })

  /** era × grid のセルに属する KC を1つ作る */
  const makeKc = async (id: string, eraId: number, regionId: number, examWeight = 1.0) => {
    await db`
      INSERT INTO kc (id, label, kind, era_id, exam_weight)
      VALUES (${id}, ${`KC ${id}`}, 'fact', ${eraId}, ${examWeight})`
    await db`INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES (${id}, ${regionId}, true)`
    await db`INSERT INTO kc_syllabus_unit (kc_id, unit_id) VALUES (${id}, ${UNIT})`
    return id
  }

  /** region_id -> grid_id を seed から引く */
  const gridOf = async (regionId: number) => {
    const [r] = await db<{ grid_id: number }[]>`SELECT grid_id FROM region WHERE id = ${regionId}`
    return r!.grid_id
  }

  /** 共有プールの設問を1問。指定のセルに落ちる */
  const poolItem = async (kcId: string) =>
    createItem(db, { userId: null, kcs: [{ kcId }], now: NOW })

  describe('プールの絞り込み', () => {
    it('共有プール（user_id IS NULL）からしか出さない', async () => {
      const kc = await makeKc('kc.a', 1, 2)
      await createItem(db, { userId, kcs: [{ kcId: kc }], now: NOW })   // 個人用
      expect((await nextQuestion(db, userId)).question).toBeNull()

      await poolItem(kc)
      expect((await nextQuestion(db, userId)).question).not.toBeNull()
    })

    it('未承認の設問は出さない', async () => {
      const kc = await makeKc('kc.a', 1, 2)
      await createItem(db, { userId: null, kcs: [{ kcId: kc }], now: NOW, approved: false })
      expect((await nextQuestion(db, userId)).question).toBeNull()
    })

    it('伏せた設問は出さない', async () => {
      const kc = await makeKc('kc.a', 1, 2)
      const id = await poolItem(kc)
      await db`UPDATE item SET hidden = true, hidden_reason = 'user_report' WHERE id = ${id}`
      expect((await nextQuestion(db, userId)).question).toBeNull()
    })

    /** ★ era も primary の region も無い KC は、どのセルにも入らない */
    it('時代の付いていない KC の設問は出さない', async () => {
      await db`INSERT INTO kc (id, label, kind) VALUES ('kc.noera', 'x', 'fact')`
      await db`INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.noera', 2, true)`
      await poolItem('kc.noera')
      expect((await nextQuestion(db, userId)).question).toBeNull()
    })

    it('primary の地域が無い KC の設問は出さない', async () => {
      await db`INSERT INTO kc (id, label, kind, era_id) VALUES ('kc.noreg', 'x', 'fact', 1)`
      await db`INSERT INTO kc_region (kc_id, region_id, is_primary) VALUES ('kc.noreg', 2, false)`
      await poolItem('kc.noreg')
      expect((await nextQuestion(db, userId)).question).toBeNull()
    })

    it('正答も解説もクライアントへ渡さない（docs/12 §6.1）', async () => {
      const kc = await makeKc('kc.a', 1, 2)
      await poolItem(kc)
      const { question } = await nextQuestion(db, userId)
      expect(Object.keys(question!)).not.toContain('answerKey')
      expect(Object.keys(question!)).not.toContain('explanation')
      expect(JSON.stringify(question)).not.toContain('解説')
    })

    it('同じ設問は2度出さない', async () => {
      const kc = await makeKc('kc.a', 1, 2)
      const a = await poolItem(kc)
      await poolItem(kc)
      await answerDiagnostic(db, userId, a, 'a', 1000, NOW)
      const { question } = await nextQuestion(db, userId)
      expect(question!.itemId).not.toBe(a)
    })
  })

  describe('進行と打ち切り（§5.3）', () => {
    /** 12セルぶんの KC と、各セル 4 問を用意する */
    const fillPool = async () => {
      // seed/region.csv から grid ごとの代表 region を1つ取る
      const regions = await db<{ id: number; grid_id: number }[]>`
        SELECT DISTINCT ON (grid_id) id, grid_id FROM region ORDER BY grid_id, ord`
      for (const era of [1, 2, 3]) {
        for (const r of regions) {
          const kc = await makeKc(`kc.e${era}g${r.grid_id}`, era, r.id)
          for (let i = 0; i < 4; i++) await poolItem(kc)
        }
      }
      return regions
    }

    const answerAll = async (correct: boolean, limit = MAX_ITEMS + 5) => {
      let n = 0
      for (;;) {
        const { question } = await nextQuestion(db, userId)
        if (!question || n >= limit) break
        await answerDiagnostic(db, userId, question.itemId, correct ? 'a' : 'b', 1000, NOW)
        n++
      }
      return n
    }

    /** ★ 24問を超えない。1問25秒想定で最大10分（§5.3） */
    it('24問を超えない', async () => {
      await fillPool()
      const n = await answerAll(true)
      expect(n).toBe(MAX_ITEMS)
      const s = await diagnosticState(db, userId)
      expect(s.answered).toBe(MAX_ITEMS)
      expect(s.done).toBe(true)
    })

    it('12問では終わらない（SD 条件は現実には満たされない）', async () => {
      await fillPool()
      for (let i = 0; i < MIN_ITEMS; i++) {
        const { question } = await nextQuestion(db, userId)
        await answerDiagnostic(db, userId, question!.itemId, 'a', 1000, NOW)
      }
      expect((await diagnosticState(db, userId)).done).toBe(false)
    })

    it('プールが尽きたらそこで終わる（「問題がありません」で止めない）', async () => {
      const kc = await makeKc('kc.a', 1, 2)
      await poolItem(kc)
      await poolItem(kc)
      const n = await answerAll(true)
      expect(n).toBe(2)
      expect((await nextQuestion(db, userId)).question).toBeNull()
    })

    it('12セルに散らして出す（1セルに固まらない）', async () => {
      await fillPool()
      await answerAll(true)
      const s = await diagnosticState(db, userId)
      const touched = [...s.cells.values()].filter(c => c.answered > 0)
      expect(touched.length).toBe(12)
      // 24問 ÷ 12セル = 2問ずつ。極端な偏りが無いこと
      expect(Math.max(...touched.map(c => c.answered))).toBeLessThanOrEqual(3)
    })

    it('正解が続けばθが上がり、不正解が続けば下がる', async () => {
      await fillPool()
      await answerAll(true)
      const up = await diagnosticState(db, userId)
      const thetaUp = [...up.cells.values()].filter(c => c.answered > 0).map(c => c.theta)
      expect(Math.min(...thetaUp)).toBeGreaterThan(THETA_0)

      await db`DELETE FROM response WHERE user_id = ${userId}`
      await answerAll(false)
      const down = await diagnosticState(db, userId)
      const thetaDown = [...down.cells.values()].filter(c => c.answered > 0).map(c => c.theta)
      expect(Math.max(...thetaDown)).toBeLessThan(THETA_0)
    })
  })

  describe('n_eff を動かさない（§5.4・§5.5）', () => {
    /**
     * ★ この試験が段6 の本題である。
     *   分岐を外すと `submitAnswer` が普通に `user_kc_state` と `kc_card` を更新し、
     *   24問で 800〜900 の KC を「判定済み」にしてしまう。
     */
    it('診断で解いても user_kc_state ができない', async () => {
      const kc = await makeKc('kc.a', 1, 2)
      const id = await poolItem(kc)
      await answerDiagnostic(db, userId, id, 'a', 1000, NOW)
      const rows = await db`SELECT * FROM user_kc_state WHERE user_id = ${userId}`
      expect(rows).toHaveLength(0)
    })

    it('診断で解いても kc_card ができない（復習予定に入らない）', async () => {
      const kc = await makeKc('kc.a', 1, 2)
      const id = await poolItem(kc)
      await answerDiagnostic(db, userId, id, 'a', 1000, NOW)
      expect(await db`SELECT * FROM kc_card WHERE user_id = ${userId}`).toHaveLength(0)
    })

    it('誤答しても誤概念を溜めない（まだ習っていないだけかもしれない）', async () => {
      const kc = await makeKc('kc.a', 1, 2)
      const id = await poolItem(kc)
      await answerDiagnostic(db, userId, id, 'b', 1000, NOW)
      expect(await db`SELECT * FROM misconception WHERE user_id = ${userId}`).toHaveLength(0)
    })

    /** ★ 逆対照。同じ設問を通常の出題として解けば、ちゃんと状態ができる */
    it('逆対照: quiz として解けば user_kc_state も kc_card もできる', async () => {
      const kc = await makeKc('kc.a', 1, 2)
      const id = await poolItem(kc)
      await submitAnswer(db, {
        userId, itemId: id, sessionKind: 'quiz', chosen: 'a', latencyMs: 1000, now: NOW,
      })
      expect(await db`SELECT * FROM user_kc_state WHERE user_id = ${userId}`).toHaveLength(1)
      expect(await db`SELECT * FROM kc_card WHERE user_id = ${userId}`).toHaveLength(1)
    })

    it('解答そのものは記録する（response と当日の活動）', async () => {
      const kc = await makeKc('kc.a', 1, 2)
      const id = await poolItem(kc)
      await answerDiagnostic(db, userId, id, 'a', 1000, NOW)
      const r = await db<{ session_kind: string }[]>`
        SELECT session_kind FROM response WHERE user_id = ${userId}`
      expect(r).toHaveLength(1)
      expect(r[0]!.session_kind).toBe('diagnostic')
      expect(await db`SELECT * FROM user_activity WHERE user_id = ${userId}`).toHaveLength(1)
    })
  })

  describe('Elo の較正（§5.2・docs/04b §1.3）', () => {
    it('診断プールの設問は較正される', async () => {
      const kc = await makeKc('kc.a', 1, 2)
      const id = await poolItem(kc)
      await answerDiagnostic(db, userId, id, 'a', 1000, NOW)
      const [i] = await db<{ elo_b: number; elo_n: number }[]>`
        SELECT elo_b, elo_n FROM item WHERE id = ${id}`
      expect(i!.elo_n).toBe(1)
      // 正解されたので易しくなる（elo_b が下がる）
      expect(i!.elo_b).toBeLessThan(0)
    })

    it('不正解なら難しくなる', async () => {
      const kc = await makeKc('kc.a', 1, 2)
      const id = await poolItem(kc)
      await answerDiagnostic(db, userId, id, 'b', 1000, NOW)
      const [i] = await db<{ elo_b: number }[]>`SELECT elo_b FROM item WHERE id = ${id}`
      expect(i!.elo_b).toBeGreaterThan(0)
    })

    /**
     * ★ ユーザー生成の設問は較正しない（04b §1.3）。
     *   同じものが二度と出ないので、1件の観測で歪んだ値だけが残る
     */
    it('ユーザー生成の設問は較正しない', async () => {
      const kc = await makeKc('kc.a', 1, 2)
      const id = await createItem(db, { userId, kcs: [{ kcId: kc }], now: NOW })
      await submitAnswer(db, {
        userId, itemId: id, sessionKind: 'diagnostic', chosen: 'a', latencyMs: 1000,
        expectedP: 0.4, now: NOW,
      })
      const [i] = await db<{ elo_b: number; elo_n: number }[]>`
        SELECT elo_b, elo_n FROM item WHERE id = ${id}`
      expect(i!.elo_n).toBe(0)
      expect(i!.elo_b).toBe(0)
    })

    /** ★ 通常の出題では較正しない。診断プールでのみ成立する（§5.2） */
    it('quiz として解いても較正しない', async () => {
      const kc = await makeKc('kc.a', 1, 2)
      const id = await poolItem(kc)
      await submitAnswer(db, {
        userId, itemId: id, sessionKind: 'quiz', chosen: 'a', latencyMs: 1000, now: NOW,
      })
      const [i] = await db<{ elo_n: number }[]>`SELECT elo_n FROM item WHERE id = ${id}`
      expect(i!.elo_n).toBe(0)
    })

    it('観測数はいつも増える', async () => {
      const kc = await makeKc('kc.a', 1, 2)
      const id = await poolItem(kc)
      await answerDiagnostic(db, userId, id, 'a', 1000, NOW)
      const other = await createUser(db, NOW)
      await answerDiagnostic(db, other, id, 'b', 1000, NOW)
      const [i] = await db<{ elo_n: number }[]>`SELECT elo_n FROM item WHERE id = ${id}`
      expect(i!.elo_n).toBe(2)
    })
  })

  describe('伝播（§5.4）', () => {
    it('測ったセルの KC にθを配り、n_eff は 0 のまま', async () => {
      const kc = await makeKc('kc.a', 1, 2)
      const sibling = await makeKc('kc.b', 1, 2)   // 同じセルの別 KC（出題はされない）
      const id = await poolItem(kc)
      await answerDiagnostic(db, userId, id, 'a', 1000, NOW)
      const r = await finishDiagnostic(db, userId, NOW)
      expect(r.seeded).toBe(2)

      const rows = await db<{ kc_id: string; theta: number; n_eff: number; p_know: number }[]>`
        SELECT kc_id, theta, n_eff, p_know FROM user_kc_state
         WHERE user_id = ${userId} ORDER BY kc_id`
      expect(rows.map(x => x.kc_id)).toEqual([kc, sibling])
      // ★ ここが §5.4 の一線
      expect(rows.every(x => x.n_eff === 0)).toBe(true)
      // 正解したのでθは初期値より上
      expect(rows[0]!.theta).toBeGreaterThan(THETA_0)
      // 同じセルなので同じθ
      expect(rows[0]!.theta).toBeCloseTo(rows[1]!.theta, 5)
      // p_know は事前分布のまま（0.10〜0.45）
      expect(rows[0]!.p_know).toBeGreaterThanOrEqual(0.10)
      expect(rows[0]!.p_know).toBeLessThanOrEqual(0.45)
    })

    /** ★ 1問も出せなかったセルには行を作らない。「測った」と「測っていない」を混ぜない */
    it('測っていないセルの KC には行を作らない', async () => {
      const measured = await makeKc('kc.a', 1, 2)
      await makeKc('kc.far', 3, 20)   // 別の時代・別の地域
      const id = await poolItem(measured)
      await answerDiagnostic(db, userId, id, 'a', 1000, NOW)
      await finishDiagnostic(db, userId, NOW)
      const rows = await db<{ kc_id: string }[]>`
        SELECT kc_id FROM user_kc_state WHERE user_id = ${userId}`
      expect(rows.map(r => r.kc_id)).toEqual(['kc.a'])
    })

    /** ★ 診断をやり直しても、その後の学習で積み上がった推定を消さない */
    it('既に状態がある KC は上書きしない', async () => {
      const kc = await makeKc('kc.a', 1, 2)
      const id = await poolItem(kc)
      const other = await poolItem(kc)
      await submitAnswer(db, {
        userId, itemId: other, sessionKind: 'quiz', chosen: 'a', latencyMs: 1000, now: NOW,
      })
      const [before] = await db<{ theta: number; n_eff: number }[]>`
        SELECT theta, n_eff FROM user_kc_state WHERE user_id = ${userId} AND kc_id = ${kc}`
      expect(before!.n_eff).toBeGreaterThan(0)

      await answerDiagnostic(db, userId, id, 'a', 1000, NOW)
      await finishDiagnostic(db, userId, NOW)
      const [after] = await db<{ theta: number; n_eff: number }[]>`
        SELECT theta, n_eff FROM user_kc_state WHERE user_id = ${userId} AND kc_id = ${kc}`
      expect(after!.theta).toBeCloseTo(before!.theta, 6)
      expect(after!.n_eff).toBeCloseTo(before!.n_eff, 6)
    })

    it('1問も解いていなければ何も配らない', async () => {
      await makeKc('kc.a', 1, 2)
      const r = await finishDiagnostic(db, userId, NOW)
      expect(r.seeded).toBe(0)
      expect(r.unmeasured).toHaveLength(12)
    })
  })

  describe('ホームの出し分け（docs/11-ux.md:80）', () => {
    it('診断を受けていなければ false', async () => {
      expect(await hasDiagnostic(db, userId)).toBe(false)
    })

    it('1問でも受けていれば true', async () => {
      const kc = await makeKc('kc.a', 1, 2)
      const id = await poolItem(kc)
      await answerDiagnostic(db, userId, id, 'a', 1000, NOW)
      expect(await hasDiagnostic(db, userId)).toBe(true)
    })

    it('通常の出題を解いただけでは true にならない（逆対照）', async () => {
      const kc = await makeKc('kc.a', 1, 2)
      const id = await poolItem(kc)
      await submitAnswer(db, {
        userId, itemId: id, sessionKind: 'quiz', chosen: 'a', latencyMs: 1000, now: NOW,
      })
      expect(await hasDiagnostic(db, userId)).toBe(false)
    })
  })

  it('グリッドの割り当ては seed の region.grid_id に従う', async () => {
    expect(await gridOf(2)).toBe(1)   // 西欧 → グリッド1
    const kc = await makeKc('kc.a', 1, 2)
    const id = await poolItem(kc)
    await answerDiagnostic(db, userId, id, 'a', 1000, NOW)
    const s = await diagnosticState(db, userId)
    expect(s.cells.get(cellKey(1, 1))!.answered).toBe(1)
  })
})
