/**
 * Anthropic プロバイダ（検証）
 *
 * 仕様: docs/08-ai-architecture.md §2・§5 層3
 *
 * ★ 生成ではなく検証に使う。生成と別系統にすることが目的なので、
 *   ここで生成もできるようにすると自己検証への退化を招く（§2.1）。
 */
import Anthropic from '@anthropic-ai/sdk'
import type { Provider, GenerateResult, VerifyResult, Claim, Verdict, Usage } from './types'
import { VerdictOutput, verdictJsonSchema } from './schema'

export type AnthropicOptions = {
  apiKey: string
  model: string
  /** テストで差し替える。既定は SDK の実クライアント */
  client?: Anthropic
}

export class VerifyFailedError extends Error {
  constructor(readonly detail: string) {
    super(`検証に失敗しました: ${detail}`)
    this.name = 'VerifyFailedError'
  }
}

const SYSTEM = `あなたは日本の大学受験世界史の事実確認を行う校閲者です。
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

export function createAnthropicProvider(o: AnthropicOptions): Provider {
  // SDK の自動リトライは切る。レート制御は docs/08 §7 で一元管理する
  const client = o.client ?? new Anthropic({ apiKey: o.apiKey, maxRetries: 0 })

  return {
    name: 'anthropic',

    async generate<T>(): Promise<GenerateResult<T>> {
      throw new Error('anthropic は生成に使わない設定です（docs/08 §2.1）')
    },

    async verify(claims: Claim[], maxOutputTokens: number): Promise<VerifyResult> {
      if (claims.length === 0) {
        return { verdicts: [], usage: { inputTokens: 0, outputTokens: 0 }, model: o.model }
      }

      const list = claims.map((c, i) => `${i}. [${c.type}] ${c.text}`).join('\n')

      let msg
      try {
        msg = await client.messages.create({
          model: o.model,
          max_tokens: maxOutputTokens,
          system: SYSTEM,
          // 判定は構造化出力で受ける。プレフィルは Sonnet 5 では使えない
          output_config: { format: { type: 'json_schema', schema: verdictJsonSchema() as Record<string, unknown> } },
          // budget_tokens は Sonnet 5 では 400 になる。adaptive のみ
          thinking: { type: 'adaptive' },
          messages: [{ role: 'user', content: `次の主張を1件ずつ判定してください。\n\n${list}` }],
        })
      } catch (e) {
        // 型付き例外を具体的な順に見る。文字列マッチはしない
        if (e instanceof Anthropic.RateLimitError) throw new VerifyFailedError('レート制限')
        if (e instanceof Anthropic.AuthenticationError) throw new VerifyFailedError('鍵が不正です')
        if (e instanceof Anthropic.BadRequestError) throw new VerifyFailedError(`リクエストが不正: ${e.message}`)
        if (e instanceof Anthropic.APIError) throw new VerifyFailedError(`API エラー ${e.status}: ${e.message}`)
        throw e
      }

      // 安全側の判定で止められた場合、検証結果が無いまま通してはいけない
      if (msg.stop_reason === 'refusal') {
        throw new VerifyFailedError(`検証モデルが応答を拒否しました（${msg.stop_details?.category ?? '理由不明'}）`)
      }
      if (msg.stop_reason === 'max_tokens') {
        throw new VerifyFailedError('検証の出力が上限で切れました')
      }

      const text = msg.content
        .filter((b): b is Anthropic.TextBlock => b.type === 'text')
        .map(b => b.text)
        .join('')

      let parsed: unknown
      try {
        parsed = JSON.parse(text)
      } catch {
        throw new VerifyFailedError('判定を JSON として読めません')
      }
      const check = VerdictOutput.safeParse(parsed)
      if (!check.success) throw new VerifyFailedError('判定がスキーマに適合しません')

      // ★ 判定が返ってこなかった claim を「問題なし」として扱わない。
      //   検証されていないものは unverifiable であって ok ではない
      const byIndex = new Map(check.data.verdicts.map(v => [v.index, v]))
      const verdicts: Verdict[] = claims.map((claim, i) => {
        const v = byIndex.get(i)
        if (!v) return { claim, status: 'unverifiable', reason: '検証モデルが判定を返しませんでした' }
        return { claim, status: v.status, ...(v.reason ? { reason: v.reason } : {}) }
      })

      const usage: Usage = {
        inputTokens: msg.usage.input_tokens,
        outputTokens: msg.usage.output_tokens,
      }
      return { verdicts, usage, model: o.model }
    },

    async embed(): Promise<{ vectors: number[][]; usage: Usage; model: string }> {
      // Anthropic に埋め込み API は無い（docs/09 §6）
      throw new Error('anthropic に埋め込み API はありません。生成側（Gemini）を使ってください')
    },
  }
}
