'use client'

import { useState, useTransition } from 'react'
import { blockedDetailAction, approveMaterialAction } from './actions'
import { MAX_NOTE_CHARS, type ApprovalTarget } from '@/lib/loop/approve'

/**
 * 配信できなかった教材と、それを作者の判断で配信可能にする操作
 * （docs/12 §7.1 の一覧 / docs/02 §5 の「作者が承認して初めて入る」）
 *
 * ★ **一覧だけ出して何もできない画面にしない。** 事実確認（層3）の指摘は
 *   誤りとは限らない。2026-09-04 の wh.4.1.3 がそれで、指摘は誤りとも
 *   正しいとも言い切れなかった。作り直すと同じ本文はもう手に入らず、
 *   1本あたり約50円が消える。読んで正しいと判断したなら、そのまま出せるべきである。
 *
 * ★ **読まずには押せないようにする。** 理由（human_edit_log に残る）が空の間は
 *   ボタンを押せない。docs/10 §8 が求めているのは「承認した」という事実ではなく、
 *   **なぜ機械の指摘を退けたのか**という痕跡である。
 */

export type BlockedRow = {
  id: string
  unitId: string
  reason: string | null
  createdAt: string
}

export function BlockedMaterials({ rows }: { rows: BlockedRow[] }) {
  const [open, setOpen] = useState<string | null>(null)
  const [detail, setDetail] = useState<Record<string, ApprovalTarget | null>>({})
  const [notes, setNotes] = useState<Record<string, string>>({})
  const [done, setDone] = useState<Record<string, string>>({})
  const [error, setError] = useState<Record<string, string>>({})
  const [pending, start] = useTransition()

  const read = (id: string) => {
    setOpen(o => (o === id ? null : id))
    if (detail[id] !== undefined) return
    start(async () => {
      try {
        const t = await blockedDetailAction(id)
        setDetail(d => ({ ...d, [id]: t }))
      } catch (e) {
        setError(x => ({ ...x, [id]: e instanceof Error ? e.message : '読めませんでした' }))
      }
    })
  }

  const approve = (id: string) => start(async () => {
    setError(x => ({ ...x, [id]: '' }))
    try {
      const r = await approveMaterialAction(id, notes[id] ?? '')
      if (r.approved) {
        setDone(d => ({ ...d, [id]: `配信できるようにしました（設問 ${r.items} 問）` }))
      } else {
        setError(x => ({ ...x, [id]: r.reason }))
      }
    } catch (e) {
      setError(x => ({ ...x, [id]: e instanceof Error ? e.message : '処理できませんでした' }))
    }
  })

  const left = rows.filter(r => !done[r.id])

  return (
    <div className="lv-card">
      <div className="lv-card__pad hs-stack">
        <span className="lv-label">配信できなかった教材（{left.length}）</span>
        {left.length === 0 ? (
          <p className="lv-caption">ありません。</p>
        ) : left.map(r => {
          const t = detail[r.id]
          const note = notes[r.id] ?? ''
          return (
            <div className="hs-unit" key={r.id}>
              <span className="lv-list__key">
                {r.unitId}・{new Date(r.createdAt).toLocaleDateString('ja-JP')}
              </span>
              <p className="lv-body">{r.reason ?? '理由の記録がありません'}</p>
              <button type="button" className="hs-report__open" onClick={() => read(r.id)}>
                {open === r.id ? '閉じる' : '本文を読んで判断する'}
              </button>

              {open === r.id && (
                <div className="hs-report">
                  {t === undefined ? (
                    <p className="lv-caption">読み込んでいます…</p>
                  ) : t === null ? (
                    <p className="lv-caption">教材が見つかりません。</p>
                  ) : (
                    <>
                      <p className="lv-caption">
                        {t.unitLabel}／{t.provider} {t.model}／設問 {t.itemCount} 問
                        {t.userId === null ? '／共有教材（全員が読みます）' : '／個別教材'}
                      </p>
                      {/* ★ 指摘は全文を出す。一覧は 200 字で切っており（blockedMaterials）、
                           切れた先に判断の分かれ目が入っていることがある */}
                      <span className="lv-list__key">事実確認が付けた指摘</span>
                      <p className="lv-body">{t.reason ?? '理由の記録がありません'}</p>
                      {t.sections.map(s => (
                        <div className="hs-stack" key={s.ord}>
                          <span className="lv-list__key">§{s.ord} {s.heading}</span>
                          <p className="lv-body">{s.bodyMd}</p>
                        </div>
                      ))}
                      {t.supersedes && (
                        <p className="lv-caption">
                          配信すると、いまの「{t.supersedes.title}」と入れ替わります。
                        </p>
                      )}
                      <label className="lv-caption" htmlFor={`note-${r.id}`}>
                        なぜこの指摘を退けて配信してよいと判断したか（記録に残ります）
                      </label>
                      <textarea
                        id={`note-${r.id}`}
                        className="hs-report__text"
                        rows={3}
                        maxLength={MAX_NOTE_CHARS}
                        value={note}
                        onChange={e => setNotes(n => ({ ...n, [r.id]: e.target.value }))}
                        placeholder="例: 三部会は1614年10月招集・1615年2月閉会。本文の記述は誤りではない"
                      />
                      <button
                        type="button" className="lv-btn lv-btn--primary lv-btn--block"
                        disabled={pending || note.trim().length === 0}
                        onClick={() => approve(r.id)}
                      >
                        配信できるようにする
                      </button>
                      <p className="lv-caption">
                        指摘の方ではなく正典（canon_event）が誤っている場合は、
                        seed/canon_event.csv を直して作り直す方が筋が良いです。
                      </p>
                    </>
                  )}
                </div>
              )}
              {error[r.id] && <p className="lv-field-note" role="status">{error[r.id]}</p>}
            </div>
          )
        })}
        {Object.entries(done).map(([id, label]) => (
          <p className="lv-caption" key={id}>{label}</p>
        ))}
      </div>
    </div>
  )
}
