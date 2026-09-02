/**
 * Gemini プロバイダ（生成）
 *
 * 仕様: docs/08-ai-architecture.md §1.1・§7
 *
 * ★ generativelanguage.googleapis.com を直接叩く。**Vertex AI は経由しない。**
 *   無料枠があるのは AI Studio 系のこの経路だけである（§1.1）。
 */
import type { Provider, GenerateArgs, GenerateResult, VerifyResult, Claim, Usage } from './types'
import { fetchWithRetry, type Sleep } from './http'
import { MaterialOutput, toGeminiSchema } from './schema'

const BASE = 'https://generativelanguage.googleapis.com/v1beta'

export type GeminiOptions = {
  apiKey: string
  model: string
  embedModel: string
  fetchImpl?: typeof fetch
  sleep?: Sleep
}

type GeminiResponse = {
  candidates?: Array<{
    content?: { parts?: Array<{ text?: string }> }
    finishReason?: string
  }>
  usageMetadata?: { promptTokenCount?: number; candidatesTokenCount?: number }
  promptFeedback?: { blockReason?: string }
}

export class GeminiBlockedError extends Error {
  constructor(readonly reason: string) {
    super(`Gemini が生成を拒否しました: ${reason}`)
    this.name = 'GeminiBlockedError'
  }
}

export class SchemaViolationError extends Error {
  constructor(readonly detail: string) {
    super(`生成結果がスキーマに適合しません: ${detail}`)
    this.name = 'SchemaViolationError'
  }
}

export function createGeminiProvider(o: GeminiOptions): Provider {
  const call = async (path: string, body: unknown): Promise<Response> =>
    fetchWithRetry(
      `${BASE}${path}`,
      {
        method: 'POST',
        // 鍵はヘッダで送る。URL に載せるとログや Referer に漏れる
        headers: { 'content-type': 'application/json', 'x-goog-api-key': o.apiKey },
        body: JSON.stringify(body),
      },
      { provider: 'gemini', fetchImpl: o.fetchImpl, sleep: o.sleep },
    )

  return {
    name: 'gemini',

    async generate<T>(args: GenerateArgs): Promise<GenerateResult<T>> {
      const res = await call(`/models/${o.model}:generateContent`, {
        systemInstruction: { parts: [{ text: args.prompt.system }] },
        contents: [{ role: 'user', parts: [{ text: args.prompt.user }] }],
        generationConfig: {
          responseMimeType: 'application/json',
          // Gemini の responseSchema は OpenAPI 3.0 の部分集合なので、
          // 通らないキーワードを落として渡す（lib/ai/schema.ts）
          responseSchema: toGeminiSchema(args.schema),
          // ★ 省略しない。遮断器の見積りの上限を定義する値である（docs/08 §7.1）
          maxOutputTokens: args.maxOutputTokens,
          temperature: 0.4,
        },
      })

      const json = (await res.json()) as GeminiResponse
      if (json.promptFeedback?.blockReason) throw new GeminiBlockedError(json.promptFeedback.blockReason)

      const finish = json.candidates?.[0]?.finishReason
      if (finish && finish !== 'STOP') {
        // MAX_TOKENS で切れた JSON をパースしても壊れているだけなので、ここで落とす
        throw new GeminiBlockedError(`finishReason=${finish}`)
      }

      const text = json.candidates?.[0]?.content?.parts?.map(p => p.text ?? '').join('') ?? ''
      if (!text) throw new SchemaViolationError('本文が空です')

      let parsed: unknown
      try {
        parsed = JSON.parse(text)
      } catch {
        throw new SchemaViolationError('JSON として読めません')
      }

      // ★ モデルがスキーマを守る保証はどのプロバイダにも無い。必ずこちらで検証する
      const check = MaterialOutput.safeParse(parsed)
      if (!check.success) {
        throw new SchemaViolationError(
          check.error.issues.slice(0, 5).map(i => `${i.path.join('.')}: ${i.message}`).join(' / '),
        )
      }

      const usage: Usage = {
        inputTokens: json.usageMetadata?.promptTokenCount ?? 0,
        outputTokens: json.usageMetadata?.candidatesTokenCount ?? 0,
      }
      return { value: check.data as unknown as T, usage, model: o.model }
    },

    async verify(): Promise<VerifyResult> {
      // 生成と検証は必ず別プロバイダにする（docs/08 §6）。
      // 生成側で検証させると同一モデルの自己検証に退化する
      throw new Error('gemini は検証に使わない設定です（docs/08 §2.1）')
    },

    async embed(texts: string[]) {
      const res = await call(`/models/${o.embedModel}:batchEmbedContents`, {
        requests: texts.map(t => ({
          model: `models/${o.embedModel}`,
          content: { parts: [{ text: t }] },
        })),
      })
      const json = (await res.json()) as { embeddings?: Array<{ values?: number[] }> }
      const vectors = (json.embeddings ?? []).map(e => e.values ?? [])
      if (vectors.length !== texts.length) {
        throw new Error(`gemini: 埋め込みの件数が合いません（${vectors.length} / ${texts.length}）`)
      }
      return {
        vectors,
        usage: { inputTokens: texts.join('').length, outputTokens: 0 },
        model: o.embedModel,
      }
    },
  }
}

/** Claim を検証に渡す形にそろえる（Anthropic 側で使う） */
export const claimsToText = (claims: Claim[]): string =>
  claims.map((c, i) => `${i}. [${c.type}] ${c.text}`).join('\n')
