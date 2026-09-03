'use client'

import { useState } from 'react'
import { WorldMap } from '@/components/world-map'
import { formatSpan, type TimelineEvent } from '@/lib/loop/timeline'

/**
 * 年表と地図の連動（docs/06-desktop.md 画面B）
 *
 * ★ 選んだ出来事の `region_ids` で地図を塗る。年表と地図が別々に置いてあるだけなら、
 *   2つの画面を並べたのと変わらない。**対照させることがこの画面の意味である。**
 *
 * ★ 地図は既存の `components/world-map.tsx`（110m・静止）を使う。
 *   ここは「どの辺りか」が分かれば足り、拡大して見る場所ではない。
 *   50m の基図（約1MB）を読むのは /map だけにする。
 *
 * ★ 何も選んでいないときは地図を出さない。空の地図は場所を取るだけで
 *   情報が無く、初期表示で年表が下に押し出される。
 */
export function TimelineView({ events }: { events: readonly TimelineEvent[] }) {
  const [selected, setSelected] = useState<TimelineEvent | null>(null)

  if (events.length === 0) {
    return <p className="lv-caption">条件に合う出来事がありません。</p>
  }

  return (
    <>
      {selected && (
        <div className="lv-card">
          <div className="lv-card__pad hs-stack">
            <div className="hs-titlerow">
              <span className="lv-label">{selected.label}</span>
              <span className="lv-caption">{formatSpan(selected)}</span>
            </div>
            {selected.regionIds.length > 0 ? (
              <WorldMap highlight={selected.regionIds} title={selected.label} />
            ) : (
              <p className="lv-caption">この出来事には地域が付いていません。</p>
            )}
          </div>
        </div>
      )}

      <div className="hs-timeline">
        {events.map(e => (
          <button
            key={e.id} type="button"
            className={`hs-timeline__row${selected?.id === e.id ? ' hs-timeline__row--active' : ''}`}
            aria-pressed={selected?.id === e.id}
            onClick={() => setSelected(s => s?.id === e.id ? null : e)}
          >
            <span className="hs-timeline__year">{formatSpan(e)}</span>
            <span className="hs-timeline__label">{e.label}</span>
          </button>
        ))}
      </div>
    </>
  )
}
