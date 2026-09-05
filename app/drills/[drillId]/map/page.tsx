import Link from 'next/link'
import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { drillRegionIds, studyDrill } from '@/lib/loop/drill-study'
import { Screen, Empty } from '@/components/ui'
import { NotReady } from '@/components/not-ready'
import { MapLoader } from '@/app/map/loader'

export const dynamic = 'force-dynamic'

export default async function DrillMapPage({ params }: { params: Promise<{ drillId: string }> }) {
  const { drillId } = await params
  const db = tryDb()
  const userId = await currentUserId()
  if (!db || !userId) return <Screen title="地図を確認" tab="drills"><NotReady /></Screen>

  const [drill, regionIds] = await Promise.all([
    studyDrill(db, userId, drillId),
    drillRegionIds(db, userId, drillId),
  ])
  if (!drill) return <Screen title="地図を確認" tab="drills"><Empty><p className="lv-body">この特訓は見つかりません。</p></Empty></Screen>

  return (
    <Screen title="地図を確認" tab="drills">
      <p className="lv-caption">{drill.title}</p>
      {regionIds.length > 0
        ? <MapLoader regionIds={regionIds} title={`${drill.title}の地図`} />
        : <Empty><p className="lv-body">この特訓には地図で確認する地域がありません。</p></Empty>}
      <Link className="lv-btn lv-btn--block" href={`/drills/${drillId}`}>勉強方法を選ぶ</Link>
    </Screen>
  )
}
