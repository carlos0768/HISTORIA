/**
 * AI クライアント — 外に出る唯一の経路
 *
 * 仕様: docs/08-ai-architecture.md §6, §7.1
 *
 * ★ アプリのどこからも fetch で直接 LLM を呼ばない。ここだけが外に出る。
 * ★ 生成と検証は必ず別プロバイダにする。同一モデルの自己検証に退化するため、
 *   両方が同じ値になる設定は起動時に拒否する。
 * ★ すべての呼び出しは支出遮断器の関門を通る。迂回路を作らない。
 */
import type { Sql } from 'postgres'
import type { Claim, GenerateResult, Provider, RenderedPrompt, VerifyResult } from './types'
import { createFakeProvider, type FakeOptions } from './fake'
import { createGeminiProvider } from './gemini'
import { createAnthropicProvider } from './anthropic'
import { assertNoIdentifiers } from './redact'
import { reserve, settle, release, estimateJpy, type Purpose, type Price } from './budget'

export type AiConfig = {
  genProvider: string
  genModel: string
  verifyProvider: string
  verifyModel: string
  embedModel: string
  geminiApiKey?: string
  anthropicApiKey?: string
}

export function readConfig(env: NodeJS.ProcessEnv = process.env): AiConfig {
  return {
    genProvider: env.GEN_PROVIDER ?? 'gemini',
    genModel: env.GEN_MODEL ?? 'gemini-3.6-flash',
    verifyProvider: env.VERIFY_PROVIDER ?? 'anthropic',
    verifyModel: env.VERIFY_MODEL ?? 'claude-sonnet-5',
    embedModel: env.EMBED_MODEL ?? 'gemini-embedding-001',
    geminiApiKey: env.GEMINI_API_KEY || undefined,
    anthropicApiKey: env.ANTHROPIC_API_KEY || undefined,
  }
}

/**
 * 起動時の設定検査。
 * 生成と検証が同じプロバイダだと、同じモデルが同じ誤りを見逃すため
 * ファクトチェックが自己検証に退化する（§2.1）。
 */
export function assertConfig(cfg: AiConfig): void {
  if (cfg.genProvider === cfg.verifyProvider) {
    throw new Error(
      `GEN_PROVIDER と VERIFY_PROVIDER が同じです（${cfg.genProvider}）。` +
        '同一系統のモデルによる自己検証に退化するため許可しません（docs/08 §6）。',
    )
  }
}

/** USD / MTok。docs/08 §3.4 */
export const PRICES: Record<string, Price> = {
  'claude-sonnet-5': { inputPerMTok: 2, outputPerMTok: 10 },
  // ★ Gemini の単価をここに書かない。
  //   docs/08 は「無料枠だから0円」を前提にしていたが、2026-09-02 の実測では
  //   gemini-2.5-flash が新規利用者に 404、他のモデルは
  //   「前払いクレジットが尽きた」の 429 を返した。
  //   **この鍵からは無料枠の存在を確認できていない**（docs/14 M28）。
  //   0 と書くと estimateJpy が 0 を返し、遮断器が生成を1円も数えなくなる。
  //   実際に課金されていた場合、元帳が空のまま支出だけが進む。
  //   単価を実測できるまでは、下の未知モデルの見積り（高め）に落ちるままにする。
}

const priceOf = (model: string): Price =>
  PRICES[model] ?? { inputPerMTok: 3, outputPerMTok: 15 } // 未知のモデルは高めに見積もる

/**
 * 鍵があれば実物、無ければフェイクにする。
 * フェイクは実物と同じ型・同じ制約で動くので、鍵が無くても閉ループは最後まで通る。
 */
