import Link from 'next/link'
import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { buildCheckTest } from '@/lib/loop/checktest'
import { Screen, Empty } from '@/components/ui'
import { CheckTest } from './test'
import type { Choice } from '@/app/study/quiz'

export const dynamic = 'force-dynamic'

const jstDate = (d: Date) =>
  new Intl.DateTimeFormat('ja-JP', { month: 'numeric', day: 'numeric', timeZone: 'Asia/Tokyo' }).format(d)

/**
 * 確認テスト（docs/06-assessment.md ／ docs/11 §10 の画面9）
 *
 * ★ 開いた時点でテストを作り、item_ids を固定する。作り直せると
 *   「解けるまで引き直す」ができてしまい、測定にならない（docs/06 §2.1）。
 *
 * ★ 中断できない。docs/11 §10 が「1画面1問・中断不可（測定のため）」と定めている。
 */
export default async function CheckTestPage({ params }: { params: Promise<{ drillId: string }> }) {
  const { drillId } = await params
  const db = tryDb()
  const userId = await currentUserId()

  if (!db || !userId) {
    return (
      <Screen title="確認テスト" tab="drills">
        <Empty><p className="lv-body">データベースに接続していません。</p></Empty>
      </Screen>
    )
  }

  const [drill] = await db<{ title: string }[]>`
    SELECT title FROM drill WHERE id = ${drillId} AND user_id = ${userId}`
  if (!drill) {
    return (
      <Screen title="確認テスト" tab="drills">
        <Empty>
          <p className="lv-body">この特訓は見つかりません。</p>
          <Link className="lv-btn" href="/drills">特訓の一覧へ</Link>
        </Empty>
      </Screen>
    )
  }

  const built = await buildCheckTest(db, userId, drillId, new Date())

  if (!built.ok) {
    return (
      <Screen title="確認テスト" tab="drills">
        <Empty>
          {built.reason === 'cooldown' ? (
            <>
              <p className="lv-body">まだ受けられません。</p>
              <p className="lv-caption">
                連続で受けると「さっきの問題を覚えているか」を測ることになってしまうため、
                3日空けています。{built.nextAt && `${jstDate(built.nextAt)} から受けられます。`}
              </p>
            </>
          ) : (
            <>
              <p className="lv-body">出題できる設問がまだありません。</p>
              <p className="lv-caption">
                教材を作ると設問も一緒に作られます。14日以内に解いた設問は避けるので、
                解いたばかりのときも出せないことがあります。
              </p>
            </>
          )}
          <Link className="lv-btn" href="/drills">特訓の一覧へ</Link>
        </Empty>
      </Screen>
    )
  }

  const rows = await db<{ id: string; stem: string; choices: Choice[] | null }[]>`
    SELECT id, stem, choices FROM item WHERE id = ANY(${built.itemIds})`
  // item_ids の順を保つ（DB の返す順に頼らない）
  const byId = new Map(rows.map(r => [r.id, r]))
  const items = built.itemIds
    .map(id => byId.get(id))
    .filter((r): r is { id: string; stem: string; choices: Choice[] | null } => !!r && !!r.choices?.length)
    .map(r => ({ id: r.id, stem: r.stem, choices: r.choices! }))

  return (
    <Screen title="確認テスト" tab="drills">
      <p className="lv-caption">{drill.title}</p>
      <CheckTest testId={built.testId} drillId={drillId} items={items} />
    </Screen>
  )
}
