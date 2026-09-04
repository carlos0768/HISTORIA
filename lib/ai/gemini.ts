/**
 * Gemini プロバイダ（生成・検証）
 *
 * 仕様: docs/08-ai-architecture.md §1.1・§7
 *
 * ★ generativelanguage.googleapis.com を直接叩く。**Vertex AI は経由しない。**
 *   もともとは無料枠が AI Studio 系のこの経路にしか無かったためだが（§1.1）、
 *   2026-09-04 に課金枠へ移った後もこの経路のままにしている。
 *
 * ★ 生成と検証の**両方**を実装する。どちらに使うかは設定で決まる。
 *   2026-09-04 に向きが「生成 Claude / 検証 Gemini」へ入れ替わった。
 *   それまでここは生成専用で、verify() は必ず例外を投げていた。
 *
 * ★ 「自己検証への退化」を防ぐのはこのファイルの仕事ではない。
 *   `client.ts` の `assertConfig` が生成と検証を別プロバイダに強制する。
 *   **片方の口を塞いで防ぐと、向きを変えた瞬間に製品が動かなくなる**（実際になった）。
 */
import type { Provider, GenerateArgs, GenerateResult, VerifyResult, Claim, Verdict, Usage } from './types'
import { fetchWithRetry, type Sleep } from './http'
import { MaterialOutput, VerdictOutput, toGeminiSchema, verdictJsonSchema } from './schema'

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

export class GeminiVerifyFailedError extends Error {
  constructor(readonly detail: string) {
    super(`検証に失敗しました: ${detail}`)
    this.name = 'GeminiVerifyFailedError'
  }
}

/** 検証の指示。anthropic.ts の SYSTEM と同じ規準にする（判定がぶれないため） */
const VERIFY_SYSTEM = `あなたは日本の大学受験世界史の事実確認を行う校閲者です。
与えられた主張のひとつひとつについて、史実として正しいかを判定してください。

# 判定
- ok           … 史実として正しい
- wrong        … 史実と食い違う。年号のずれ・主体の取り違え・因果の逆転を含む
- unverifiable … 判定に必要な情報が主張の中に無い、または学説が分かれている

# 守ること
1. 確信が持てないものを ok にしない。迷ったら unverifiable にする
2. wrong と判定したら、何がどう違うのかを reason に1文で書く
3. 教材の文体や表現の good/bad は判定しない。事実の正誤だけを見る
4. 入力の主張に含まれない前提を補って正しさを作らない`

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

    async verify(claims: Claim[], maxOutputTokens: number): Promise<VerifyResult> {
      if (claims.length === 0) {
        return { verdicts: [], usage: { inputTokens: 0, outputTokens: 0 }, model: o.model }
      }

      const list = claims.map((c, i) => `${i}. [${c.type}] ${c.text}`).join('\n')

      const res = await call(`/models/${o.model}:generateContent`, {
        systemInstruction: { parts: [{ text: VERIFY_SYSTEM }] },
        contents: [{ role: 'user', parts: [{ text: `次の主張を1件ずつ判定してください。\n\n${list}` }] }],
        generationConfig: {
          responseMimeType: 'application/json',
          responseSchema: toGeminiSchema(verdictJsonSchema()),
          maxOutputTokens,
          // ★ 事実の判定なので揺らさない。生成（0.4）より低くする
          temperature: 0,
        },
      })

      const json = (await res.json()) as GeminiResponse
      // ★ 安全側の判定で止められたものを「問題なし」として通さない。
      //   検証できなかったのであって、正しいと分かったのではない
      if (json.promptFeedback?.blockReason) {
        throw new GeminiVerifyFailedError(`検証モデルが応答を拒否しました: ${json.promptFeedback.blockReason}`)
      }
      const finish = json.candidates?.[0]?.finishReason
      if (finish && finish !== 'STOP') {
        // ★ MAX_TOKENS のとき、原因は「判定が長すぎた」とは限らない。
        //   3.x Pro は思考トークンをこの予算から使うので、判定を書き始める前に
        //   使い切ることがある（2026-09-04 に実際に踏んだ）。次に読む人が
        //   claims の件数を疑って時間を溶かさないよう、ここに書いておく
        const hint = finish === 'MAX_TOKENS'
          ? '（maxOutputTokens が足りません。思考トークンもこの予算から使われます）'
          : ''
        throw new GeminiVerifyFailedError(`finishReason=${finish}${hint}`)
      }

      const text = json.candidates?.[0]?.content?.parts?.map(p => p.text ?? '').join('') ?? ''
      let parsed: unknown
      try {
        parsed = JSON.parse(text)
      } catch {
        throw new GeminiVerifyFailedError('判定を JSON として読めません')
      }
      const check = VerdictOutput.safeParse(parsed)
      if (!check.success) throw new GeminiVerifyFailedError('判定がスキーマに適合しません')

      // ★ 判定が返ってこなかった claim を「問題なし」として扱わない。
      //   検証されていないものは unverifiable であって ok ではない
      const byIndex = new Map(check.data.verdicts.map(v => [v.index, v]))
      const verdicts: Verdict[] = claims.map((claim, i) => {
        const v = byIndex.get(i)
        if (!v) return { claim, status: 'unverifiable', reason: '検証モデルが判定を返しませんでした' }
        return { claim, status: v.status, ...(v.reason ? { reason: v.reason } : {}) }
      })

      const usage: Usage = {
        inputTokens: json.usageMetadata?.promptTokenCount ?? 0,
        outputTokens: json.usageMetadata?.candidatesTokenCount ?? 0,
      }
      return { verdicts, usage, model: o.model }
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
