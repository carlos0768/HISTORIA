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
 *
 * 人物・出来事のリンク（docs/11-ux.md §4.2）:
 * `terms` に渡された語（正典に当たった人物と出来事）を本文の中で見つけ、「調べる」への
 * リンクにする。どの語を渡すかはサーバー（lib/loop/terms.ts）が全語彙で決め、
 * ここは渡された語を同じ規則（lib/domain/term-link.ts）で切って <a> にするだけである。
 * ★ 1つの語は本文の中で**初出だけ**リンクにする。10回出る語を10回リンクにすると
 *   本文が線だらけになり、どこを押せばよいかがかえって分からなくなる。
 * ★ リンクは本文の意味を変えない。文字はそのまま、押せるようになるだけである。
 *   強調の中でも重要箇所（朱）の中でもリンクにする。字の色は CSS が継承するので、
 *   朱の語をリンクにしても朱のままである。
 */
import type { ReactNode } from 'react'
import Link from 'next/link'
import { createLinker, researchHref, type LinkedTerm, type Linker } from '@/lib/domain/term-link'

/**
 * **強調** と ==重要== だけを拾う。入れ子は考えない。
 * ★ `==` の中に改行や `=` は許さない。閉じ忘れを行の終わりまで赤くしないため
 */
const INLINE_RE = /(\*\*[^*]+\*\*|==[^=\n]+==)/g

const KIND_LABEL: Record<LinkedTerm['kind'], string> = { person: '人物', event: '出来事' }

/** 語をリンクにしつつ文字を出す。seen で初出だけに絞る */
function linked(text: string, linker: Linker | null, seen: Set<string>, keyPrefix: string): ReactNode[] {
  if (!linker) return [<span key={keyPrefix}>{text}</span>]
  return linker.segment(text, seen).map((s, i) =>
    s.term ? (
      <Link
        key={`${keyPrefix}-${i}`}
        className={`hs-term hs-term--${s.term.kind}`}
        href={researchHref(s.term.label)}
        title={`${KIND_LABEL[s.term.kind]}「${s.term.label}」を調べる`}
      >
        {s.text}
      </Link>
    ) : (
      <span key={`${keyPrefix}-${i}`}>{s.text}</span>
    ),
  )
}

function inline(text: string, linker: Linker | null, seen: Set<string>, keyPrefix: string): ReactNode[] {
  return text.split(INLINE_RE).filter(s => s !== '').map((part, i) => {
    const key = `${keyPrefix}-${i}`
    if (part.length > 4 && part.startsWith('**') && part.endsWith('**')) {
      return <strong key={key}>{linked(part.slice(2, -2), linker, seen, key)}</strong>
    }
    if (part.length > 4 && part.startsWith('==') && part.endsWith('==')) {
      // 朱の文字。色は app/globals.css の .hs-important
      return <mark key={key} className="hs-important">{linked(part.slice(2, -2), linker, seen, key)}</mark>
    }
    return <span key={key}>{linked(part, linker, seen, key)}</span>
  })
}

export function Markdown({ source, terms = [] }: {
  source: string
  /** この本文に出てくる人物・出来事。空なら本文はただの文字のまま */
  terms?: readonly LinkedTerm[]
}) {
  const blocks = source.split(/\n{2,}/).map(b => b.trim()).filter(b => b !== '')
  // 語彙は「この本文で見つかった語」だけなので、渡された語をそのまま label と aliases に使う。
  // 描画のたびに作り直すが、数件〜十数件なので費用は無い
  const linker = terms.length === 0 ? null
    : createLinker(terms.map(t => ({ kind: t.kind, label: t.label, aliases: [t.text] })))
  // 初出だけをリンクにするための記録。1回の描画（＝1つの本文）の中で共有する
  const seen = new Set<string>()

  return (
    <div className="hs-prose">
      {blocks.map((block, i) => {
        const heading = /^(#{2,4})\s+(.*)$/.exec(block)
        if (heading) {
          return <p key={i} className="lv-label">{inline(heading[2]!, linker, seen, `h${i}`)}</p>
        }

        const lines = block.split('\n')
        if (lines.every(l => /^[-・*]\s+/.test(l))) {
          return (
            <ul key={i} className="hs-prose__list">
              {lines.map((l, j) => (
                <li key={j} className="lv-body">{inline(l.replace(/^[-・*]\s+/, ''), linker, seen, `l${i}-${j}`)}</li>
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
                {inline(l, linker, seen, `p${i}-${j}`)}
              </span>
            ))}
          </p>
        )
      })}
    </div>
  )
}
