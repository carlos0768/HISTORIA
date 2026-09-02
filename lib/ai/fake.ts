/**
 * 鍵が無い間に閉ループを最後まで通すためのフェイクプロバイダ
 *
 * 実物と同じ型・同じ制約で動く。違うのは中身を作る方法だけである。
 * これがあることで、GEMINI_API_KEY / ANTHROPIC_API_KEY が無くても
 * 「生成 → 検証 → 出題 → 採点 → 弱点更新」の通しを実行して確認できる。
 */
import type { Provider, GenerateArgs, GenerateResult, VerifyResult, Claim, Usage } from './types'
import { MaterialOutput, TARGET_CHARS } from './schema'

/** 決定的な擬似乱数。Math.random を使わない（同じ入力で同じ出力にする） */
function hash(s: string): number {
  let h = 2166136261
  for (let i = 0; i < s.length; i++) {
    h ^= s.charCodeAt(i)
    h = Math.imul(h, 16777619)
  }
  return h >>> 0
}

export type FakeOptions = {
  /** 検証でこの割合の claim を wrong と判定する。層3の検出率の試験に使う */
  wrongRate?: number
  /** 生成を失敗させる（層5 の配信停止の経路を試す） */
  failGeneration?: boolean
  /** 本文の合計文字数。範囲外を意図的に作って再生成の経路を試す */
  charCount?: number
  /** 生成物に混ぜる誤った主張。層2・層3 の検出を試す */
  wrongClaims?: string[]
}

/** プロンプト本文に並んでいる候補KCの行を読み取る */
function kcsFromPrompt(user: string): Array<{ id: string; kind: string; label: string }> {
  return [...user.matchAll(/^- (kc\.[a-z0-9_.]+) \| ([a-z]+) \| ([^|]+) \|/gm)].map(m => ({
    id: m[1]!,
    kind: m[2]!,
    label: m[3]!.trim(),
  }))
}

export function createFakeProvider(name: string, opts: FakeOptions = {}): Provider {
  const wrongRate = opts.wrongRate ?? 0

  return {
    /**
     * ★ 名前に `fake:` を付ける。ここが「後から見て偽物と分かる」唯一の手掛かりになる。
     *
     *   以前は実物と同じ名前（'gemini'）を名乗っていたため、
     *   material.provider にも 'gemini' と記録され、**鍵を入れ忘れて作った
     *   でたらめな教材を、後から見分ける方法が無かった**。
     *   受験勉強でこれは最悪の失敗の仕方をする（嘘を覚えて気づかない）。
     */
    name: `fake:${name}`,

    async generate<T>(args: GenerateArgs): Promise<GenerateResult<T>> {
      if (opts.failGeneration) throw new Error('fake: 生成に失敗しました')

      const kcs = kcsFromPrompt(args.prompt.user)
      const kcIds = kcs.length > 0 ? kcs.map(k => k.id) : ['kc.fake.placeholder']
      const label = (i: number) => kcs[i % Math.max(1, kcs.length)]?.label ?? '項目'

      const total = opts.charCount ?? TARGET_CHARS
      const per = Math.max(1, Math.floor(total / 7))
      const sections = Array.from({ length: 7 }, (_, i) => {
        const want = i === 6 ? total - per * 6 : per
        return {
          ord: i + 1,
          heading: `§${i + 1} ${label(i)}`,
          body_md: 'あ'.repeat(Math.max(1, want)),
          kc_ids: [kcIds[i % kcIds.length]!],
        }
      })

      // 実物と同じ件数を出す。スキーマの下限（6件）を満たさないと
      // 自分の出力の検査で落ちる。フェイクも同じ契約で動かすためである
      const kinds = ['year', 'person', 'event', 'causal', 'place'] as const
      const claims = [
        ...(opts.wrongClaims ?? []).map((text, i) => ({
          kind: 'year' as const,
          text,
          section_ord: (i % 7) + 1,
        })),
        ...Array.from({ length: 12 }, (_, i) => ({
          kind: kinds[i % kinds.length]!,
          text: `${label(i)}に関する主張${i + 1}`,
          section_ord: (i % 7) + 1,
        })),
      ]

      const value: MaterialOutput = {
        title: `${label(0)}の単元`,
        sections,
        flashcards: Array.from({ length: 10 }, (_, i) => ({
          front: `${label(i)}とは何か`,
          back: `${label(i)}の答え`.slice(0, 30),
          kc_ids: [kcIds[i % kcIds.length]!],
        })),
        mcqs: Array.from({ length: 6 }, (_, i) => ({
          stem: `${label(i)}に関する設問`,
          choices: (['a', 'b', 'c', 'd'] as const).map(k => ({
            key: k,
            text: `選択肢${k}`,
            why_wrong: k === 'a' ? '' : '同時代の別の事象と取り違えています',
          })),
          answer_key: 'a' as const,
          explanation: '解説',
          kc_ids: [kcIds[i % kcIds.length]!],
        })),
        claims,
      }

      // フェイクも自分の出力を検証する。実物と同じ契約で動かすため
      const check = MaterialOutput.safeParse(value)
      if (!check.success) throw new Error(`fake: 自分の出力がスキーマに反しています: ${check.error.message}`)

      const chars = sections.reduce((n, s) => n + s.body_md.length, 0)
      return {
        value: value as unknown as T,
        usage: { inputTokens: 600, outputTokens: Math.ceil(chars / 1.8) },
        model: `${name}-fake`,
      }
    },

    async verify(claims: Claim[]): Promise<VerifyResult> {
      const verdicts = claims.map((c, i) => {
        const injected = (opts.wrongClaims ?? []).includes(c.text)
        const sampled = wrongRate > 0 && (hash(c.text + i) % 1000) / 1000 < wrongRate
        return injected || sampled
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
      const usage: Usage = { inputTokens: texts.join('').length, outputTokens: 0 }
      return { vectors, usage, model: `${name}-fake-embed` }
    },
  }
}
