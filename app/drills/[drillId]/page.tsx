import Link from 'next/link'
import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { drillProgressFor } from '@/lib/loop/today'
import { Screen, Card, Empty, TwoBars } from '@/components/ui'
import { NotReady } from '@/components/not-ready'

export const dynamic = 'force-dynamic'

const MODES = [
  { segment: 'read', label: '読む', primary: true },
  { segment: 'flashcards', label: 'フラッシュカード', primary: false },
  { segment: 'quiz', label: '一問一答', primary: false },
  { segment: 'map', label: '地図を確認', primary: false },
] as const

export default async function DrillStudyPage({ params }: { params: Promise<{ drillId: string }> }) {
  const { drillId } = await params
  const db = tryDb()
  const userId = await currentUserId()

  if (!db || !userId) {
    return <Screen title="勉強する" tab="drills"><NotReady /></Screen>
  }

  const drill = await drillProgressFor(db, userId, drillId, new Date())
  if (!drill) {
    return (
      <Screen title="勉強する" tab="drills">
        <Empty>
          <p className="lv-body">この特訓は見つかりません。</p>
          <Link className="lv-btn" href="/drills">特訓の一覧へ</Link>
        </Empty>
      </Screen>
    )
  }

  return (
    <Screen title="勉強する" tab="drills">
      <Card>
        <p className="lv-heading">{drill.title}</p>
        <TwoBars
          masteredCount={drill.masteredCount} totalKc={drill.totalKc}
          materialsRead={drill.materialsRead} materialsTotal={drill.materialsTotal}
        />
      </Card>

      <nav className="hs-study-modes" aria-label={`${drill.title}の勉強方法`}>
        {MODES.map(mode => (
          <Link
            key={mode.segment}
            className={`lv-btn lv-btn--block${mode.primary ? ' lv-btn--primary' : ''}`}
            href={`/drills/${drillId}/${mode.segment}`}
          >
            {mode.label}
          </Link>
        ))}
      </nav>
    </Screen>
  )
}
