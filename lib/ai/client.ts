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
import type { AnonymizedContext, Claim, GenerateResult, Provider, VerifyResult } from './types'
import { createFakeProvider } from './fake'
import { assertAnonymized } from './redact'
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
    genModel: env.GEN_MODEL ?? 'gemini-2.5-flash',
    verifyProvider: env.VERIFY_PROVIDER ?? 'anthropic',
    verifyModel: env.VERIFY_MODEL ?? 'claude-sonnet-5',
    embedModel: env.EMBED_MODEL ?? 'text-embedding-004',
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
  // 無料枠。0 でも元帳には載せる（迂回路を作らないため）
  'gemini-2.5-flash': { inputPerMTok: 0, outputPerMTok: 0 },
  'text-embedding-004': { inputPerMTok: 0, outputPerMTok: 0 },
}

const priceOf = (model: string): Price =>
  PRICES[model] ?? { inputPerMTok: 3, outputPerMTok: 15 } // 未知のモデルは高めに見積もる

/** 鍵が無いプロバイダはフェイクにする。閉ループが最後まで通ることを優先する */
function resolveProvider(name: string, cfg: AiConfig): Provider {
  if (name === 'gemini' && cfg.geminiApiKey) throw new Error('gemini の実装は未接続です（鍵はあります）')
  if (name === 'anthropic' && cfg.anthropicApiKey) throw new Error('anthropic の実装は未接続です（鍵はあります）')
  return createFakeProvider(name)
}

export type GenerateCall = {
  db: Sql; context: AnonymizedContext; schema: object; maxOutputTokens: number
  promptVersion: string; purpose?: Purpose; jobId?: string | null; now: Date
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

export function createClient(cfg: AiConfig = readConfig()): Client {
  assertConfig(cfg)
  const gen = resolveProvider(cfg.genProvider, cfg)
  const ver = resolveProvider(cfg.verifyProvider, cfg)
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
      // 型だけでなく実行時にも個人識別情報の混入を止める（§4.2）
      assertAnonymized(a.context)
      // 入力の上限は文脈の実測値から。教材生成は出力が支配的
      const maxIn = Math.ceil(JSON.stringify(a.context).length / 1.5) + 2000
      return guarded(
        a.db, a.now, cfg.genModel, cfg.genProvider, a.purpose ?? 'generate',
        maxIn, a.maxOutputTokens, a.jobId,
        () => gen.generate<T>({
          context: a.context, schema: a.schema,
          maxOutputTokens: a.maxOutputTokens, promptVersion: a.promptVersion,
        }),
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
