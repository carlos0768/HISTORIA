'use client'

import { useState, useTransition } from 'react'
import Link from 'next/link'
import type { DrillCard } from '@/lib/loop/drill-study'
import { answerRecall } from '../actions'

type Result = { correct: boolean; answer: string }

export function RecallQuiz({ cards, drillId }: { cards: DrillCard[]; drillId: string }) {
  const [index, setIndex] = useState(0)
  const [startedAt, setStartedAt] = useState(() => Date.now())
  const [answer, setAnswer] = useState('')
  const [result, setResult] = useState<Result | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [pending, startTransition] = useTransition()
  const card = cards[index]

  if (!card) {
    return (
      <div className="hs-empty">
        <p className="lv-title">一問一答は終わりです</p>
        <Link className="lv-btn" href={`/drills/${drillId}`}>勉強方法を選ぶ</Link>
      </div>
    )
  }

  const submit = () => {
    if (pending || result) return
    setError(null)
    startTransition(async () => {
      try {
        const judged = await answerRecall({
          drillId,
          itemId: card.id,
          answer,
          latencyMs: Date.now() - startedAt,
        })
        setResult(judged)
      } catch (e) {
        setError(e instanceof Error ? e.message : '採点できませんでした')
      }
    })
  }

  const next = () => {
    setIndex(current => current + 1)
    setAnswer('')
    setResult(null)
    setError(null)
    setStartedAt(Date.now())
  }

  return (
    <div className="hs-study-session">
      <div className="hs-progress">
        <div className="hs-progress__bar">
          {cards.map((item, n) => (
            <span key={item.id} className={`hs-progress__seg${n < index ? ' hs-progress__seg--done' : ''}`} />
          ))}
        </div>
        <span className="hs-progress__label">{index + 1} / {cards.length}</span>
      </div>

      <div className="lv-card">
        <div className="lv-card__pad hs-study-session">
          <span className="lv-label">{card.kcLabel}</span>
          <p className="lv-heading">{card.front}</p>
          <form onSubmit={event => { event.preventDefault(); submit() }} className="hs-study-session">
            <input className="lv-input" value={answer} onChange={event => setAnswer(event.target.value)}
                   disabled={pending || !!result} maxLength={300} autoComplete="off"
                   aria-label="答え" placeholder="答えを入力" autoFocus />
            {!result && (
              <button type="submit" className="lv-btn lv-btn--primary lv-btn--block" disabled={pending || answer.trim() === ''}>
                {pending ? '答え合わせ中…' : '答え合わせ'}
              </button>
            )}
          </form>
          {error && <p className="lv-field-note">{error}</p>}
          {result && (
            <div className="hs-study-session" aria-live="polite">
              <p className="lv-heading">{result.correct ? '正解' : '不正解'}</p>
              <div className="hs-flashcard__answer">
                <span className="lv-label">答え</span>
                <p className="lv-title">{result.answer}</p>
              </div>
              <button type="button" className="lv-btn lv-btn--primary lv-btn--block" onClick={next}>
                {index + 1 < cards.length ? '次へ' : '終わる'}
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
