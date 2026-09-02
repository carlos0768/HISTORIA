'use client'

import { useState, useTransition } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'
import type { UnitMaterial } from '@/lib/loop/material'
import { generateMaterialAction } from './drills/actions'

const STATUS_TEXT: Record<UnitMaterial['status'], string> = {
  none: 'まだ作っていない',
  generating: '作っています',
  ready: '読める',
  blocked: '配信していない',
  superseded: '古い版',
  failed: '作れなかった',
}

/**
 * 特訓の範囲に対する教材の状態。
 *
 * ★ 生成中・配信不可を隠さない。作者判断 Q4 でユニットごと止める設計なので、
 *   止まっていることと理由が見えないと、学習者には不具合と区別がつかない。
 */
export function UnitMaterials({ units }: { units: UnitMaterial[] }) {
  const router = useRouter()
  const [rows, setRows] = useState(units)
  const [busy, setBusy] = useState<string | null>(null)
  const [errors, setErrors] = useState<Record<string, string>>({})
  const [, startTransition] = useTransition()

  const build = (unitId: string, force: boolean) => {
    if (busy) return
    setBusy(unitId)
    setErrors(prev => ({ ...prev, [unitId]: '' }))
    startTransition(async () => {
      try {
        const r = await generateMaterialAction({ unitId, force })
        setRows(prev => prev.map(u => u.unitId !== unitId ? u : r.ok
          ? { ...u, status: 'ready', materialId: r.materialId, blockedReason: null }
          : { ...u, status: r.status, materialId: r.materialId ?? null, blockedReason: r.reason }))
        if (!r.ok) setErrors(prev => ({ ...prev, [unitId]: r.reason }))
        // 節の数と読了数はサーバーが持っている。作った直後に取り直す。
        // 楽観更新だけだと「読了 0 / 7」が出せず、状態だけが変わって見える
        router.refresh()
      } catch (e) {
        setErrors(prev => ({ ...prev, [unitId]: e instanceof Error ? e.message : '生成に失敗しました' }))
      } finally {
        setBusy(null)
      }
    })
  }

  return (
    <div className="hs-stack">
      {rows.map(u => {
        const pending = busy === u.unitId
        const msg = errors[u.unitId] || (u.status === 'blocked' || u.status === 'failed' ? u.blockedReason : null)
        return (
          <div key={u.unitId} className="hs-unit">
            <div className="lv-list__row">
              <span className="lv-list__value">{u.unitLabel}</span>
              <span className="lv-caption">
                {u.status === 'ready' && u.sectionCount > 0
                  ? `読了 ${u.readCount} / ${u.sectionCount}`
                  : STATUS_TEXT[u.status]}
              </span>
            </div>

            {msg && <p className="lv-field-note">{msg}</p>}

            <div className="lv-chips">
              {u.status === 'ready' && u.materialId && (
                <Link className="lv-chip lv-chip--marker" href={`/material/${u.materialId}`}>読む</Link>
              )}
              {u.status === 'none' && (
                <button type="button" className="lv-chip" disabled={pending} onClick={() => build(u.unitId, false)}>
                  {pending ? '作っています…' : '教材を作る'}
                </button>
              )}
              {(u.status === 'blocked' || u.status === 'failed') && (
                <button type="button" className="lv-chip" disabled={pending} onClick={() => build(u.unitId, true)}>
                  {pending ? '作り直しています…' : '作り直す'}
                </button>
              )}
              {u.status === 'blocked' && u.materialId && (
                <Link className="lv-chip" href={`/material/${u.materialId}`}>理由を見る</Link>
              )}
            </div>
          </div>
        )
      })}
    </div>
  )
}
