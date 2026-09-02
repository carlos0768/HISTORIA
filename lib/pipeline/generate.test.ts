import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import { seedMasters, seedKc, SEED_DIR } from '@/scripts/db/seed'
import { createClient, type AiConfig } from '@/lib/ai/client'
import { ensureBudgetRow, budgetStatus, periodOf } from '@/lib/ai/budget'
import { generateMaterial, paramsHash, MATERIAL_MAX_OUTPUT_TOKENS, VERIFY_MAX_OUTPUT_TOKENS } from './generate'
import { MAX_CHARS } from '@/lib/ai/schema'
import { machineCheck, extractYear, matchRate } from './factcheck'
import { createUser } from '@/lib/loop/fixture'
import { MATERIAL_PROMPT_VERSION } from '@/lib/ai/prompt'

const cfg: AiConfig = {
  genProvider: 'gemini', genModel: 'gemini-3.6-flash',
  verifyProvider: 'anthropic', verifyModel: 'claude-sonnet-5',
  embedModel: 'gemini-embedding-001',
}

describe('層2 の年号抽出', () => {
  it('西暦と紀元前を拾う', () => {
    expect(extractYear('ウェストファリア条約は1648年')).toBe(1648)
    expect(extractYear('ハンムラビ法典は前1750年ごろ')).toBe(-1750)
  })
  it('「前18世紀」のような表記は拾わない（誤照合を作らない）', () => {
    expect(extractYear('ハンムラビ法典は前18世紀')).toBeNull()
    expect(extractYear('年号を含まない主張')).toBeNull()
  })
})

/**
 * 出力上限が「実際に出うる最大」を下回っていると、
 * finishReason が MAX_TOKENS になって毎回失敗する。
 * docs/08 §3.3 の見積りと docs/07 §2 の受け入れ範囲から下限を導いて固定する。
 */
describe('出力トークンの上限', () => {
  it('教材の上限が docs/08 §3.3 の見積り（12,168）を上回る', () => {
    expect(MATERIAL_MAX_OUTPUT_TOKENS).toBeGreaterThan(12_168)
  })

  it('受け入れ範囲の最大構成でも収まる', () => {
    // docs/08 §3.3 の 12,168 は 本文3,500字 / FC12枚 / 四択8問 / claims20件 の構成
    const base = 12_168
    const extra =
      (MAX_CHARS - 3_500) +      // 本文が上限まで伸びたぶん（日本語はおよそ1字1トークン）
      (14 - 12) * 60 +           // フラッシュカードの増分
      (10 - 8) * 300 +           // 四択の増分（選択肢4つ＋誤答の説明＋解説）
      (40 - 20) * 60             // claims の増分
    expect(MATERIAL_MAX_OUTPUT_TOKENS).toBeGreaterThanOrEqual(base + extra)
  })

  it('検証の上限が claims 最大40件の判定を収められる', () => {
    // 1件あたり index + status + 理由およそ60字
    expect(VERIFY_MAX_OUTPUT_TOKENS).toBeGreaterThanOrEqual(40 * 90)
  })
})

describe('冪等キー', () => {
  it('KC の順序が違っても同じ鍵になる', () => {
    expect(paramsHash('wh.2.1.1', 'v1', ['b', 'a'])).toBe(paramsHash('wh.2.1.1', 'v1', ['a', 'b']))
  })
  it('プロンプト版が違えば別の鍵になる（版を上げたら作り直す）', () => {
    expect(paramsHash('wh.2.1.1', 'v1', ['a'])).not.toBe(paramsHash('wh.2.1.1', 'v2', ['a']))
  })
})

const dbSuite = TEST_DB_URL ? describe : describe.skip

