import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { Screen, Card } from '@/components/ui'
import { NotReady } from '@/components/not-ready'
import { timeline, TIMELINE_LIMIT } from '@/lib/loop/timeline'
import { REGION_SHAPES } from '@/lib/map/regions'
import { TimelineView } from './view'

export const dynamic = 'force-dynamic'

/**
 * 年表と地図の対照（docs/06-desktop.md 画面B）
 *
 * ★ **Phase5 の「歴史タイムライン」ではない**（docs/11-ux.md:302 と混同しない）。
 *   あれは学習機能としての年表で、Phase2 に回っている。
 *   ここで作るのは、既に在る canon_event 1,180件を並べて地図と対照させる
 *   デスクトップの閲覧画面である。新しいデータも新しい表も要らない。
 *
 * ★ 絞り込みは URL でやる（`?from=&to=&q=&region=`）。
 *   見ている範囲をそのまま人に渡せるし、戻るボタンが効く。
 */
export default async function Timeline({
  searchParams,
}: {
  searchParams: Promise<{ from?: string; to?: string; q?: string; region?: string }>
}) {
  const db = tryDb()
  const userId = await currentUserId()
  const sp = await searchParams

  if (!db || !userId) {
    return <Screen title="年表と地図" tab="timeline"><NotReady /></Screen>
  }

  const num = (v: string | undefined) => {
    const n = Number(v)
    return v !== undefined && v !== '' && Number.isFinite(n) ? n : null
  }
  const from = num(sp.from), to = num(sp.to), regionId = num(sp.region)
  const q = sp.q ?? ''

  const events = await timeline(db, { from, to, query: q, regionId })

  return (
    <Screen title="年表と地図" tab="timeline">
      <Card>
        <span className="lv-label">絞る</span>
        <form className="hs-report__row" method="get">
          <input className="lv-input" type="number" name="from" defaultValue={sp.from ?? ''}
                 placeholder="西暦から" aria-label="西暦から（紀元前は負の数）" />
          <input className="lv-input" type="number" name="to" defaultValue={sp.to ?? ''}
                 placeholder="西暦まで" aria-label="西暦まで" />
          <input className="lv-input" type="search" name="q" defaultValue={q}
                 placeholder="出来事の名前" aria-label="出来事をさがす" />
          <select className="lv-input" name="region" defaultValue={sp.region ?? ''} aria-label="地域で絞る">
            <option value="">すべての地域</option>
            {REGION_SHAPES.map(s => <option key={s.id} value={s.id}>{s.label}</option>)}
          </select>
          <button type="submit" className="lv-btn">絞る</button>
        </form>
        <p className="lv-caption">
          {events.length} 件
          {events.length >= TIMELINE_LIMIT && `（上限 ${TIMELINE_LIMIT} 件。範囲を狭めてください）`}
          。紀元前は負の数で入れます（例: -330）。
        </p>
      </Card>

      <TimelineView events={events} />
    </Screen>
  )
}
