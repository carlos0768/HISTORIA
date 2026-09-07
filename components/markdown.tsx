/**
 * 教材本文の最小限の描画
 *
 * 生成物の body_md は「小見出し・段落・箇条書き・強調」しか使わない（prompts/material_v1.md）。
 * それに HISTORIA が足した「重要箇所のマーク」`==語句==` を加えたぶんだけを
 * React 要素として組み立てる（docs/07 §2.1、lib/domain/markup.ts）。
 *
 * ★ dangerouslySetInnerHTML を使わない。モデルの出力を HTML として解釈させない。
 *   解釈しなければ、注入されようがない（docs/12 §6）。
 * ★ 解釈できない記法はそのまま文字として出す。黙って消さない。
 */
import type { ReactNode } from 'react'

/**
 * **強調** と ==重要== だけを拾う。入れ子は考えない。
 * ★ `==` の中に改行や `=` は許さない。閉じ忘れを行の終わりまで赤くしないため
 */
const INLINE_RE = /(\*\*[^*]+\*\*|==[^=\n]+==)/g

function inline(text: string, keyPrefix: string): ReactNode[] {
  return text.split(INLINE_RE).filter(s => s !== '').map((part, i) => {
    const key = `${keyPrefix}-${i}`
    if (part.length > 4 && part.startsWith('**') && part.endsWith('**')) {
      return <strong key={key}>{part.slice(2, -2)}</strong>
    }
    if (part.length > 4 && part.startsWith('==') && part.endsWith('==')) {
      // 朱の文字。色は app/globals.css の .hs-important
      return <mark key={key} className="hs-important">{part.slice(2, -2)}</mark>
    }
    return <span key={key}>{part}</span>
  })
}

export function Markdown({ source }: { source: string }) {
  const blocks = source.split(/\n{2,}/).map(b => b.trim()).filter(b => b !== '')

  return (
    <div className="hs-prose">
      {blocks.map((block, i) => {
        const heading = /^(#{2,4})\s+(.*)$/.exec(block)
        if (heading) {
          return <p key={i} className="lv-label">{inline(heading[2]!, `h${i}`)}</p>
        }

        const lines = block.split('\n')
        if (lines.every(l => /^[-・*]\s+/.test(l))) {
          return (
            <ul key={i} className="hs-prose__list">
              {lines.map((l, j) => (
                <li key={j} className="lv-body">{inline(l.replace(/^[-・*]\s+/, ''), `l${i}-${j}`)}</li>
              ))}
            </ul>
          )
        }

        // 段落内の単独改行は原文の折り返しなので、そのまま行として出す
        return (
          <p key={i} className="lv-body">
            {lines.map((l, j) => (
              <span key={j}>
                {j > 0 && <br />}
                {inline(l, `p${i}-${j}`)}
              </span>
            ))}
          </p>
        )
      })}
    </div>
  )
}
