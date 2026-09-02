/**
 * 生成物のスキーマ
 *
 * 仕様: docs/07-content-pipeline.md §5.3
 *
 * ★ スキーマの定義はここ1箇所だけに持つ。
 *   API に渡す JSON Schema も、応答の検証も、TypeScript の型も、
 *   すべてこの zod スキーマから導出する。3箇所に書くと必ずずれる。
 *
 * ★ モデルがスキーマを守る保証はどのプロバイダにも無い。
 *   応答は必ずこちら側で検証してから使う（docs/13 の判定手順）。
 */
import { z } from 'zod'

export const CHOICE_KEYS = ['a', 'b', 'c', 'd'] as const

export const MaterialSection = z.object({
  ord: z.number().int().min(1).max(7),
  heading: z.string().min(1),
  body_md: z.string().min(1),
  kc_ids: z.array(z.string()),
})

export const Flashcard = z.object({
  front: z.string().min(1),
  // 答えは30字以内。自己採点できる長さに収める（docs/07 §5.2）
  back: z.string().min(1).max(30),
  kc_ids: z.array(z.string()).min(1),
})

export const Mcq = z.object({
  stem: z.string().min(1),
  choices: z
    .array(
      z.object({
        key: z.enum(CHOICE_KEYS),
        text: z.string().min(1),
        // 正答の場合は空文字。誤答にはなぜ誤りかを必ず書かせる（docs/07 §5.2）
        why_wrong: z.string(),
      }),
    )
    .length(4),
  answer_key: z.enum(CHOICE_KEYS),
  explanation: z.string().min(1),
  kc_ids: z.array(z.string()).min(1),
})

/** 本文中の検証可能な主張。ファクトチェックに使う（docs/08 §5 層1） */
export const GeneratedClaim = z.object({
  kind: z.enum(['year', 'person', 'event', 'causal', 'place']),
  text: z.string().min(1),
  subject: z.string().optional(),
  year_from: z.number().int().optional(),
  year_to: z.number().int().optional(),
  section_ord: z.number().int(),
})

export const MaterialOutput = z.object({
  title: z.string().min(1).max(60),
  sections: z.array(MaterialSection).length(7),
  flashcards: z.array(Flashcard).min(10).max(14),
  mcqs: z.array(Mcq).min(6).max(10),
  claims: z.array(GeneratedClaim),
})

export type MaterialOutput = z.infer<typeof MaterialOutput>
export type Mcq = z.infer<typeof Mcq>
export type Flashcard = z.infer<typeof Flashcard>
export type GeneratedClaim = z.infer<typeof GeneratedClaim>

/** 検証の判定。Anthropic に返させる（docs/08 §5 層3） */
export const VerdictOutput = z.object({
  verdicts: z.array(
    z.object({
      index: z.number().int(),
      status: z.enum(['ok', 'wrong', 'unverifiable']),
      reason: z.string().optional(),
    }),
  ),
})
export type VerdictOutput = z.infer<typeof VerdictOutput>

export const materialJsonSchema = (): object => z.toJSONSchema(MaterialOutput)
export const verdictJsonSchema = (): object => z.toJSONSchema(VerdictOutput)

/**
 * Gemini の responseSchema は OpenAPI 3.0 Schema の**部分集合**であり、
 * JSON Schema のキーワードをすべて受け付けるわけではない。
 * 公式ドキュメントが参照できない環境なので、**通ることが確認できていない
 * キーワードを落として**渡す。落としても、応答は zod で検証するので
 * 正しさは失われない（スキーマは「守らせるための助言」であって保証ではない）。
 *
 * 実際にどこまで通るかは M5 として鍵が入った時点で実測する。
 */
const GEMINI_SAFE_KEYS = new Set([
  'type', 'format', 'description', 'nullable', 'enum',
  'properties', 'required', 'items', 'propertyOrdering',
  'minItems', 'maxItems', 'minLength', 'maxLength',
  'minimum', 'maximum',
])

export function toGeminiSchema(schema: unknown): unknown {
  if (Array.isArray(schema)) return schema.map(toGeminiSchema)
  if (schema === null || typeof schema !== 'object') return schema

  const out: Record<string, unknown> = {}
  for (const [k, v] of Object.entries(schema as Record<string, unknown>)) {
    if (!GEMINI_SAFE_KEYS.has(k)) continue
    if (k === 'properties') {
      const props: Record<string, unknown> = {}
      for (const [pk, pv] of Object.entries(v as Record<string, unknown>)) props[pk] = toGeminiSchema(pv)
      out[k] = props
      // 生成の安定のため、プロパティの順序を明示する。
      // 順序が揺れるとモデルの出力品質が落ちることが報告されている
      out.propertyOrdering = Object.keys(props)
    } else if (k === 'items') {
      out[k] = toGeminiSchema(v)
    } else {
      out[k] = v
    }
  }
  return out
}

/** 教材本文の文字数。docs/07 §2 の目標 3,500字に対する実測用 */
export function bodyCharCount(m: MaterialOutput): number {
  return m.sections.reduce((n, s) => n + s.body_md.length, 0)
}

export const TARGET_CHARS = 3500

/**
 * 受け入れる文字数の範囲。
 *
 * ★ 「3,500字±15%」（2,975〜4,025）ではなく、docs/07 §5.2 が**プロンプトで指示している
 *   各節の字数の合計**（3,050〜4,500）を使う。
 *
 *   ±15% で弾くと、プロンプトの指示どおりに書いた教材（例: 各節を上限いっぱいで
 *   書いて 4,300字）を「範囲外」として捨てることになる。
 *   **自分が出した指示に従った出力を落とす判定を作らない。**
 *
 *   作者判断 Q2 の「3,500字±15%で確定」は目標値の話であり、目標は TARGET_CHARS が持つ。
 */
export const MIN_CHARS = 3050
export const MAX_CHARS = 4500

export function isCharCountOutOfRange(chars: number): boolean {
  return chars < MIN_CHARS || chars > MAX_CHARS
}
