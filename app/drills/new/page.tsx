import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { unitTree } from '@/lib/pipeline/drill'
import { Screen } from '@/components/ui'
import { NotReady } from '@/components/not-ready'
import { RangePicker } from './picker'

export const dynamic = 'force-dynamic'

/** 締切の既定値。今日から30日後（Asia/Tokyo の日付で出す） */
function defaultDeadline(): string {
  const d = new Date(Date.now() + 30 * 86_400_000)
  return new Intl.DateTimeFormat('en-CA', { timeZone: 'Asia/Tokyo' }).format(d)
}

export default async function NewDrill({ searchParams }: { searchParams: Promise<{ unit?: string | string[] }> }) {
  const db = tryDb()
  const userId = await currentUserId()

  if (!db || !userId) {
    return (
      <Screen title="範囲を選ぶ" tab="drills">
        <NotReady />
      </Screen>
    )
  }

  const tree = await unitTree(db)
  const { unit } = await searchParams
  const initialUnitId = typeof unit === 'string' && /^[a-z0-9.]+$/.test(unit) ? unit : undefined
  return (
    <Screen title="範囲を選ぶ" tab="drills">
      <RangePicker tree={tree} defaultDeadline={defaultDeadline()} initialUnitId={initialUnitId} />
    </Screen>
  )
}
