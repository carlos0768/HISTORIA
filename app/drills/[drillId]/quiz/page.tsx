import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { drillQuizItems, studyDrill } from '@/lib/loop/drill-study'
import { Screen, Empty } from '@/components/ui'
import { NotReady } from '@/components/not-ready'
import { ChoiceQuiz } from './choice-quiz'

export const dynamic = 'force-dynamic'

/**
 * 一問一答（四択）。docs/11-ux.md §1.2 の4つの学習方法のひとつ。
 *
 * 出題順は SM-2 が決める（lib/domain/scheduler.ts drillQueue）。
 * due になった KC が先、まだ due でない KC は後ろに並ぶ。
 */
export default async function DrillQuizPage({ params }: { params: Promise<{ drillId: string }> }) {
  const { drillId } = await params
  const db = tryDb()
  const userId = await currentUserId()
  if (!db || !userId) return <Screen title="一問一答" tab="drills"><NotReady /></Screen>

  const now = new Date()
  const [drill, items] = await Promise.all([
    studyDrill(db, userId, drillId),
    drillQuizItems(db, userId, drillId, now),
  ])
  if (!drill) return <Screen title="一問一答" tab="drills"><Empty><p className="lv-body">この特訓は見つかりません。</p></Empty></Screen>

  return (
    <Screen title="一問一答" tab="drills">
      <p className="lv-caption">{drill.title}</p>
      {items.length > 0
        ? <ChoiceQuiz items={items} drillId={drillId} />
        : <Empty><p className="lv-body">出題できる四択がまだありません。</p><p className="lv-caption">教材を作ると問題も一緒に作られます。</p></Empty>}
    </Screen>
  )
}
