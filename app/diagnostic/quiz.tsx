'use client'

import { useState, useTransition } from 'react'
import {
  answerDiagnosticAction, nextDiagnosticAction, finishDiagnosticAction,
  type NextQuestion,
} from './actions'

/**
 * 診断テストの出題（docs/04-weakness-engine.md §5・docs/11-ux.md §10）
 *
 * ★ 1画面1問。戻れない。前に戻れると、後の問題文から前の答えを推測できてしまう。
 *
 * ★ **正誤をその場で出さない。** 診断は測定であって練習ではない。
 *   途中で「連続で間違えている」と分かると、そこで閉じる人が出る。
 *
 * ★ 「わからない」を置く（docs/11 §10）。当てずっぽうで正解されると
 *   実力を過大評価する。当てずっぽうの下限 g はそれを見込んだ値だが、
 *   本人が「わからない」と言えるならそのほうが正確である。
 *
 * ★ 進捗を必ず出す。終わりが見えない測定は投げ出される。
 */
export function DiagnosticQuiz({ first }: { first: NextQuestion }) {
  const [q, setQ] = useState<NextQuestion>(first)
  const [chosen, setChosen] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [startedAt, setStartedAt] = useState(() => Date.now())
  const [pending, start] = useTransition()

  const send = (choice: string | null) => {
    if (pending) return
    setChosen(choice ?? '__unknown__')
    setError(null)
    start(async () => {
      try {
        const r = await answerDiagnosticAction({
          itemId: q.itemId,
          // ★ 「わからない」は null で送る。どの選択肢とも一致しないので不正解になる。
          //   誤答の選択肢として記録されないぶん、誤概念の材料にもならない
          chosen: choice,
          latencyMs: Date.now() - startedAt,
        })
        if (r.done) { await finishDiagnosticAction(); return }
        const next = await nextDiagnosticAction()
        if (!next) { await finishDiagnosticAction(); return }
        setQ(next)
        setChosen(null)
        setStartedAt(Date.now())
      } catch (e) {
        setChosen(null)
        setError(e instanceof Error ? e.message : '記録できませんでした')
      }
    })
  }

  return (
    <>
      <div className="hs-titlerow">
        <span className="lv-label">{q.index} / {q.total} 問目</span>
        <span className="lv-caption">正誤はまとめて最後に出ます</span>
      </div>

      <div className="lv-card">
        <div className="lv-card__pad hs-stack">
          <p className="lv-body">{q.stem}</p>
          {q.choices.map(c => (
            <button
              key={c.key} type="button"
              className={`lv-btn lv-btn--block${chosen === c.key ? ' lv-btn--primary' : ''}`}
              disabled={pending} onClick={() => send(c.key)}
            >
              {c.text}
            </button>
          ))}
        </div>
      </div>

      <button
        type="button" className="lv-btn lv-btn--block"
        disabled={pending} onClick={() => send(null)}
      >
        わからない
      </button>
      <p className="lv-caption">
        当てずっぽうより正確に測れます。ここで押しても不利にはなりません。
      </p>
      {error && <p className="lv-field-note" role="status">{error}</p>}
    </>
  )
}
