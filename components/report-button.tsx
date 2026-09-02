'use client'

import { useState, useTransition } from 'react'
import { COMMENT_MAX, type ReportTarget } from '@/lib/loop/report'

/**
 * 「この記述はおかしい」導線（docs/08-ai-architecture.md §5 層4）
 *
 * ★ 毎回生成なので人手レビューができない。層2（機械照合）と層3（AI の事実確認）を
 *   抜けた誤りを拾える最後の網が、読んでいる本人の違和感である。
 *   だから**押しやすさが唯一の設計要件**になる。
 *
 * ★ 理由は任意にする。必須にすると押されない。「なんか変」しか言えない
 *   段階の違和感を捨てないほうが、網として広い。
 * ★ 押しても本文はその場で消えない。誤報1件で正しい教材が消えると
 *   いたずらで壊せるので、伏せるのは作者が確認したあとである（そう画面にも書く）。
 * ★ 目立たせない。朱は主要ボタンの色なので使わず、字だけの控えめな導線にする。
 *   本文を読む邪魔をしてまで出すものではない。
 */
export function ReportButton({
  targetKind, targetId, action,
}: {
  targetKind: ReportTarget
  targetId: string
  action: (input: { targetKind: ReportTarget; targetId: string; comment: string | null })
    => Promise<{ duplicate: boolean }>
}) {
  const [open, setOpen] = useState(false)
  const [done, setDone] = useState(false)
  const [comment, setComment] = useState('')
  const [error, setError] = useState<string | null>(null)
  const [pending, startTransition] = useTransition()

  if (done) {
    return (
      <p className="lv-caption hs-report__done">
        受け付けました。作者が確認します。確認されるまで表示は変わりません。
      </p>
    )
  }

  const send = () => {
    setError(null)
    startTransition(async () => {
      try {
        await action({ targetKind, targetId, comment: comment.trim() || null })
        setDone(true)
      } catch (e) {
        setError(e instanceof Error ? e.message : '送れませんでした')
      }
    })
  }

  if (!open) {
    return (
      <button type="button" className="hs-report__open" onClick={() => setOpen(true)}>
        この記述はおかしい
      </button>
    )
  }

  return (
    <div className="hs-report">
      <label className="lv-caption" htmlFor={`report-${targetId}`}>
        どこが気になりましたか（書かなくても送れます）
      </label>
      <textarea
        id={`report-${targetId}`}
        className="hs-report__text"
        rows={2}
        maxLength={COMMENT_MAX}
        value={comment}
        onChange={e => setComment(e.target.value)}
        placeholder="例: 年号が1つずれている気がする"
      />
      {error && <p className="lv-field-note">{error}</p>}
      <div className="hs-report__row">
        <button type="button" className="lv-btn" disabled={pending} onClick={() => setOpen(false)}>
          やめる
        </button>
        <button type="button" className="lv-btn lv-btn--primary" disabled={pending} onClick={send}>
          {pending ? '送っています…' : '報告する'}
        </button>
      </div>
    </div>
  )
}
