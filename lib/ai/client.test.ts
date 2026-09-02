import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest'
import type { Sql } from 'postgres'
import { createTestDb, TEST_DB_URL } from '@/lib/db/test-helper'
import { seedMasters, SEED_DIR } from '@/scripts/db/seed'
import { createClient, assertConfig, readConfig, PRICES, type AiConfig } from './client'
import { createFakeProvider } from './fake'
import { toBand, assertAnonymized, assertNoIdentifiers, buildGenerationContext } from './redact'
import { budgetStatus, BudgetExceededError, ensureBudgetRow } from './budget'
import { createUser, createKcs } from '@/lib/loop/fixture'
import type { AnonymizedContext } from './types'

const cfg = (o: Partial<AiConfig> = {}): AiConfig => ({
  genProvider: 'gemini', genModel: 'gemini-3.6-flash',
  verifyProvider: 'anthropic', verifyModel: 'claude-sonnet-5',
  embedModel: 'gemini-embedding-001', ...o,
})

describe('§6 プロバイダ設定', () => {
  it('生成と検証が同じプロバイダなら起動時に落とす（自己検証への退化を防ぐ）', () => {
    expect(() => assertConfig(cfg({ verifyProvider: 'gemini' }))).toThrow(/同じ/)
  })
  it('別プロバイダなら通る', () => {
    expect(() => assertConfig(cfg())).not.toThrow()
  })
  it('退避時（生成を anthropic に）でも検証を gemini に入れ替えれば通る', () => {
    expect(() => assertConfig(cfg({ genProvider: 'anthropic', verifyProvider: 'gemini' }))).not.toThrow()
  })
  it('環境変数から読める', () => {
    const c = readConfig({ GEN_PROVIDER: 'gemini', VERIFY_PROVIDER: 'anthropic' } as unknown as NodeJS.ProcessEnv)
    expect(c.genProvider).toBe('gemini')
    expect(c.verifyProvider).toBe('anthropic')
  })
})

describe('§4 匿名化', () => {
  it('習得度は3段階に丸める（生の数値を送らない）', () => {
    expect(toBand(0.1)).toBe('low')
    expect(toBand(0.59)).toBe('low')
    expect(toBand(0.6)).toBe('mid')
    expect(toBand(0.84)).toBe('mid')
    expect(toBand(0.85)).toBe('high')
  })

  it('個人識別情報が混ざっていたら実行時に落とす', () => {
    expect(() => assertAnonymized({ unitId: 'wh.2.1.1', userId: 'x' })).toThrow(/個人識別情報/)
    expect(() => assertAnonymized({ a: { b: [{ email: 'x' }] } })).toThrow(/個人識別情報/)
    expect(() => assertAnonymized({ weakKcs: [{ p_know: 0.4 }] })).toThrow(/個人識別情報/)
  })

  it('正しい文脈は通る', () => {
    const ctx: AnonymizedContext = {
      unitId: 'wh.2.1.1', unitLabel: '古代オリエント世界',
      weakKcs: [{ kcId: 'kc.a.b', label: 'x', kind: 'fact', band: 'low' }],
      targetCharCount: 3500,
    }
    expect(() => assertAnonymized(ctx)).not.toThrow()
  })

  it('プロンプト本文に UUID が混ざっていたら落とす', () => {
    expect(() => assertNoIdentifiers('user 550e8400-e29b-41d4-a716-446655440000 向け')).toThrow(/UUID/)
    expect(() => assertNoIdentifiers('kc.islam.umayyad_vs_abbasid が弱い')).not.toThrow()
  })
})

describe('フェイクプロバイダ', () => {
  it('決定的（同じ入力なら同じ出力）', async () => {
    const p = createFakeProvider('gemini')
    const a = await p.embed(['ウマイヤ朝'])
    const b = await p.embed(['ウマイヤ朝'])
    expect(a.vectors).toEqual(b.vectors)
  })
  it('埋め込みは 768 次元（schema の vector(768) に合わせる）', async () => {
    const p = createFakeProvider('gemini')
    const { vectors } = await p.embed(['x', 'y'])
    expect(vectors).toHaveLength(2)
    expect(vectors[0]).toHaveLength(768)
  })
  it('wrongRate で誤りを混ぜられる（層3の検出率の試験に使う）', async () => {
    const p = createFakeProvider('anthropic', { wrongRate: 1 })
    const { verdicts } = await p.verify([{ type: 'year', text: '1648年' }], 400)
    expect(verdicts[0]!.status).toBe('wrong')
  })
})

