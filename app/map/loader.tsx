'use client'

import dynamic from 'next/dynamic'
import { useEffect, useState } from 'react'
import type { Basemap } from '@/components/map-workspace'

/**
 * 50m の基図を**この画面を開いたときだけ**読む（docs/06-desktop.md 04）
 *
 * ★ lib/map/basemap-50m.ts は約1MB ある。静的に import すると、
 *   地図を一度も開かない読者にも毎回送ることになる。
 *   モバイルの初回転送量を増やさない、が地図の唯一の制約である
 *   （lib/map/basemap.ts の110m・166KB は教材の本文で使うので据え置き）。
 *
 * ★ 読み込み中に何を出すかを決めておく。1MB は回線によっては数秒かかる。
 *   何も出さないと「壊れている」と読まれる。
 */
const MapWorkspace = dynamic(
  () => import('@/components/map-workspace').then(m => m.MapWorkspace),
  { ssr: false, loading: () => <p className="lv-caption">地図を読み込んでいます…</p> },
)

export function MapLoader({ regionIds, title }: { regionIds: number[]; title: string }) {
  const [basemap, setBasemap] = useState<Basemap | null>(null)
  const [failed, setFailed] = useState(false)

  useEffect(() => {
    let live = true
    import('@/lib/map/basemap-50m')
      .then(m => { if (live) setBasemap(m as unknown as Basemap) })
      .catch(() => { if (live) setFailed(true) })
    return () => { live = false }
  }, [])

  if (failed) {
    return (
      <p className="lv-caption">
        地図を読み込めませんでした。通信を確かめて開き直してください。
      </p>
    )
  }
  if (!basemap) return <p className="lv-caption">地図を読み込んでいます…</p>
  return <MapWorkspace basemap={basemap} regionIds={regionIds} title={title} />
}
