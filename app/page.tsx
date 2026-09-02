import Link from 'next/link'
import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { todaysPlan, drillProgressList } from '@/lib/loop/today'
import { drillMaterials } from '@/lib/loop/material'
import { UnitMaterials } from './units'
import { Screen, Card, TwoBars, Alert, Empty, StatusChip } from '@/components/ui'
import { DEFAULT_MAX_DAILY } from '@/lib/domain/scheduler'

export const dynamic = 'force-dynamic'

export default async function Home() {
  const db = tryDb()
  const userId = await currentUserId()

  if (!db || !userId) {
    return (
      <Screen title="HISTORIA" tab="home">
        <Empty>
          <p className="lv-body">データベースに接続していません。</p>
          <p className="lv-caption">
            <code>DATABASE_URL</code> と <code>DEMO_USER_ID</code> を設定すると、
            今日やることが表示されます。
          </p>
        </Empty>
      </Screen>
    )
  }

  const now = new Date()
  const [plan, drills] = await Promise.all([
    todaysPlan(db, userId, now, DEFAULT_MAX_DAILY),
    drillProgressList(db, userId, now),
  ])
  // 特訓ごとに、範囲の単元と教材の状態を引く（生成中・配信不可を隠さない）
  const materials = await Promise.all(drills.map(d => drillMaterials(db, userId, d.drillId)))

  return (
    <Screen title="HISTORIA" tab="home">
      {/* ホームに出す数字は1つだけ。特訓ごとのノルマは出さない（docs/05 §5.1） */}
      <Card>
        <span className="lv-label">今日やること</span>
        <p className="hs-count">
          <span className="lv-display">{plan.targetCount}</span>
          <span className="lv-body">問</span>
        </p>
        {plan.targetCount > 0 ? (
          <Link className="lv-btn lv-btn--primary lv-btn--block" href="/study">はじめる</Link>
        ) : (
          <p className="lv-caption">今日の分は終わりました。</p>
        )}
      </Card>

      {/* 達成不能を黙って丸めない（docs/05 §3.2） */}
      {!plan.feasible && (
        <Alert title="このペースでは締切に間に合いません">
          <p className="lv-body">
            残り {plan.daysLeft} 日 / 必要 {plan.need} 回 / 1日あたり{' '}
            {Math.ceil(plan.need / plan.daysLeft)} 回（上限 {plan.targetCount} 回）
          </p>
          <p className="lv-body">約 {plan.shortfall} 回分が不足します。</p>
        </Alert>
      )}

      <div className="hs-stack">
        <div className="lv-list__row">
          <span className="lv-label">集中特訓</span>
          <Link className="lv-chip" href="/drills/new">範囲を選んで作る</Link>
        </div>
        {drills.length === 0 && (
          <Empty>
            <p className="lv-body">まだ特訓がありません。</p>
            <p className="lv-caption">教科書の章立てから範囲を選ぶと、今日やることが決まります。</p>
          </Empty>
        )}
        {drills.map((d, di) => {
          const daysLeft = Math.ceil((d.deadline.getTime() - now.getTime()) / 86_400_000)
          return (
            <Card key={d.drillId}>
              <p className="lv-heading">
                {d.state === 'overdue'
                  ? `締切を過ぎています — ${d.title}`
                  : `あと${daysLeft}日で「${d.title}」を仕上げよう`}
              </p>
              <TwoBars
                masteredCount={d.masteredCount} totalKc={d.totalKc}
                materialsRead={d.materialsRead} materialsTotal={d.materialsTotal}
              />
              {d.state === 'overdue' && <p className="lv-caption">新しい締切を設定しますか？</p>}
              <UnitMaterials units={materials[di] ?? []} />
            </Card>
          )
        })}
      </div>

      {plan.queue.length > 0 && (
        <div>
          <span className="lv-label">今日の内訳</span>
          <div className="lv-list">
            {plan.queue.slice(0, 8).map(q => (
              <div key={q.kcId} className="lv-list__row">
                <span className="lv-list__value">{q.label ?? q.kcId}</span>
                <StatusChip status={q.status} />
              </div>
            ))}
          </div>
        </div>
      )}
    </Screen>
  )
}
