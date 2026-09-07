/**
 * 教材本文（body_md）の記法のうち、HISTORIA が足したもの
 *
 * 生成物の body_md は「小見出し・段落・箇条書き・**強調**」しか使わない
 * （prompts/material_v2.md）。ここに **重要箇所のマーク** `==語句==` を足す。
 * 画面では朱（`--lv-accent-ink`）の文字になる（components/markdown.tsx、docs/11 §4）。
 *
 * ★ マークは本文ではなく**注記**である。したがって字数に数えない。
 *   数えると、字数の上限いっぱいで書かれた節（実際に §1・§6 に余裕0の節がある）に
 *   マークを1つ付けただけで docs/07 §2 の契約を破ることになる。
 *   `**` は生成の契約に含まれる記法で、これまでの字数も含めて数えてきたので変えない。
 *
 * ★ 記法の解釈はここと components/markdown.tsx の2箇所だけに持つ。
 *   検索の抜き書き（lib/loop/research.ts）も字数の検査（scripts/db/check-material.ts）も
 *   ここを通す。3箇所目を作らない。
 */

/** `==語句==`。空・改行またぎ・`=` の入れ子は解釈しない（そのまま文字として出る） */
export const IMPORTANT_RE = /==([^=\n]+)==/g

/** マークの記号だけを落とす。中の語句は残る */
export function stripImportant(md: string): string {
  return md.replace(IMPORTANT_RE, '$1')
}

/** 読者に見える本文の字数（マークの記号を除く）。docs/07 §2 の字数はこれで測る */
export function bodyTextLength(md: string): number {
  return stripImportant(md).length
}

/**
 * マークの付け方の誤りを列挙する。空なら問題なし。
 *
 * ★ 解釈できない `==` は画面にそのまま出る（黙って消さない）ので、
 *   投入前にここで落とす。受験生の画面に `==` が残るのは事故である。
 */
export function importantMarkProblems(md: string): string[] {
  const problems: string[] = []
  const rest = stripImportant(md)
  if (rest.includes('==')) problems.push('閉じていない、または空・改行またぎの == がある')
  if (/===/.test(md)) problems.push('=== がある（マークが隣接している）')
  for (const m of md.matchAll(IMPORTANT_RE)) {
    const inner = m[1]!
    const boldInside = (inner.match(/\*\*/g) ?? []).length
    const boldBefore = (md.slice(0, m.index).match(/\*\*/g) ?? []).length
    if (boldInside % 2 === 1 || boldBefore % 2 === 1) {
      problems.push(`「${inner.slice(0, 20)}」が **強調** と交差している`)
    }
  }
  return problems
}