function resolveProvider(name: string, cfg: AiConfig, fake: FakeOptions = {}): Provider {
  if (name === 'gemini' && cfg.geminiApiKey) {
    return createGeminiProvider({
      apiKey: cfg.geminiApiKey, model: cfg.genModel, embedModel: cfg.embedModel,
    })
  }
  if (name === 'anthropic' && cfg.anthropicApiKey) {
    return createAnthropicProvider({ apiKey: cfg.anthropicApiKey, model: cfg.verifyModel })
  }
  return createFakeProvider(name, fake)
}

export type GenerateCall = {
  db: Sql; prompt: RenderedPrompt; schema: object; maxOutputTokens: number
  purpose?: Purpose; jobId?: string | null; now: Date
}
export type VerifyCall = {
  db: Sql; claims: Claim[]; maxOutputTokens: number; jobId?: string | null; now: Date
}
export type EmbedCall = { db: Sql; texts: string[]; now: Date }

export type Client = {
  config: AiConfig
  usingFake: boolean
  generate<T>(a: GenerateCall): Promise<GenerateResult<T>>
  verify(a: VerifyCall): Promise<VerifyResult>
  embed(a: EmbedCall): Promise<{ vectors: number[][]; model: string }>
}

export function createClient(cfg: AiConfig = readConfig(), fake: FakeOptions = {}): Client {
  assertConfig(cfg)
  const gen = resolveProvider(cfg.genProvider, cfg, fake)
  const ver = resolveProvider(cfg.verifyProvider, cfg, fake)
  const usingFake = !cfg.geminiApiKey || !cfg.anthropicApiKey

  /** 予約 → 呼び出し → 確定。失敗したら解放する */
  async function guarded<R extends { usage: { inputTokens: number; outputTokens: number } }>(
    db: Sql, now: Date, model: string, provider: string, purpose: Purpose,
    maxInputTokens: number, maxOutputTokens: number, jobId: string | null | undefined,
    run: () => Promise<R>,
  ): Promise<R> {
    const price = priceOf(model)
    const est = estimateJpy(maxInputTokens, maxOutputTokens, price)
    const r = await reserve(db, { estJpy: est, provider, model, purpose, jobId, now })
    try {
      const out = await run()
      const actual = Math.min(
        est,
        estimateJpy(out.usage.inputTokens, out.usage.outputTokens, price),
      )
      await settle(db, r, { ...out.usage, actualJpy: actual })
      return out
    } catch (e) {
      await release(db, r)
      throw e
    }
  }

  return {
    config: cfg,
    usingFake,

    async generate<T>(a: GenerateCall) {
      // 型だけでなく実行時にも個人識別情報の混入を止める（§4.2）。
      // renderMaterialPrompt でも検査しているが、経路を1つに絞れない以上ここでも見る
      assertNoIdentifiers(a.prompt.system)
      assertNoIdentifiers(a.prompt.user)
      // 入力の上限はプロンプトの実測値から。教材生成は出力が支配的
      const maxIn = Math.ceil((a.prompt.system.length + a.prompt.user.length) / 1.5) + 1000
      return guarded(
        a.db, a.now, cfg.genModel, cfg.genProvider, a.purpose ?? 'generate',
        maxIn, a.maxOutputTokens, a.jobId,
        () => gen.generate<T>({ prompt: a.prompt, schema: a.schema, maxOutputTokens: a.maxOutputTokens }),
      )
    },

    async verify(a: VerifyCall) {
      const maxIn = Math.ceil(JSON.stringify(a.claims).length / 1.5) + 500
      return guarded(
        a.db, a.now, cfg.verifyModel, cfg.verifyProvider, 'factcheck',
        maxIn, a.maxOutputTokens, a.jobId,
        () => ver.verify(a.claims, a.maxOutputTokens),
      )
    },

    async embed(a: EmbedCall) {
      const maxIn = Math.ceil(a.texts.join('').length / 1.5)
      const out = await guarded(
        a.db, a.now, cfg.embedModel, cfg.genProvider, 'embed', maxIn, 0, null,
        () => gen.embed(a.texts),
      )
      return { vectors: out.vectors, model: out.model }
    },
  }
}
