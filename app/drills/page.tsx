import Link from 'next/link'
import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { drillProgressList } from '@/lib/loop/today'
import { Screen, Card, TwoBars, Empty } from '@/components/ui'

export const dynamic = 'force-dynamic'

const jstDate = (d: Date) =>
  new Intl.DateTimeFormat('ja-JP', { month: 'numeric', day: 'numeric', timeZone: 'Asia/Tokyo' }).format(d)

/**
 * 特訓の一覧（docs/11-ux.md §10 の画面7）
 *
 * ★ 進捗は2本のバーで出す（docs/11 §6）。習得と読了は別のものなので、
 *   1本にまとめると「教材は読んだが解けていない」が見えなくなる。
 */
export default async function Drills() {
  const db = tryDb()
  const userId = await currentUserId()

  if (!db || !userId) {
    return (
      <Screen title="特訓" tab="drills">
        <Empty><p className="lv-body">データベースに接続していません。</p></Empty>
      </Screen>
    )
  }

  const now = new Date()
  const drills = await drillProgressList(db, userId, now)

  const aside = (
    <>
      <span className="hs-side__label">特訓とは</span>
      <p className="lv-caption">
        範囲と締切を決めると、その範囲の教材と出題を締切から逆算して配ります。
        進捗の「習得」は解けるようになった項目の割合、「読了」は教材を読んだ割合です。
      </p>
      <Link className="lv-btn lv-btn--primary lv-btn--block" href="/drills/new">新しい特訓をつくる</Link>
    </>
  )

  return (
    <Screen title="特訓" tab="drills" aside={aside}>
      {drills.length === 0 ? (
        <Empty>
          <p className="lv-body">進行中の特訓はありません。</p>
          <p className="lv-caption">範囲と締切を決めると、そこから逆算して毎日の分量が決まります。</p>
          <Link className="lv-btn lv-btn--primary" href="/drills/new">新しい特訓をつくる</Link>
        </Empty>
      ) : (
        <>
          {drills.map(d => (
            <Card key={d.drillId}>
              {/* ★ 題名は長い。lv-meta__row は flex なので、縮む指定が無いと
                   締切と詰まって画面から溢れる（375px で実測） */}
              <div className="hs-titlerow">
                <span className="lv-list__value">{d.title}</span>
                <span className="lv-caption">{jstDate(d.deadline)} まで</span>
              </div>
              <TwoBars
                masteredCount={d.masteredCount} totalKc={d.totalKc}
                materialsRead={d.materialsRead} materialsTotal={d.materialsTotal}
              />
            </Card>
          ))}
          <Link className="lv-btn lv-btn--block" href="/drills/new">新しい特訓をつくる</Link>
        </>
      )}
    </Screen>
  )
}
