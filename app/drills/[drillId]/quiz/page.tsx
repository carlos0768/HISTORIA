import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { drillCards, studyDrill } from '@/lib/loop/drill-study'
import { Screen, Empty } from '@/components/ui'
import { NotReady } from '@/components/not-ready'
import { RecallQuiz } from './recall'

export const dynamic = 'force-dynamic'

export default async function RecallQuizPage({ params }: { params: Promise<{ drillId: string }> }) {
  const { drillId } = await params
  const db = tryDb()
  const userId = await currentUserId()
  if (!db || !userId) return <Screen title="一問一答" tab="drills"><NotReady /></Screen>

  const [drill, cards] = await Promise.all([
    studyDrill(db, userId, drillId),
    drillCards(db, userId, drillId),
  ])
  if (!drill) return <Screen title="一問一答" tab="drills"><Empty><p className="lv-body">この特訓は見つかりません。</p></Empty></Screen>

  return (
    <Screen title="一問一答" tab="drills">
      <p className="lv-caption">{drill.title}</p>
      {cards.length > 0
        ? <RecallQuiz cards={cards} drillId={drillId} />
        : <Empty><p className="lv-body">出題できる一問一答がまだありません。</p><p className="lv-caption">教材を作ると問題も一緒に作られます。</p></Empty>}
    </Screen>
  )
}
