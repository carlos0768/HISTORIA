'use client'

import { useState, useTransition } from 'react'
import { answerCheckTest, finishCheckTest } from '../actions'
import type { Choice } from '@/app/study/quiz'

export type TestItem = { id: string; stem: string; choices: Choice[] }

/**
 * 確認テストの出題（docs/11 §10 の画面9）
 *
 * ★ 1画面1問・中断不可。戻るボタンを置かない。
 *   前の問題に戻れると、後の問題文から前の答えを推測できてしまう。
 *
 * ★ 正誤をその場で出さない。理由は actions.ts の answerCheckTest に書いた。
 *   代わりに「あと何問か」を常に出す。終わりが見えないと投げ出す。
 */
export function CheckTest({ testId, items }: { testId: string; drillId: string; items: TestItem[] }) {
  const [i, setI] = useState(0)
  const [startedAt, setStartedAt] = useState(() => Date.now())
  const [chosen, setChosen] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [pending, startTransition] = useTransition()

  const item = items[i]
  if (!item) return null

  const answer = (key: string) => {
    if (pending) return
    setChosen(key)
    setError(null)
    startTransition(async () => {
      try {
        await answerCheckTest({ itemId: item.id, chosen: key, latencyMs: Date.now() - startedAt })
      } catch (e) {
        setChosen(null)
        setError(e instanceof Error ? e.message : '記録できませんでした')
        return
      }
      if (i + 1 < items.length) {
        setI(i + 1)
        setChosen(null)
        setStartedAt(Date.now())
      } else {
        // 最後の1問。採点して結果画面へ（redirect が投げられる）
        await finishCheckTest(testId)
      }
    })
  }

  return (
    <div className="hs-stack">
      <div className="hs-titlerow">
        <span className="lv-label">確認テスト</span>
        <span className="lv-caption">{i + 1} / {items.length} 問</span>
      </div>

      <div className="lv-card">
        <div className="lv-card__pad hs-stack">
          <p className="lv-body">{item.stem}</p>
          <div className="hs-stack">
            {item.choices.map(c => (
              <button
                key={c.key}
                type="button"
                className={`lv-btn lv-btn--block${chosen === c.key ? ' lv-btn--primary' : ''}`}
                onClick={() => answer(c.key)}
                disabled={pending}
              >
                {c.text}
              </button>
            ))}
          </div>
        </div>
      </div>

      {error && <p className="lv-field-note" role="alert">{error}</p>}

      <p className="lv-caption">
        途中でやめても、この問題のまま残ります。結果は最後まで解いたときに出ます。
      </p>
    </div>
  )
}
