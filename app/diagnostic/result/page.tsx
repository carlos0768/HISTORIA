import Link from 'next/link'
import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { Screen, Empty, Card } from '@/components/ui'
import { NotReady } from '@/components/not-ready'
import { diagnosticState } from '@/lib/loop/diagnostic'
import { ERA_IDS, GRID_IDS, cellKey, THETA_0 } from '@/lib/domain/diagnostic'

export const dynamic = 'force-dynamic'

/**
 * 診断の結果（docs/04-weakness-engine.md §5.5）
 *
 * ★ **弱点を断定しない。** 24問で 800〜900 の KC を判定したと表示すれば、
 *   実際には測っていないものを断定することになり、初日に信頼を壊す。
 *   仕様が文言まで定めている:
 *
 *     ✅「まずここから測っていきます」
 *     ❌「あなたの弱点はこれです」
 *
 * ★ 点数を出さない。何問正解したかは測定の目的ではないうえ、
 *   出すと「低い点数を取った」という記憶だけが残る。
 *
 * ★ 1問も出せなかったセルは「まだ測っていません」と**書く**。
 *   空欄にすると「測ったが何も無かった」と読まれる。
 */

/** 診断で測った順序だけを示す3段階。数値も百分率も出さない */
const BAND = [
  { label: 'ここから始めます', max: THETA_0 },
  { label: '次に進みます', max: 0.5 },
  { label: 'あとで確かめます', max: Infinity },
] as const

const band = (theta: number) => BAND.find(b => theta <= b.max)!.label

export default async function DiagnosticResult() {
  const db = tryDb()
  const userId = await currentUserId()

  if (!db || !userId) {
    return (
      <Screen title="診断の結果">
        <NotReady />
      </Screen>
    )
  }

  const state = await diagnosticState(db, userId)
  if (state.answered === 0) {
    return (
      <Screen title="診断の結果">
        <Empty>
          <p className="lv-body">まだ診断を受けていません。</p>
          <Link className="lv-btn" href="/diagnostic">診断を始める</Link>
        </Empty>
      </Screen>
    )
  }

  const eras = await db<{ id: number; label: string }[]>`
    SELECT id, label FROM era ORDER BY ord`
  const grids = await db<{ grid_id: number; label: string }[]>`
    SELECT DISTINCT ON (grid_id) grid_id, label
      FROM region WHERE parent_id IS NULL ORDER BY grid_id, ord`
  const gridLabel = new Map(grids.map(g => [g.grid_id, g.label]))

  return (
    <Screen title="診断の結果">
      <Card>
        <span className="lv-label">まずここから測っていきます</span>
        <p className="lv-body">
          {state.answered} 問から、どのあたりを先に確かめるかの見当を付けました。
          これは<b>順番の目安</b>であって、得意不得意の判定ではありません。
        </p>
        <p className="lv-caption">
          本当の弱点は、これから解いた記録が溜まってから分かります。
          いまの時点では、どの項目も「まだ測っていない」扱いのままです。
        </p>
      </Card>

      {ERA_IDS.map(eraId => (
        <Card key={eraId}>
          <span className="lv-label">{eras.find(e => e.id === eraId)?.label ?? `時代 ${eraId}`}</span>
          <div className="lv-list">
            {GRID_IDS.map(gridId => {
              const c = state.cells.get(cellKey(eraId, gridId))
              return (
                <div className="lv-list__row" key={gridId}>
                  <span className="lv-list__key">{gridLabel.get(gridId) ?? `地域 ${gridId}`}</span>
                  <span className="lv-list__value">
                    {!c || c.answered === 0 ? 'まだ測っていません' : band(c.theta)}
                  </span>
                </div>
              )
            })}
          </div>
        </Card>
      ))}

      <Card>
        <span className="lv-label">次にやること</span>
        <p className="lv-body">
          範囲と締切を決めると、この順番にそって教材と出題が並びます。
        </p>
        <Link className="lv-btn lv-btn--primary lv-btn--block" href="/drills/new">
          範囲と締切を決める
        </Link>
        <Link className="lv-btn lv-btn--block" href="/">ホームへ</Link>
      </Card>
    </Screen>
  )
}