dbSuite('生成パイプライン（実DB）', () => {
  let db: Sql
  let drop: () => Promise<void>
  const NOW = new Date('2026-09-15T03:00:00Z')
  const UNIT = 'wh.2.1.1'
  let userId: string

  beforeAll(async () => {
    ;({ db, drop } = await createTestDb('historia_pipeline_test'))
    await seedMasters(db, SEED_DIR)
    await seedKc(db, SEED_DIR, { requireApproval: false })
  }, 120_000)
  afterAll(async () => { await drop() })

  beforeEach(async () => {
    await db`TRUNCATE material_section_kc, material_section, material_read, material,
             item_kc, item, response, user_kc_state, kc_card, misconception,
             generation_job, ai_spend, app_user RESTART IDENTITY CASCADE`
    await db`DELETE FROM ai_budget`
    await ensureBudgetRow(db, periodOf(NOW))
    userId = await createUser(db, NOW)
  })

  it('教材とセクション7つ、設問が保存され ready になる', async () => {
    const ai = createClient(cfg)
    const r = await generateMaterial(db, ai, { userId, unitId: UNIT, now: NOW })
    expect(r.status).toBe('ready')
    if (r.status !== 'ready') return

    const m = await db<{ status: string; prompt_version: string; title: string }[]>`
      SELECT status, prompt_version, title FROM material WHERE id = ${r.materialId}`
    expect(m[0]!.status).toBe('ready')
    expect(m[0]!.prompt_version).toBe(MATERIAL_PROMPT_VERSION)

    const secs = await db<{ n: string }[]>`SELECT count(*) AS n FROM material_section WHERE material_id = ${r.materialId}`
    expect(Number(secs[0]!.n)).toBe(7)

    /**
     * ★ 鍵が無いときは「使いたかった名前」ではなく「実際に使われた名前」を残す。
     *   ここが 'gemini' に戻ると、鍵を入れ忘れて作ったでたらめな教材を
     *   後から見分けられなくなり、画面の警告も出なくなる。
     */
    const p = await db<{ provider: string }[]>`
      SELECT provider FROM material WHERE id = ${r.materialId}`
    expect(p[0]!.provider).toBe('fake:gemini')
    const ip = await db<{ provider: string }[]>`
      SELECT DISTINCT provider FROM item WHERE material_id = ${r.materialId}`
    expect(ip.map(x => x.provider)).toEqual(['fake:gemini'])

    // 四択6問 + フラッシュカード10枚
    const items = await db<{ format: string; n: string }[]>`
      SELECT format, count(*) AS n FROM item WHERE material_id = ${r.materialId} GROUP BY format ORDER BY format`
    expect(items).toEqual([
      { format: 'flashcard', n: '10' },
      { format: 'mcq4', n: '6' },
    ])
    expect(r.itemCount).toBe(16)
  })

  it('ready なら item が factcheck 承認で出題可能になる', async () => {
    const ai = createClient(cfg)
    const r = await generateMaterial(db, ai, { userId, unitId: UNIT, now: NOW })
    const rows = await db<{ approved: boolean; approved_by: string | null }[]>`
      SELECT approved, approved_by FROM item WHERE user_id = ${userId}`
    expect(rows.length).toBeGreaterThan(0)
    expect(rows.every(x => x.approved && x.approved_by === 'factcheck')).toBe(true)
    expect(r.status).toBe('ready')
  })

  // ---- 作者判断 Q4: 事実確認を通らなければユニットごと配信しない ----

  it('誤りが1件でもあれば blocked になり、設問は1問も承認されない', async () => {
    const ai = createClient(cfg, { wrongClaims: ['ウェストファリア条約は1658年'] })
    const r = await generateMaterial(db, ai, { userId, unitId: UNIT, now: NOW })
    expect(r.status).toBe('blocked')
    if (r.status !== 'blocked') return

    expect(r.reason).toContain('1658年')
    const m = await db<{ status: string; blocked_reason: string }[]>`
      SELECT status, blocked_reason FROM material WHERE id = ${r.materialId}`
    expect(m[0]!.status).toBe('blocked')
    expect(m[0]!.blocked_reason).toBeTruthy()

    const items = await db<{ approved: boolean }[]>`SELECT approved FROM item WHERE material_id = ${r.materialId}`
    expect(items.length).toBeGreaterThan(0)
    expect(items.every(x => !x.approved)).toBe(true)
  })

  it('blocked の教材は「配信できる教材」に数えない', async () => {
    const ai = createClient(cfg, { wrongClaims: ['前1750年に成立したはずの条約は1500年'] })
    await generateMaterial(db, ai, { userId, unitId: UNIT, now: NOW })
    const ready = await db<{ n: string }[]>`
      SELECT count(*) AS n FROM material WHERE user_id = ${userId} AND status = 'ready'`
    expect(Number(ready[0]!.n)).toBe(0)
  })

  /**
   * v1 のプロンプトは claims を一度も指示していなかった。
   * モデルが空配列を返すと層2は0件、層3は呼ばれず、ready として配信されていた。
   * 5層防御が沈黙のうちに0層になる経路である。
   */
  it('claims が空の教材は配信しない（未検証のまま通さない）', async () => {
    const ai = createClient(cfg)
    // プロバイダを迂回して claims を空にする。スキーマ検査の裏をかいた状態を作る
    const noClaims = {
      ...ai,
      generate: async <T,>() => ({
        value: {
          title: '主張の無い教材',
          sections: Array.from({ length: 7 }, (_, i) => ({
            ord: i + 1, heading: `§${i + 1}`, body_md: 'あ'.repeat(500), kc_ids: [],
          })),
          flashcards: Array.from({ length: 10 }, (_, i) => ({
            front: `問${i}`, back: '答', kc_ids: [],
          })),
          mcqs: Array.from({ length: 6 }, (_, i) => ({
            stem: `設問${i}`,
            choices: (['a', 'b', 'c', 'd'] as const).map(k => ({ key: k, text: k, why_wrong: k === 'a' ? '' : '誤り' })),
            answer_key: 'a' as const, explanation: '解説', kc_ids: [],
          })),
          claims: [],
        } as unknown as T,
        usage: { inputTokens: 600, outputTokens: 2000 },
        model: 'test',
      }),
    }
    const r = await generateMaterial(db, noClaims as typeof ai, { userId, unitId: UNIT, now: NOW })
    expect(r.status).toBe('failed')
    if (r.status !== 'failed') return
    expect(r.reason).toContain('検証用の主張が1件も出力されませんでした')

    // 教材も設問も1件も残らない
    const m = await db<{ n: string }[]>`SELECT count(*) AS n FROM material WHERE user_id = ${userId}`
    expect(Number(m[0]!.n)).toBe(0)
    const items = await db<{ n: string }[]>`SELECT count(*) AS n FROM item WHERE user_id = ${userId}`
    expect(Number(items[0]!.n)).toBe(0)
  })

  it('claims が少なすぎる生成物はスキーマで弾かれる（層1の入口で止める）', async () => {
    const { MaterialOutput } = await import('@/lib/ai/schema')
    const few = { claims: [{ kind: 'year', text: 'x', section_ord: 1 }] }
    const r = MaterialOutput.safeParse(few)
    expect(r.success).toBe(false)
    // 空配列も通らないこと。ここが v1 の穴だった
    expect(MaterialOutput.safeParse({ ...few, claims: [] }).success).toBe(false)
  })

  it('検証そのものが失敗したら配信しない（未検証を通さない）', async () => {
    const ai = createClient(cfg)
    // 検証プロバイダを落とす
    const broken = { ...ai, verify: async () => { throw new Error('検証プロバイダが落ちています') } }
    const r = await generateMaterial(db, broken as typeof ai, { userId, unitId: UNIT, now: NOW })
    expect(r.status).toBe('failed')
    if (r.status !== 'failed') return
    expect(r.reason).toContain('事実確認を実施できませんでした')

    const m = await db<{ n: string }[]>`SELECT count(*) AS n FROM material WHERE user_id = ${userId}`
    expect(Number(m[0]!.n)).toBe(0)
  })

  // ---- docs/07 §2: 文字数 ----

  it('文字数が範囲外なら作り直し、それでも駄目なら失敗にする', async () => {
    const ai = createClient(cfg, { charCount: 800 })
    const r = await generateMaterial(db, ai, { userId, unitId: UNIT, now: NOW })
    expect(r.status).toBe('failed')
    if (r.status !== 'failed') return
    expect(r.reason).toContain('文字数')

    const job = await db<{ status: string; attempts: number }[]>`
      SELECT status, attempts FROM generation_job WHERE user_id = ${userId}`
    expect(job[0]!.status).toBe('failed')
  })

  it('範囲内の文字数なら通る', async () => {
    const ai = createClient(cfg, { charCount: 4000 })
    const r = await generateMaterial(db, ai, { userId, unitId: UNIT, now: NOW })
    expect(r.status).toBe('ready')
    if (r.status !== 'ready') return
    expect(r.chars).toBe(4000)
  })

  // ---- docs/08 §4: 冪等とジョブ ----

  it('同じ範囲を2回叩いても二重生成しない（リロード連打）', async () => {
    const ai = createClient(cfg)
    const a = await generateMaterial(db, ai, { userId, unitId: UNIT, now: NOW })
    const b = await generateMaterial(db, ai, { userId, unitId: UNIT, now: NOW })
    expect(a.status).toBe('ready')
    expect(b.status).toBe('ready')
    if (a.status !== 'ready' || b.status !== 'ready') return
    expect(b.materialId).toBe(a.materialId)

    const jobs = await db<{ n: string }[]>`SELECT count(*) AS n FROM generation_job WHERE user_id = ${userId}`
    expect(Number(jobs[0]!.n)).toBe(1)
    // 学習履歴が無いので共有教材（user_id IS NULL）として1本だけ保存される
    const mats = await db<{ n: string }[]>`SELECT count(*) AS n FROM material`
    expect(Number(mats[0]!.n)).toBe(1)
  })

  it('失敗したジョブを同じ範囲で再実行できる（job_id を取り違えない）', async () => {
    // 1回目は文字数で失敗する。generation_job は残り、status = 'failed' になる
    const short = createClient(cfg, { charCount: 800 })
    expect((await generateMaterial(db, short, { userId, unitId: UNIT, now: NOW })).status).toBe('failed')

    // 2回目は ON CONFLICT DO UPDATE になる。既存行の id を使わないと
    // ai_spend.job_id が存在しない行を指して外部キーで落ちる
    const r = await generateMaterial(db, createClient(cfg), { userId, unitId: UNIT, now: NOW })
    expect(r.status).toBe('ready')

    const jobs = await db<{ id: string; attempts: number; status: string }[]>`
      SELECT id, attempts, status FROM generation_job WHERE user_id = ${userId}`
    expect(jobs).toHaveLength(1)
    expect(jobs[0]!.status).toBe('succeeded')
    expect(jobs[0]!.attempts).toBe(1)

    const spend = await db<{ job_id: string | null }[]>`
      SELECT job_id FROM ai_spend WHERE period = ${periodOf(NOW)} AND job_id IS NOT NULL`
    expect(spend.length).toBeGreaterThan(0)
    expect(spend.every(x => x.job_id === jobs[0]!.id)).toBe(true)
  })

  it('force で冪等の短絡を飛ばして作り直せる（blocked から抜ける唯一の道）', async () => {
    const bad = createClient(cfg, { wrongClaims: ['ウェストファリア条約は1658年'] })
    expect((await generateMaterial(db, bad, { userId, unitId: UNIT, now: NOW })).status).toBe('blocked')

    // force 無しは blocked のまま返る（冪等）
    expect((await generateMaterial(db, createClient(cfg), { userId, unitId: UNIT, now: NOW })).status)
      .toBe('blocked')

    const again = await generateMaterial(db, createClient(cfg), { userId, unitId: UNIT, now: NOW, force: true })
    expect(again.status).toBe('ready')

    // 配信できる教材は単元につき1本のまま
    const ready = await db<{ n: string }[]>`
      SELECT count(*) AS n FROM material WHERE unit_id = ${UNIT} AND status = 'ready'`
    expect(Number(ready[0]!.n)).toBe(1)
  })

  // ---- 初回教材の共有（生成費の削減） ----

  /**
   * 初回生成の時点では p_know も misconception も空なので、
   * 誰に対しても同じプロンプトが組み立つ。人数分作れば生成費だけが人数倍になる。
   */
  describe('初回教材の共有', () => {
    const personalize = async (uid: string) => {
      const kcs = await db<{ id: string }[]>`
        SELECT kc_id AS id FROM kc_syllabus_unit WHERE unit_id = ${UNIT} ORDER BY kc_id LIMIT 2`
      for (const k of kcs) {
        await db`INSERT INTO user_kc_state (user_id, kc_id, p_know, n_obs, n_eff)
                 VALUES (${uid}, ${k.id}, 0.9, 5, 4)
                 ON CONFLICT (user_id, kc_id) DO UPDATE SET p_know = 0.9`
      }
    }

    it('学習履歴が無ければ共有教材として保存される', async () => {
      const r = await generateMaterial(db, createClient(cfg), { userId, unitId: UNIT, now: NOW })
      expect(r.status).toBe('ready')
      if (r.status !== 'ready') return
      const [m] = await db<{ user_id: string | null }[]>`
        SELECT user_id FROM material WHERE id = ${r.materialId}`
      expect(m!.user_id).toBeNull()
    })

    it('2人目は生成せず共有教材を使う（呼び出しが増えない）', async () => {
      const ai = createClient(cfg)
      const a = await generateMaterial(db, ai, { userId, unitId: UNIT, now: NOW })
      const other = await createUser(db, NOW)
      const b = await generateMaterial(db, ai, { userId: other, unitId: UNIT, now: NOW })

      expect(a.status).toBe('ready')
      expect(b.status).toBe('ready')
      if (a.status !== 'ready' || b.status !== 'ready') return
      expect(b.materialId).toBe(a.materialId)

      // ★ ここが節約の実体。教材は1本、元帳も1回ぶんしか増えない
      const [mats] = await db<{ n: string }[]>`SELECT count(*) AS n FROM material`
      expect(Number(mats!.n)).toBe(1)
      const spend = await db<{ purpose: string }[]>`
        SELECT purpose FROM ai_spend WHERE period = ${periodOf(NOW)} ORDER BY id`
      expect(spend.map(x => x.purpose)).toEqual(['generate', 'factcheck'])
    })

    it('2人目にも設問が複製される（共有教材でも解ける）', async () => {
      const ai = createClient(cfg)
      await generateMaterial(db, ai, { userId, unitId: UNIT, now: NOW })
      const other = await createUser(db, NOW)
      const b = await generateMaterial(db, ai, { userId: other, unitId: UNIT, now: NOW })
      expect(b.status).toBe('ready')
      if (b.status !== 'ready') return
      expect(b.itemCount).toBe(16)

      const mine = await db<{ format: string; n: string }[]>`
        SELECT format, count(*) AS n FROM item WHERE user_id = ${userId} GROUP BY format ORDER BY format`
      const theirs = await db<{ format: string; n: string }[]>`
        SELECT format, count(*) AS n FROM item WHERE user_id = ${other} GROUP BY format ORDER BY format`
      expect(theirs).toEqual(mine)

      // 設問は利用者ごと。診断用の共有プール（user_id IS NULL）には入れない
      const [pool] = await db<{ n: string }[]>`SELECT count(*) AS n FROM item WHERE user_id IS NULL`
      expect(Number(pool!.n)).toBe(0)
    })

    it('設問の複製は繰り返しても増えない', async () => {
      const ai = createClient(cfg)
      await generateMaterial(db, ai, { userId, unitId: UNIT, now: NOW })
      const other = await createUser(db, NOW)
      await generateMaterial(db, ai, { userId: other, unitId: UNIT, now: NOW })
      await generateMaterial(db, ai, { userId: other, unitId: UNIT, now: NOW })
      const [n] = await db<{ n: string }[]>`SELECT count(*) AS n FROM item WHERE user_id = ${other}`
      expect(Number(n!.n)).toBe(16)
    })

    it('弱点が溜まった利用者には個別に作り直す', async () => {
      const ai = createClient(cfg)
      const shared = await generateMaterial(db, ai, { userId, unitId: UNIT, now: NOW })
      expect(shared.status).toBe('ready')

      const other = await createUser(db, NOW)
      await personalize(other)
      const personal = await generateMaterial(db, ai, { userId: other, unitId: UNIT, now: NOW })
      expect(personal.status).toBe('ready')
      if (shared.status !== 'ready' || personal.status !== 'ready') return

      expect(personal.materialId).not.toBe(shared.materialId)
      const [m] = await db<{ user_id: string | null }[]>`
        SELECT user_id FROM material WHERE id = ${personal.materialId}`
      expect(m!.user_id).toBe(other)

      // 共有版は残る。他の利用者はそのまま読み続ける
      const [s] = await db<{ status: string }[]>`
        SELECT status FROM material WHERE id = ${shared.materialId}`
      expect(s!.status).toBe('ready')
    })

    it('同じ単元に配信できる共有教材は1本だけ（一意索引）', async () => {
      const ai = createClient(cfg)
      const r = await generateMaterial(db, ai, { userId, unitId: UNIT, now: NOW })
      if (r.status !== 'ready') throw new Error('ready ではありません')
      await expect(db`
        INSERT INTO material (id, user_id, unit_id, title, provider, model, prompt_version, status)
        VALUES (gen_random_uuid(), NULL, ${UNIT}, '二本目', 'gemini', 'x', 'v1', 'ready')
      `).rejects.toThrow()
    })
  })

  it('generation_job にトークン数が記録される', async () => {
    const ai = createClient(cfg)
    await generateMaterial(db, ai, { userId, unitId: UNIT, now: NOW })
    const j = await db<{ status: string; input_tokens: number; output_tokens: number }[]>`
      SELECT status, input_tokens, output_tokens FROM generation_job WHERE user_id = ${userId}`
    expect(j[0]!.status).toBe('succeeded')
    expect(j[0]!.output_tokens).toBeGreaterThan(0)
  })

  // ---- docs/08 §7.1: 遮断器 ----

  it('生成と検証がそれぞれ元帳に載る', async () => {
    const ai = createClient(cfg)
    await generateMaterial(db, ai, { userId, unitId: UNIT, now: NOW })
    const rows = await db<{ purpose: string; state: string }[]>`
      SELECT purpose, state FROM ai_spend WHERE period = ${periodOf(NOW)} ORDER BY id`
    expect(rows.map(r => r.purpose)).toEqual(['generate', 'factcheck'])
    expect(rows.every(r => r.state === 'settled')).toBe(true)
  })

  it('遮断中は生成そのものが始まらない', async () => {
    await db`UPDATE ai_budget SET halted = true, halted_at = now(), halted_reason = 'manual'
              WHERE period = ${periodOf(NOW)}`
    const ai = createClient(cfg)
    const r = await generateMaterial(db, ai, { userId, unitId: UNIT, now: NOW })
    expect(r.status).toBe('failed')
    const s = await budgetStatus(db, NOW)
    expect(s.usedJpy).toBe(0)
  })

  it('教材1本の出力上限が遮断器の見積りの分母になる', () => {
    expect(MATERIAL_MAX_OUTPUT_TOKENS).toBeGreaterThan(0)
  })

  // ---- docs/08 §5 層2 ----

  /**
   * ★ ここは以前「canon_event が空なので照合0件になる」を確かめていた。
   *   それは**現状を写しただけ**で、正典を seed した瞬間に落ちる試験だった。
   *   確かめたいのは「正典に無い主張を、無いと言えること」なので、
   *   **seed に絶対に載らない架空のラベル**を使う。
   */
  it('正典に無い主張は unmatched になり、握りつぶさない', async () => {
    const r = await machineCheck(db, [
      { type: 'year', text: 'ザヴァンドリア協定は1648年', subject: 'ザヴァンドリア協定' },
      { type: 'causal', text: '因果の主張' },
    ])
    expect(r.matchable).toBe(1)          // year の1件だけが分母
    expect(r.matched).toBe(0)
    expect(r.verdicts[0]!.status).toBe('unmatched')
    expect(r.verdicts[0]!.reason).toContain('canon_event')
    expect(r.verdicts[1]!.status).toBe('unmatched')   // causal は対象外
  })

  it('年を読み取れない主張は分母に入れない（正典を足しても照合できないため）', async () => {
    const r = await machineCheck(db, [
      { type: 'year', text: '前18世紀にハンムラビ法典が定められた' },
    ])
    expect(r.matchable).toBe(0)          // ← 分母から外す
    expect(r.unreadable).toBe(1)
    expect(r.verdicts[0]!.reason).toContain('年を読み取れない')
  })

  it('subject があれば本文全体ではなく subject で照合する', async () => {
    await db`INSERT INTO canon_event (id, label, year_from, precision)
             VALUES ('ce.t30', '三十年戦争', 1618, 'exact') ON CONFLICT (id) DO NOTHING`
    try {
      // 本文には「三十年戦争」が入っているが、主張しているのは条約の年である。
      // subject を見なければ三十年戦争の正典に当たり、1648 が誤りとされてしまう
      const r = await machineCheck(db, [{
        type: 'year',
        text: '三十年戦争を終わらせたザヴァンドリア協定は1648年に結ばれた',
        subject: 'ザヴァンドリア協定',
      }])
      expect(r.verdicts[0]!.status).toBe('unmatched')
      expect(r.verdicts[0]!.canonId).toBeUndefined()
    } finally {
      await db`DELETE FROM canon_event WHERE id = 'ce.t30'`
    }
  })

  it('短いラベルが長いラベルを食わない（最長一致・毎回同じ正典に当たる）', async () => {
    await db`INSERT INTO canon_event (id, label, year_from, precision) VALUES
             ('ce.short', 'ザヴァンドリア', 1600, 'exact'),
             ('ce.long',  'ザヴァンドリア協定', 1648, 'exact')
             ON CONFLICT (id) DO NOTHING`
    try {
      const claim = { type: 'year' as const, text: 'ザヴァンドリア協定は1648年', subject: 'ザヴァンドリア協定' }
      const a = await machineCheck(db, [claim])
      const b = await machineCheck(db, [claim])
      expect(a.verdicts[0]!.canonId).toBe('ce.long')   // 短い方に当たると 1600 年で wrong になる
      expect(a.verdicts[0]!.status).toBe('ok')
      expect(b.verdicts[0]!.canonId).toBe(a.verdicts[0]!.canonId)  // 決定的
    } finally {
      await db`DELETE FROM canon_event WHERE id IN ('ce.short','ce.long')`
    }
  })

  it('claim の year_from を本文の抽出より優先する', async () => {
    await db`INSERT INTO canon_event (id, label, year_from, precision)
             VALUES ('ce.yf', 'ザヴァンドリア協定', 1648, 'exact') ON CONFLICT (id) DO NOTHING`
    try {
      // 本文には年が書かれていない。構造化された year_from だけが手がかり
      const r = await machineCheck(db, [{
        type: 'year', text: 'ザヴァンドリア協定が結ばれた',
        subject: 'ザヴァンドリア協定', yearFrom: 1648,
      }])
      expect(r.verdicts[0]!.status).toBe('ok')
      expect(r.matched).toBe(1)
    } finally {
      await db`DELETE FROM canon_event WHERE id = 'ce.yf'`
    }
  })

  it('誤りの理由から、当たった正典の id を辿れる', async () => {
    // ★ 年号は一括承認で入れており検算していない。誤っているのが教材ではなく
    //   正典の側でありうるので、どの行に当たったかが分からないと直せない
    await db`INSERT INTO canon_event (id, label, year_from, precision)
             VALUES ('ce.trace', 'ザヴァンドリア協定', 1648, 'exact') ON CONFLICT (id) DO NOTHING`
    try {
      const r = await machineCheck(db, [{
        type: 'year', text: 'ザヴァンドリア協定は1658年', subject: 'ザヴァンドリア協定',
      }])
      expect(r.verdicts[0]!.status).toBe('wrong')
      expect(r.verdicts[0]!.reason).toContain('ce.trace')
      expect(r.verdicts[0]!.canonId).toBe('ce.trace')
    } finally {
      await db`DELETE FROM canon_event WHERE id = 'ce.trace'`
    }
  })

  it('century の正典でも year_to を見る（期間の後半を誤りにしない）', async () => {
    // ★ 実データを書いていて見つけた。以前は year_from からの ±100 だけを見て
    //   year_to を捨てていたので、「ローマの平和（前27〜後180）」のような期間では
    //   後半（74〜180年）がまるごと範囲外になり、正しい年が wrong になっていた
    await db`INSERT INTO canon_event (id, label, year_from, year_to, precision)
             VALUES ('ce.period', 'ザヴァンドリアの平和', -27, 180, 'century')
             ON CONFLICT (id) DO NOTHING`
    try {
      const at = async (y: number) => {
        const r = await machineCheck(db, [{
          type: 'year', text: 'x', subject: 'ザヴァンドリアの平和', yearFrom: y,
        }])
        return r.verdicts[0]!.status
      }
      expect(await at(150)).toBe('ok')     // 期間の後半。以前はここが wrong だった
      expect(await at(-27)).toBe('ok')
      expect(await at(180)).toBe('ok')
      expect(await at(400)).toBe('wrong')  // 範囲＋100 を超えたら誤り
    } finally {
      await db`DELETE FROM canon_event WHERE id = 'ce.period'`
    }
  })

  it('照合率は分母が0なら null（0除算を0%と偽らない）', () => {
    expect(matchRate({ verdicts: [], matched: 0, matchable: 0, unreadable: 0 })).toBeNull()
    expect(matchRate({ verdicts: [], matched: 4, matchable: 5, unreadable: 2 })).toBeCloseTo(0.8)
  })

  it('canon_event があれば年号のずれを課金なしで捕まえる', async () => {
    await db`INSERT INTO canon_event (id, label, year_from, precision)
             VALUES ('ce.westphalia', 'ウェストファリア条約', 1648, 'exact')
             ON CONFLICT (id) DO NOTHING`
    const ok = await machineCheck(db, [{ type: 'year', text: 'ウェストファリア条約は1648年' }])
    expect(ok.verdicts[0]!.status).toBe('ok')
    expect(ok.matched).toBe(1)

    const ng = await machineCheck(db, [{ type: 'year', text: 'ウェストファリア条約は1658年' }])
    expect(ng.verdicts[0]!.status).toBe('wrong')
    expect(ng.verdicts[0]!.reason).toContain('1648')
    await db`DELETE FROM canon_event WHERE id = 'ce.westphalia'`
  })

  it('層2で誤りが確定したら層3を呼ばない（課金しない）', async () => {
    await db`INSERT INTO canon_event (id, label, year_from, precision)
             VALUES ('ce.w2', 'ウェストファリア条約', 1648, 'exact') ON CONFLICT (id) DO NOTHING`
    const ai = createClient(cfg, { wrongClaims: ['ウェストファリア条約は1658年'] })
    const r = await generateMaterial(db, ai, { userId, unitId: UNIT, now: NOW })
    expect(r.status).toBe('blocked')

    const rows = await db<{ purpose: string }[]>`
      SELECT purpose FROM ai_spend WHERE period = ${periodOf(NOW)} ORDER BY id`
    expect(rows.map(x => x.purpose)).toEqual(['generate']) // factcheck を呼んでいない
    await db`DELETE FROM canon_event WHERE id = 'ce.w2'`
  })

  // ---- docs/08 §4: 匿名化 ----

  it('プロンプトに user_id が載らない', async () => {
    const ai = createClient(cfg)
    let sent = ''
    const spy = {
      ...ai,
      generate: async (a: Parameters<typeof ai.generate>[0]) => {
        sent = a.prompt.system + a.prompt.user
        return ai.generate(a)
      },
    }
    await generateMaterial(db, spy as typeof ai, { userId, unitId: UNIT, now: NOW })
    expect(sent).not.toContain(userId)
    expect(sent).toContain('古代オリエント世界')
  })
})
