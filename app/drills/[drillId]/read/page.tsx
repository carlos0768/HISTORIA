import Link from 'next/link'
import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { drillMaterials } from '@/lib/loop/material'
import { studyDrill } from '@/lib/loop/drill-study'
import { Screen, Card, Empty } from '@/components/ui'
import { NotReady } from '@/components/not-ready'
import { UnitMaterials } from '@/app/units'

export const dynamic = 'force-dynamic'

export default async function DrillReadPage({ params }: { params: Promise<{ drillId: string }> }) {
  const { drillId } = await params
  const db = tryDb()
  const userId = await currentUserId()

  if (!db || !userId) return <Screen title="読む" tab="drills"><NotReady /></Screen>

  const [drill, materials] = await Promise.all([
    studyDrill(db, userId, drillId),
    drillMaterials(db, userId, drillId),
  ])
  if (!drill) {
    return <Screen title="読む" tab="drills"><Empty><p className="lv-body">この特訓は見つかりません。</p></Empty></Screen>
  }

  return (
    <Screen title="読む" tab="drills">
      <p className="lv-caption">{drill.title}</p>
      {materials.length > 0 ? (
        <Card><UnitMaterials units={materials} /></Card>
      ) : (
        <Empty><p className="lv-body">この特訓には教材がまだありません。</p></Empty>
      )}
      <Link className="lv-btn lv-btn--block" href={`/drills/${drillId}`}>勉強方法を選ぶ</Link>
    </Screen>
  )
}
