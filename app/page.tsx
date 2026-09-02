import Link from 'next/link'
import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { todaysPlan, drillProgressList } from '@/lib/loop/today'
import { drillMaterials } from '@/lib/loop/material'
import { streak } from '@/lib/loop/records'
import { UnitMaterials } from './units'
import { Screen, Card, TwoBars, Alert, Empty, StatusChip } from '@/components/ui'
import { NotReady } from '@/components/not-ready'
import { FakeNotice } from '@/components/fake-warning'
import { readConfig } from '@/lib/ai/client'
import { DEFAULT_MAX_DAILY } from '@/lib/domain/scheduler'
import { hasDiagnostic } from '@/lib/loop/diagnostic'

export const dynamic = 'force-dynamic'

export default async function Home() {
  const db = tryDb()
  const userId = await currentUserId()

  if (!db || !userId) {
    return (
      <Screen title="HISTORIA" tab="home">
        <NotReady />
      </Screen>
    )
  }

  const now = new Date()

  /**
   * ★ 診断が未了なら、ホームは診断の導線だけを出す（docs/11-ux.md:80）。
   *   弱点は確認テストから生まれ、確認テストは特訓の中にあり、特訓の教材は
   *   弱点から作られる。新規ユーザーはこの環のどこからも起動できないので、
   *   「今日やること 0問」と「特訓がありません」だけの画面になってしまう
   *   （docs/04 §5.1 の循環依存）。診断がその環を断ち切る唯一の入口である。
   *
   * ★ ただし**素通りできる**ようにする。共有プールが未承認だと診断は始められず、
   *   そこで足止めすると特訓も教材も使えなくなる。
   */
  if (!await hasDiagnostic(db, userId)) {
    return (
      <Screen title="HISTORIA" tab="home">
        <Card>
          <span className="lv-label">はじめに</span>
          <p className="lv-body">
            まず10分ほどの診断テストで、どこから確かめていくかの見当を付けます。
            点数は付きません。
          </p>
          <Link className="lv-btn lv-btn--primary lv-btn--block" href="/diagnostic">
            診断テストを受ける
          </Link>
          <p className="lv-caption">
            あとで受けても構いません。その場合は範囲と締切を先に決めてください。
          </p>
          <Link className="lv-btn lv-btn--block" href="/drills/new">範囲と締切を決める</Link>
        </Card>
      </Screen>
    )
  }

  const [plan, drills, days] = await Promise.all([
    todaysPlan(db, userId, now, DEFAULT_MAX_DAILY),
    drillProgressList(db, userId, now),
    streak(db, userId, now),
  ])
  // 特訓ごとに、範囲の単元と教材の状態を引く（生成中・配信不可を隠さない）
  const materials = await Promise.all(drills.map(d => drillMaterials(db, userId, d.drillId)))

  // ★ 作る前に言う。鍵が無いと resolveProvider が黙ってフェイクに落ちるので、
  //   作ってから気づくと、でたらめな本文を読んだあとになる
  const cfg = readConfig()
  const usingFake = !cfg.geminiApiKey || !cfg.anthropicApiKey

  return (
    <Screen title="HISTORIA" tab="home"
            /* ★ 0日のときは出さない。「0日連続」は続けたい気持ちを削ぐだけで、
                 情報も無い（docs/11-ux.md §7.1 の「罪悪感で離脱を招く」） */
            trailing={days.current > 0 ? <><b>{days.current}</b>日連続</> : undefined}>
      {usingFake && <FakeNotice />}
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
