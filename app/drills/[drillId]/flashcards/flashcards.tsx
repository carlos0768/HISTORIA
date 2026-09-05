'use client'

import { useState, useTransition } from 'react'
import Link from 'next/link'
import type { DrillCard } from '@/lib/loop/drill-study'
import { rateFlashcard, revealFlashcard } from '../actions'

const RATINGS = [
  { value: 'unknown', label: 'わからない' },
  { value: 'vague', label: 'あいまい' },
  { value: 'known', label: 'わかった' },
  { value: 'easy', label: '余裕' },
] as const

export function Flashcards({ cards, drillId }: { cards: DrillCard[]; drillId: string }) {
  const [index, setIndex] = useState(0)
  const [answer, setAnswer] = useState<string | null>(null)
  const [revealedAt, setRevealedAt] = useState<number | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [pending, startTransition] = useTransition()
  const card = cards[index]

  if (!card) {
    return (
      <div className="hs-empty">
        <p className="lv-title">カードは終わりです</p>
        <Link className="lv-btn" href={`/drills/${drillId}`}>勉強方法を選ぶ</Link>
      </div>
    )
  }

  const reveal = () => {
    setError(null)
    startTransition(async () => {
      try {
        const result = await revealFlashcard({ drillId, itemId: card.id })
        setAnswer(result.answer)
        setRevealedAt(Date.now())
      } catch (e) {
        setError(e instanceof Error ? e.message : '答えを開けませんでした')
      }
    })
  }

  const rate = (rating: typeof RATINGS[number]['value']) => {
    if (revealedAt === null) return
    setError(null)
    startTransition(async () => {
      try {
        await rateFlashcard({
          drillId,
          itemId: card.id,
          rating,
          msSinceReveal: Date.now() - revealedAt,
        })
        setIndex(current => current + 1)
        setAnswer(null)
        setRevealedAt(null)
      } catch (e) {
        setError(e instanceof Error ? e.message : '記録できませんでした')
      }
    })
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
        <div className="lv-card__pad hs-flashcard">
          <span className="lv-label">{card.kcLabel}</span>
          <p className="lv-heading">{card.front}</p>
          {answer === null ? (
            <button type="button" className="lv-btn lv-btn--primary lv-btn--block" onClick={reveal} disabled={pending}>
              {pending ? '開いています…' : '答えを見る'}
            </button>
          ) : (
            <>
              <div className="hs-flashcard__answer" aria-live="polite">
                <span className="lv-label">答え</span>
                <p className="lv-title">{answer}</p>
              </div>
              <div className="hs-rating-grid" aria-label="覚え具合">
                {RATINGS.map(rating => (
                  <button key={rating.value} type="button" className="lv-btn" disabled={pending}
                          onClick={() => rate(rating.value)}>
                    {rating.label}
                  </button>
                ))}
              </div>
            </>
          )}
          {error && <p className="lv-field-note">{error}</p>}
        </div>
      </div>
    </div>
  )
}
