'use client'

import { useState, useTransition } from 'react'
import { resolveReportAction, resumeBudgetAction, setCapAction } from './actions'
import { REPORT_STATUSES, type ReportStatus, type ReportTarget } from '@/lib/loop/report'

/**
 * 管理画面のうち、押すもの（docs/12-nonfunctional.md §7.1・§7.2）
 *
 * ★ 判定パラメータ（guess / slip / ef の初期値 / 打ち切り条件）は**置かない**。
 *   docs/12 §7.2 が「変えたら response から再計算しないと新旧の判定が混在する」
 *   として、管理画面から触れるようにしてはいけないと定めている。
 *   ここに在るのは上限額と遮断の解除、そして報告の処理だけである。
 */

const STATUS_LABEL: Record<ReportStatus, string> = {
  confirmed: '誤りだった（本文を伏せる）',
  dismissed: '誤報だった（何もしない）',
  fixed: '直した',
}

const KIND_LABEL: Record<ReportTarget, string> = {
  material_section: '教材',
  item: '設問',
}

export type ReportRow = {
  id: string
  targetKind: ReportTarget
  comment: string | null
  excerpt: string | null
  createdAt: string
}

export function AdminControls({
  halted, capJpy, reports,
}: {
  halted: boolean
  capJpy: number
  reports: ReportRow[]
}) {
  const [cap, setCapInput] = useState(String(capJpy))
  const [msg, setMsg] = useState<string | null>(null)
  const [done, setDone] = useState<Record<string, string>>({})
  const [pending, start] = useTransition()

  const resolve = (id: string, status: ReportStatus) => start(async () => {
    setMsg(null)
    try {
      const r = await resolveReportAction(id, status)
      setDone(d => ({ ...d, [id]: r.hidden ? '伏せました' : '処理しました' }))
    } catch (e) {
      setMsg(e instanceof Error ? e.message : '処理できませんでした')
    }
  })

  const resume = () => start(async () => {
    setMsg(null)
    try {
      const r = await resumeBudgetAction()
      setMsg(r.resumed ? '遮断を解除しました' : '遮断されていません')
    } catch (e) {
      setMsg(e instanceof Error ? e.message : '解除できませんでした')
    }
  })

  const save = () => start(async () => {
    const r = await setCapAction(Number(cap))
    setMsg(r.message)
  })

  const open = reports.filter(r => !done[r.id])

  return (
    <>
      <div className="lv-card">
        <div className="lv-card__pad hs-stack">
          <span className="lv-label">支出の遮断器</span>
          <p className="lv-caption">
            上限は変えられます。判定に使うパラメータ（guess / slip / ef の初期値・
            打ち切り条件）はここからは変えられません。変えると新旧の判定が混ざるためです。
          </p>
          <div className="lv-field">
            <label className="lv-caption" htmlFor="cap">当月の上限（円）</label>
            <input
              id="cap" className="lv-input" type="number" inputMode="numeric"
              min={1} value={cap} onChange={e => setCapInput(e.target.value)}
            />
          </div>
          <button type="button" className="lv-btn lv-btn--block" disabled={pending} onClick={save}>
            上限を保存する
          </button>
          {halted && (
            <button
              type="button" className="lv-btn lv-btn--block lv-btn--primary"
              disabled={pending} onClick={resume}
            >
              遮断を解除する（上限は変えません）
            </button>
          )}
          {msg && <p className="lv-field-note" role="status">{msg}</p>}
        </div>
      </div>

      <div className="lv-card">
        <div className="lv-card__pad hs-stack">
          <span className="lv-label">未処理の誤り報告（{open.length}）</span>
          {open.length === 0 ? (
            <p className="lv-caption">ありません。</p>
          ) : open.map(r => (
            <div className="hs-unit" key={r.id}>
              <span className="lv-list__key">
                {KIND_LABEL[r.targetKind]}・{new Date(r.createdAt).toLocaleDateString('ja-JP')}
              </span>
              <p className="lv-body">{r.excerpt ?? '（対象が見つかりません）'}</p>
              {r.comment && <p className="lv-caption">報告: {r.comment}</p>}
              <div className="hs-report__row">
                {REPORT_STATUSES.map(s => (
                  <button
                    key={s} type="button" className="lv-btn"
                    disabled={pending} onClick={() => resolve(r.id, s)}
                  >
                    {STATUS_LABEL[s]}
                  </button>
                ))}
              </div>
            </div>
          ))}
          {Object.entries(done).map(([id, label]) => (
            <p className="lv-caption" key={id}>{label}</p>
          ))}
        </div>
      </div>
    </>
  )
}
