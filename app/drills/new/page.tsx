import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { unitTree } from '@/lib/pipeline/drill'
import { Screen, Empty } from '@/components/ui'
import { RangePicker } from './picker'

export const dynamic = 'force-dynamic'

/** 締切の既定値。今日から30日後（Asia/Tokyo の日付で出す） */
function defaultDeadline(): string {
  const d = new Date(Date.now() + 30 * 86_400_000)
  return new Intl.DateTimeFormat('en-CA', { timeZone: 'Asia/Tokyo' }).format(d)
}

export default async function NewDrill() {
  const db = tryDb()
  const userId = await currentUserId()

  if (!db || !userId) {
    return (
      <Screen title="範囲を選ぶ" tab="drills">
        <Empty>
          <p className="lv-body">データベースに接続していません。</p>
          <p className="lv-caption"><code>DATABASE_URL</code> と <code>DEMO_USER_ID</code> が要ります。</p>
        </Empty>
      </Screen>
    )
  }

  const tree = await unitTree(db)
  return (
    <Screen title="範囲を選ぶ" tab="drills">
      <RangePicker tree={tree} defaultDeadline={defaultDeadline()} />
    </Screen>
  )
}
