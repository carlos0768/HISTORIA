/**
 * 鍵が無い間に閉ループを最後まで通すためのフェイクプロバイダ
 *
 * 実物と同じ型・同じ制約で動く。違うのは中身を作る方法だけである。
 * これがあることで、GEMINI_API_KEY / ANTHROPIC_API_KEY が無くても
 * 「生成 → 検証 → 出題 → 採点 → 弱点更新」の通しを実行して確認できる。
 */
import type { Provider, GenerateArgs, GenerateResult, VerifyResult, Claim } from './types'

/** 決定的な擬似乱数。Math.random を使わない（同じ入力で同じ出力にする） */
function hash(s: string): number {
  let h = 2166136261
  for (let i = 0; i < s.length; i++) { h ^= s.charCodeAt(i); h = Math.imul(h, 16777619) }
  return h >>> 0
}

export type FakeOptions = {
  /** 検証でこの割合の claim を wrong と判定する。層3の検出率の試験に使う */
  wrongRate?: number
  /** 生成を失敗させる（層5 の配信停止の経路を試す） */
  failGeneration?: boolean
}

export function createFakeProvider(name: string, opts: FakeOptions = {}): Provider {
  const wrongRate = opts.wrongRate ?? 0

  return {
    name,

    async generate<T>(args: GenerateArgs<T>): Promise<GenerateResult<T>> {
      if (opts.failGeneration) throw new Error('fake: 生成に失敗しました')
      const ctx = args.context
      const sections = ctx.weakKcs.slice(0, 5).map((kc, i) => ({
        ord: i + 1,
        heading: `${kc.label}`,
        body_md: `${kc.label}についての解説。`.repeat(
          Math.max(1, Math.floor(args.context.targetCharCount / 5 / 12)),
        ),
        kc_ids: [kc.kcId],
      }))
      const value = {
        title: `${ctx.unitLabel}`,
        sections,
        claims: ctx.weakKcs.slice(0, 3).map((kc, i) => ({
          type: (['year', 'person', 'causal'] as const)[i % 3],
          text: `${kc.label}に関する主張`,
          sectionOrd: 1,
        })),
        items: ctx.weakKcs.slice(0, 4).map((kc, i) => ({
          format: 'mcq4' as const,
          stem: `${kc.label}に関する設問`,
          choices: ['a', 'b', 'c', 'd'].map(k => ({ key: k, text: `選択肢${k}`, why_wrong: k === 'a' ? null : '誤り' })),
          answer_key: 'a',
          explanation: '解説',
          kc_ids: [kc.kcId],
        })),
      }
      const chars = sections.reduce((n, s) => n + s.body_md.length, 0)
      return {
        value: value as unknown as T,
        usage: { inputTokens: 600, outputTokens: Math.ceil(chars / 1.8) },
        model: `${name}-fake`,
      }
    },

    async verify(claims: Claim[]): Promise<VerifyResult> {
      const verdicts = claims.map((c, i) => {
        const isWrong = wrongRate > 0 && (hash(c.text + i) % 1000) / 1000 < wrongRate
        return isWrong
          ? { claim: c, status: 'wrong' as const, reason: 'fake: 年号が正典と一致しません' }
          : { claim: c, status: 'ok' as const }
      })
      return {
        verdicts,
        usage: { inputTokens: 1200, outputTokens: 400 },
        model: `${name}-fake`,
      }
    },

    async embed(texts: string[]) {
      // 768次元。決定的に作るので、同じ文字列は常に同じベクトルになる
      const vectors = texts.map(t => {
        const seed = hash(t)
        return Array.from({ length: 768 }, (_, i) => {
          const h = hash(`${seed}:${i}`)
          return (h / 0xffffffff) * 2 - 1
        })
      })
      return { vectors, usage: { inputTokens: texts.join('').length, outputTokens: 0 }, model: `${name}-fake-embed` }
    },
  }
}
