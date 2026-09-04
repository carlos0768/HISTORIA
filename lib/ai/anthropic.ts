/**
 * Anthropic プロバイダ（生成・検証）
 *
 * 仕様: docs/08-ai-architecture.md §2・§5 層3
 *
 * ★ 生成と検証の**両方**を実装する。どちらに使うかは設定で決まる。
 *   2026-09-04 に向きが「生成 Claude / 検証 Gemini」へ入れ替わった（§2 の注記）。
 *   それまでここは検証専用で、generate() は必ず例外を投げていた。
 *
 * ★ 「自己検証への退化」を防ぐのはこのファイルの仕事ではない。
 *   両方を実装しても危なくないのは、`client.ts` の `assertConfig` が
 *   生成と検証を別プロバイダに強制するからである。**片方のプロバイダを
 *   不能にして防ぐと、向きを変えた瞬間に製品が動かなくなる**（実際になった）。
 */
import Anthropic from '@anthropic-ai/sdk'
import type { Provider, GenerateArgs, GenerateResult, VerifyResult, Claim, Verdict, Usage } from './types'
import { parseMaterialOutput, VerdictOutput, verdictJsonSchema, toAnthropicSchema } from './schema'

export type AnthropicOptions = {
  apiKey: string
  model: string
  /** テストで差し替える。既定は SDK の実クライアント */
  client?: Anthropic
}

export class GenerateFailedError extends Error {
  constructor(readonly detail: string) {
    super(`生成に失敗しました: ${detail}`)
    this.name = 'GenerateFailedError'
  }
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

    async generate<T>(args: GenerateArgs): Promise<GenerateResult<T>> {
      let msg: Anthropic.Message
      try {
        /**
         * ★ ストリームで受ける。教材の max_tokens は 16,000
         *   （`MATERIAL_MAX_OUTPUT_TOKENS`）で、非ストリームの1リクエストに
         *   かかる時間の上限に当たりうる。`finalMessage()` は組み上がった
         *   Message を返すので、以降の扱いは `create` と変わらない。
         *
         * ★ temperature を送らない。adaptive thinking と併用すると 400 になる。
         *   Gemini 側は 0.4 を送っているが、それはあちらの制約が違うためである。
         */
        msg = await client.messages
          .stream({
            model: o.model,
            // ★ 省略しない。遮断器の見積りの上限を定義する値である（docs/08 §7.1）
            max_tokens: args.maxOutputTokens,
            system: args.prompt.system,
            output_config: {
              // ★ そのまま送らない。配列の minItems は 0/1 しか通らない（schema.ts の注記）。
              //   教材スキーマは全ての配列が引っかかるので、変換しないと 400 で必ず落ちる
              format: {
                type: 'json_schema',
                schema: toAnthropicSchema(args.schema) as Record<string, unknown>,
              },
            },
            // budget_tokens は Opus 5 では 400 になる。adaptive のみ
            thinking: { type: 'adaptive' },
            messages: [{ role: 'user', content: args.prompt.user }],
          })
          .finalMessage()
      } catch (e) {
        // 型付き例外を具体的な順に見る。文字列マッチはしない
        if (e instanceof Anthropic.RateLimitError) throw new GenerateFailedError('レート制限')
        if (e instanceof Anthropic.AuthenticationError) throw new GenerateFailedError('鍵が不正です')
        if (e instanceof Anthropic.BadRequestError) throw new GenerateFailedError(`リクエストが不正: ${e.message}`)
        if (e instanceof Anthropic.APIError) throw new GenerateFailedError(`API エラー ${e.status}: ${e.message}`)
        throw e
      }

      if (msg.stop_reason === 'refusal') {
        throw new GenerateFailedError(`生成モデルが応答を拒否しました（${msg.stop_details?.category ?? '理由不明'}）`)
      }
      if (msg.stop_reason === 'max_tokens') {
        // 途中で切れた JSON をパースしても壊れているだけなので、ここで落とす
        throw new GenerateFailedError('出力が上限で切れました')
      }

      // thinking ブロックが混ざるので text だけを取る
      const text = msg.content
        .filter((b): b is Anthropic.TextBlock => b.type === 'text')
        .map(b => b.text)
        .join('')
      if (!text) throw new GenerateFailedError('本文が空です')

      let parsed: unknown
      try {
        parsed = JSON.parse(text)
      } catch {
        throw new GenerateFailedError('JSON として読めません')
      }

      // ★ モデルがスキーマを守る保証はどのプロバイダにも無い。必ずこちらで検証する
      // ★ 上限を超えた配列は切り詰めてから検査する（schema.ts の注記）
      const check = parseMaterialOutput(parsed)
      if (!check.success) {
        throw new GenerateFailedError(
          check.error.issues.slice(0, 5).map(i => `${i.path.join('.')}: ${i.message}`).join(' / '),
        )
      }

      const usage: Usage = {
        inputTokens: msg.usage.input_tokens,
        outputTokens: msg.usage.output_tokens,
      }
      return { value: check.data as unknown as T, usage, model: o.model }
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
          // 判定は構造化出力で受ける。プレフィルは Sonnet 5 では使えない。
          // 生成側と同じ変換を通す（いまの VerdictOutput に minItems は無いが、
          // 増やしたときに片方だけ落ちる、を防ぐ）
          output_config: {
            format: {
              type: 'json_schema',
              schema: toAnthropicSchema(verdictJsonSchema()) as Record<string, unknown>,
            },
          },
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
