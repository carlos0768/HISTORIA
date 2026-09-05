import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { drillCards, studyDrill } from '@/lib/loop/drill-study'
import { Screen, Empty } from '@/components/ui'
import { NotReady } from '@/components/not-ready'
import { Flashcards } from './flashcards'

export const dynamic = 'force-dynamic'

export default async function FlashcardsPage({ params }: { params: Promise<{ drillId: string }> }) {
  const { drillId } = await params
  const db = tryDb()
  const userId = await currentUserId()
  if (!db || !userId) return <Screen title="フラッシュカード" tab="drills"><NotReady /></Screen>

  const [drill, cards] = await Promise.all([
    studyDrill(db, userId, drillId),
    drillCards(db, userId, drillId),
  ])
  if (!drill) return <Screen title="フラッシュカード" tab="drills"><Empty><p className="lv-body">この特訓は見つかりません。</p></Empty></Screen>

  return (
    <Screen title="フラッシュカード" tab="drills">
      <p className="lv-caption">{drill.title}</p>
      {cards.length > 0
        ? <Flashcards cards={cards} drillId={drillId} />
        : <Empty><p className="lv-body">使えるフラッシュカードがまだありません。</p><p className="lv-caption">教材を作るとカードも一緒に作られます。</p></Empty>}
    </Screen>
  )
}