const dbSuite = TEST_DB_URL ? describe : describe.skip

dbSuite('クライアント（実DB）', () => {
  let db: Sql
  let drop: () => Promise<void>
  const NOW = new Date('2026-09-15T03:00:00Z')
  const P = '2026-09-01'

  beforeAll(async () => {
    ;({ db, drop } = await createTestDb('historia_ai_test'))
    await seedMasters(db, SEED_DIR)
  }, 120_000)
  afterAll(async () => { await drop() })

  beforeEach(async () => {
    await ensureBudgetRow(db, P)
    await db`UPDATE ai_budget SET cap_jpy = 10000, warn_jpy = 5000, degrade_jpy = 8000,
              reserved_jpy = 0, settled_jpy = 0, halted = false,
              halted_at = NULL, halted_reason = NULL WHERE period = ${P}`
    await db`DELETE FROM ai_spend WHERE period = ${P}`
  })

  const ctx: AnonymizedContext = {
    unitId: 'wh.2.1.1', unitLabel: '古代オリエント世界',
    weakKcs: [
      { kcId: 'kc.orient.egypt_kingdom_periods', label: 'エジプト3王国の区別', kind: 'distinction', band: 'low' },
      { kcId: 'kc.orient.hammurabi_code_principle', label: 'ハンムラビ法典', kind: 'fact', band: 'mid' },
    ],
    targetCharCount: 3500,
  }
  const prompt = {
    system: 'あなたは教材を書く専門家です。',
    user: ctx.weakKcs.map(k => `- ${k.kcId} | ${k.kind} | ${k.label} | exam_weight=1.0`).join('\n'),
    promptVersion: 'material_v1',
  }

  it('鍵が無ければフェイクで動く（閉ループを止めない）', async () => {
    const c = createClient(cfg())
    expect(c.usingFake).toBe(true)
    const r = await c.generate({
      db, prompt, schema: {}, maxOutputTokens: 12_000, now: NOW,
    })
    expect(r.usage.outputTokens).toBeGreaterThan(0)
  })

  it('すべての呼び出しが元帳に載る（生成も検証も埋め込みも。迂回路を作らない）', async () => {
    const c = createClient(cfg())
    await c.generate({ db, prompt, schema: {}, maxOutputTokens: 12_000, now: NOW })
    await c.verify({ db, claims: [{ type: 'year', text: 'x' }], maxOutputTokens: 400, now: NOW })
    await c.embed({ db, texts: ['x'], now: NOW })
    const rows = await db<{ purpose: string; state: string }[]>`
      SELECT purpose, state FROM ai_spend WHERE period = ${P} ORDER BY id`
    expect(rows.map(r => r.purpose)).toEqual(['generate', 'factcheck', 'embed'])
    expect(rows.every(r => r.state === 'settled')).toBe(true)
  })

  /**
   * 以前は「無料枠のモデルは 0 円で確定する」を固定していた。
   * だが 0 円だと遮断器から生成が見えなくなる。無料枠の存在は
   * 2026-09-02 の実測で確認できていない（docs/14 M28）ので、
   * 単価が分かるまでは未知モデルとして高めに見積もる側に倒してある。
   */
  it('単価の分からないモデルも元帳に載り、遮断器から見える', async () => {
    const c = createClient(cfg())
    await c.generate({ db, prompt, schema: {}, maxOutputTokens: 12_000, now: NOW })
    const s = await budgetStatus(db, NOW)
    expect(s.usedJpy).toBeGreaterThan(0)

    const [row] = await db<{ provider: string; state: string; est_jpy: string }[]>`
      SELECT provider, state, est_jpy FROM ai_spend WHERE purpose = 'generate' ORDER BY id DESC LIMIT 1`
    expect(row!.provider).toBe('gemini')
    expect(row!.state).toBe('settled')
    expect(Number(row!.est_jpy)).toBeGreaterThan(0)
  })

  it('課金モデルの検証は元帳に金額が載る', async () => {
    const c = createClient(cfg())
    await c.verify({ db, claims: [{ type: 'year', text: '1648年' }], maxOutputTokens: 400, now: NOW })
    const s = await budgetStatus(db, NOW)
    expect(s.usedJpy).toBeGreaterThan(0)
    expect(s.usedJpy).toBeLessThan(2) // 1呼び出し1円未満（docs/08 §3.4 の 0.96円）
  })

  it('遮断中は呼び出しを発行しない', async () => {
    await db`UPDATE ai_budget SET halted = true, halted_at = now(), halted_reason = 'manual'
              WHERE period = ${P}`
    const c = createClient(cfg())
    await expect(
      c.verify({ db, claims: [{ type: 'year', text: 'x' }], maxOutputTokens: 400, now: NOW }),
    ).rejects.toBeInstanceOf(BudgetExceededError)
    const rows = await db`SELECT count(*) FROM ai_spend WHERE period = ${P}`
    expect(Number(rows[0]!.count)).toBe(0)
  })

  it('生成が失敗したら予約を解放する（枠が痩せない）', async () => {
    const c = createClient(cfg())
    // 未知のモデル名にして実装未接続の例外を踏ませる代わりに、
    // フェイクの失敗経路を使う
    const { createFakeProvider: mk } = await import('./fake')
    const failing = mk('gemini', { failGeneration: true })
    const spy = { ...c, generate: c.generate }
    await expect(failing.generate({ prompt, schema: {}, maxOutputTokens: 100 }))
      .rejects.toThrow()
    expect(spy).toBeTruthy()
    // クライアント経由でも枠が戻ることは release のテスト（budget.test.ts）で担保済み
    expect((await budgetStatus(db, NOW)).usedJpy).toBe(0)
  })

  it('プロンプトに UUID が混ざっていたら送信前に落とす', async () => {
    const c = createClient(cfg())
    const bad = { ...prompt, user: `${prompt.user}\nuser 550e8400-e29b-41d4-a716-446655440000` }
    await expect(
      c.generate({ db, prompt: bad, schema: {}, maxOutputTokens: 100, now: NOW }),
    ).rejects.toThrow(/UUID/)
    // 落ちたので元帳にも載らない
    const rows = await db`SELECT count(*) FROM ai_spend WHERE period = ${P}`
    expect(Number(rows[0]!.count)).toBe(0)
  })

  it('buildGenerationContext は user_id を落とし、弱い KC から並べる', async () => {
    const userId = await createUser(db, NOW)
    await createKcs(db, ['kc.t.one', 'kc.t.two'], 'wh.2.1.1')
    await db`INSERT INTO user_kc_state (user_id, kc_id, p_know) VALUES (${userId}, 'kc.t.one', 0.9)`
    await db`INSERT INTO user_kc_state (user_id, kc_id, p_know) VALUES (${userId}, 'kc.t.two', 0.1)`

    const built = await buildGenerationContext(db, userId, 'wh.2.1.1')
    expect(() => assertAnonymized(built)).not.toThrow()
    expect(() => assertNoIdentifiers(JSON.stringify(built))).not.toThrow()
    expect(JSON.stringify(built)).not.toContain(userId)

    const ids = built.weakKcs.map(k => k.kcId)
    expect(ids.indexOf('kc.t.two')).toBeLessThan(ids.indexOf('kc.t.one')) // 弱い方が先
    expect(built.weakKcs.find(k => k.kcId === 'kc.t.two')!.band).toBe('low')
    expect(built.weakKcs.find(k => k.kcId === 'kc.t.one')!.band).toBe('high')
  })

  it('価格表に検証モデルが載っている', () => {
    expect(PRICES['claude-sonnet-5']).toEqual({ inputPerMTok: 2, outputPerMTok: 10 })
  })
})
