import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import { seedMasters, seedKc, SEED_DIR } from '@/scripts/db/seed'
import { createClient, type AiConfig } from '@/lib/ai/client'
import { ensureBudgetRow, budgetStatus, periodOf } from '@/lib/ai/budget'
import { generateMaterial, paramsHash, MATERIAL_MAX_OUTPUT_TOKENS } from './generate'
import { machineCheck, extractYear } from './factcheck'
import { createUser } from '@/lib/loop/fixture'
import { MATERIAL_PROMPT_VERSION } from '@/lib/ai/prompt'

const cfg: AiConfig = {
  genProvider: 'gemini', genModel: 'gemini-2.5-flash',
  verifyProvider: 'anthropic', verifyModel: 'claude-sonnet-5',
  embedModel: 'text-embedding-004',
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
    const mats = await db<{ n: string }[]>`SELECT count(*) AS n FROM material WHERE user_id = ${userId}`
    expect(Number(mats[0]!.n)).toBe(1)
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

  it('canon_event が空なので層2は照合0件になる（この状態を握りつぶさない）', async () => {
    const r = await machineCheck(db, [
      { type: 'year', text: 'ウェストファリア条約は1648年' },
      { type: 'causal', text: '因果の主張' },
    ])
    expect(r.matchable).toBe(1)
    expect(r.matched).toBe(0)
    expect(r.verdicts[0]!.status).toBe('unmatched')
    expect(r.verdicts[0]!.reason).toContain('canon_event')
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
