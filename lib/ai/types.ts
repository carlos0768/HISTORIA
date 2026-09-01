/**
 * AI プロバイダの型
 *
 * 仕様: docs/08-ai-architecture.md §4.2・§6
 */

/** 習得度は数値ではなく3段階に丸めて送る（§4.1） */
export type MasteryBand = 'low' | 'mid' | 'high'

/**
 * 生成プロンプトに渡してよい文脈。
 *
 * ★ この型に user_id / display_name / email / birth_date を **絶対に足さない**。
 *   無料枠に送ったデータは Google の製品改善に使われ、人間のレビュアーが見る
 *   （§4）。型で防ぐのが唯一の確実な手段である。
 */
export type AnonymizedContext = {
  /** 公開されている教科書の章立て */
  unitId: string
  unitLabel: string
  /** 本アプリが定義した公開語彙 */
  weakKcs: Array<{
    kcId: string
    label: string
    kind: string
    band: MasteryBand
    /** 反復して選ばれた誤選択肢のラベル。歴史用語であって個人情報ではない */
    confusedWith?: string[]
  }>
  targetCharCount: number
}

export type GenerateArgs<T> = {
  context: AnonymizedContext
  schema: object
  /**
   * ★ 省略できない。支出遮断器の見積りは「入力＋maxOutputTokens」を上限として
   *   計算するため、未指定だと上限が定義できず不変条件が崩れる（§7.1）。
   */
  maxOutputTokens: number
  promptVersion: string
}

/** 教材が主張している検証可能な事実（§5 層1） */
export type Claim = {
  type: 'year' | 'person' | 'place' | 'causal' | 'order'
  text: string
  /** 本文中の該当箇所 */
  sectionOrd?: number
}

export type Verdict = {
  claim: Claim
  status: 'ok' | 'wrong' | 'unverifiable'
  reason?: string
}

export type Usage = { inputTokens: number; outputTokens: number }

export type GenerateResult<T> = { value: T; usage: Usage; model: string }
export type VerifyResult = { verdicts: Verdict[]; usage: Usage; model: string }

export type Provider = {
  name: string
  generate<T>(args: GenerateArgs<T>): Promise<GenerateResult<T>>
  verify(claims: Claim[], maxOutputTokens: number): Promise<VerifyResult>
  embed(texts: string[]): Promise<{ vectors: number[][]; usage: Usage; model: string }>
}
