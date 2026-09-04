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
  /**
   * ★ 下限が要る。空配列を許すと層2・層3 が素通りし、
   *   未検証の教材が ready として配信される（v1 で実際にそうなっていた）。
   *   プロンプトは 12〜24件を求める。下限はそれより緩くして、
   *   数件足りないだけで無料枠のリクエストを捨てないようにする。
   */
  claims: z.array(GeneratedClaim).min(6).max(40),
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

/**
 * Anthropic の構造化出力（`output_config.format.schema`）が受け付ける形に直す。
 *
 * ★ **公式ドキュメントに一覧がある。** SDK の `OutputConfig.format` の JSDoc が
 *   指している https://platform.claude.com/docs/en/build-with-claude/structured-outputs
 *   に、通るものと通らないものが明記されている。**推測しない。**
 *
 *   通らないと書かれているもの:
 *     - 数値の制約         minimum / maximum / multipleOf
 *     - 文字列の制約       minLength / maxLength
 *     - 配列の制約         minItems の 0・1 以外を含め、minItems 以外すべて（maxItems も）
 *     - additionalProperties が false 以外
 *     - 再帰スキーマ、enum の中の複合型、外部 $ref
 *
 *   通ると書かれているもの: 基本型 / enum / const / anyOf・allOf / $ref・$defs /
 *   default / required / additionalProperties: false / 文字列の format /
 *   minItems（0 か 1 のみ）
 *
 * ★ **2回、往復で潰そうとして失敗した**（2026-09-04）。API は 400 を1件ずつしか
 *   返さないので、「名指しされていない＝通っている」は成り立たない。実際
 *   `minItems` を直したら次は `maxItems` が出た（req_011CeiPWeKkAjSeaPDzHB2z9 →
 *   req_011CeiQ1eGqAYF6NH2DywA8Y）。**一覧が読める場所を先に探すこと。**
 *
 * ★ **落としても正しさは失われない。** 件数・長さ・範囲の契約は応答を
 *   `MaterialOutput`（zod）で検証するときに効く。スキーマは「守らせるための助言」
 *   であって保証ではない、という `toGeminiSchema` と同じ立場である。
 *
 * ★ **`minItems` は 0 ではなく 1 に丸める。**「空配列は認めない」は通る範囲で残す。
 *   0 にすると空の教材が API 側の検査を素通りする。
 */
const ANTHROPIC_UNSUPPORTED = new Set([
  'minimum', 'maximum', 'multipleOf',   // 数値の制約
  'minLength', 'maxLength',             // 文字列の制約
  'maxItems',                           // 配列の制約（minItems だけが例外）
])

export function toAnthropicSchema(schema: unknown): unknown {
  if (Array.isArray(schema)) return schema.map(toAnthropicSchema)
  if (schema === null || typeof schema !== 'object') return schema

  const out: Record<string, unknown> = {}
  for (const [k, v] of Object.entries(schema as Record<string, unknown>)) {
    if (ANTHROPIC_UNSUPPORTED.has(k)) continue
    if (k === 'minItems' && typeof v === 'number' && v > 1) {
      out[k] = 1
      continue
    }
    out[k] = toAnthropicSchema(v)
  }
  return out
}

/**
 * 応答を `MaterialOutput` に通す。**上限を超えた配列は切り詰めてから検査する。**
 *
 * ★ なぜ要るか（2026-09-04）。Anthropic の構造化出力は `maxItems` を受け付けないので
 *   送っていない（`toAnthropicSchema`）。`wh.4.1.3` の1本では件数がすべて指示どおりに
 *   収まったので「プロンプトの指示だけで守られる」と結論したが、**n=1 からの一般化**
 *   だった。`gh.2.1.1` はフラッシュカードを15枚出し、
 *   `flashcards: Too big: expected array to have <=14 items` で丸ごと落ちた。
 *
 * ★ 切り詰めるのは**上限のある配列だけ**。「14枚以内」と頼んで15枚返ったなら、
 *   先頭14枚を採るのが元の意図そのものである。余りを捨てても中身は損なわれない。
 *
 * ★ **`sections` と `choices` は切り詰めない。** どちらも「ちょうど7」「ちょうど4」で、
 *   多い場合は構造の誤りである。とくに `choices` を削ると `answer_key` が
 *   消えた選択肢を指しうる — **正解の無い設問**ができる。数が合わないなら落とす。
 *
 * ★ 下限は救えない。10枚と頼んで8枚しか返らなければ作り直すしかない。
 *   ここで水増しすると、検証していない中身が混ざる。
 */
const MAX_ITEMS = { flashcards: 14, mcqs: 10, claims: 40 } as const

export function parseMaterialOutput(raw: unknown): ReturnType<typeof MaterialOutput.safeParse> {
  if (raw !== null && typeof raw === 'object' && !Array.isArray(raw)) {
    const o = { ...(raw as Record<string, unknown>) }
    for (const [key, max] of Object.entries(MAX_ITEMS)) {
      const v = o[key]
      if (Array.isArray(v) && v.length > max) o[key] = v.slice(0, max)
    }
    return MaterialOutput.safeParse(o)
  }
  return MaterialOutput.safeParse(raw)
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
