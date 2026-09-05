import { notFound } from 'next/navigation'
import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { isAdmin } from '@/lib/auth/admin'
import { Screen, Card, Empty } from '@/components/ui'
import { budgetStatus, periodOf } from '@/lib/ai/budget'
import { openReports } from '@/lib/loop/report'
import {
  generationToday, blockedMaterials, spendByPurpose, verificationSpend, cronHealth,
  RPD_LIMIT, CRON_SILENCE_HOURS,
} from '@/lib/loop/admin'
import { AdminControls } from './controls'
import { BlockedMaterials } from './blocked'

export const dynamic = 'force-dynamic'

/**
 * 管理ビュー（docs/12-nonfunctional.md §7.1）
 *
 * ★ 作者ひとりのための1画面である。利用者向けの機能ではない。
 *
 * ★ 管理者でなければ **404**。リダイレクトではない（docs/10 G2）。
 *   /login へ飛ばすと「管理画面が在る」ことを教えてしまう。
 *   `ADMIN_USER_ID` が未設定なら誰も入れない（lib/auth/admin.ts。既定は閉）。
 *
 * ★ 管理者以外にも見える主要タブには足さない。入口は設定画面からの条件付きリンク。
 */
const yen = (n: number) => `${Math.round(n).toLocaleString('ja-JP')} 円`
const pct = (n: number) => `${(n * 100).toFixed(1)}%`
const when = (d: Date | null) =>
  d === null ? '記録なし' : d.toLocaleString('ja-JP', { timeZone: 'Asia/Tokyo' })

export default async function Admin() {
  const userId = await currentUserId()
  if (!isAdmin(userId)) notFound()

  const db = tryDb()
  if (!db) {
    return (
      <Screen title="管理">
        <Empty>データベースに接続していません。</Empty>
      </Screen>
    )
  }

  const now = new Date()
  const period = periodOf(now)
  const [gen, blocked, budget, purposes, verify, cron, reports] = await Promise.all([
    generationToday(db, now),
    blockedMaterials(db),
    budgetStatus(db, now),
    spendByPurpose(db, period),
    verificationSpend(db, period),
    cronHealth(db, now),
    openReports(db),
  ])

  return (
    <Screen title="管理">
      {/* ★ 止まっているものを先頭に置く。下までスクロールしないと
           気づけない位置に警告を置くと、気づかない */}
      {budget.halted && (
        <Card>
          <span className="lv-label">遮断中</span>
          <p className="lv-body">
            当月の支出が上限に達したため、生成を止めています（{yen(budget.usedJpy)} / {yen(budget.capJpy)}）。
          </p>
        </Card>
      )}

      {cron.some(c => c.stale) && (
        <Card>
          <span className="lv-label">定時実行が止まっている疑い</span>
          <p className="lv-body">
            {CRON_SILENCE_HOURS} 時間以上、実行の記録がありません:
            {' '}{cron.filter(c => c.stale).map(c => c.kind).join('・')}
          </p>
          <p className="lv-caption">
            CRON_SECRET が未設定だと /api/cron は 404 を返し、1行も記録されません。
          </p>
        </Card>
      )}

      <Card>
        <span className="lv-label">当日の生成</span>
        <div className="lv-list">
          <div className="lv-list__row">
            <span className="lv-list__key">リクエスト</span>
            <span className="lv-list__value">
              {gen.requests} / {RPD_LIMIT}（{pct(gen.usage)}）
            </span>
          </div>
          <div className="lv-list__row">
            <span className="lv-list__key">失敗</span>
            <span className="lv-list__value">{gen.failed} 件</span>
          </div>
          <div className="lv-list__row">
            <span className="lv-list__key">実行中</span>
            <span className="lv-list__value">{gen.running} 件</span>
          </div>
        </div>
      </Card>

      <Card>
        <span className="lv-label">当月の支出（{period}）</span>
        <div className="lv-list">
          <div className="lv-list__row">
            <span className="lv-list__key">使用</span>
            <span className="lv-list__value">{yen(budget.usedJpy)} / {yen(budget.capJpy)}</span>
          </div>
          <div className="lv-list__row">
            <span className="lv-list__key">残り</span>
            <span className="lv-list__value">{yen(budget.remainingJpy)}</span>
          </div>
          <div className="lv-list__row">
            <span className="lv-list__key">状態</span>
            <span className="lv-list__value">
              {budget.halted ? '遮断' : budget.degraded ? '縮退' : budget.warned ? '警告' : '正常'}
            </span>
          </div>
        </div>
        {purposes.length === 0 ? (
          <p className="lv-caption">当月の支出はまだありません。</p>
        ) : (
          <div className="lv-list">
            {purposes.map(p => (
              <div className="lv-list__row" key={p.purpose}>
                <span className="lv-list__key">{p.purpose}</span>
                <span className="lv-list__value">
                  確定 {yen(p.settledJpy)}／予約 {yen(p.reservedJpy)}（{p.count} 件）
                </span>
              </div>
            ))}
          </div>
        )}
        <p className="lv-caption">
          二次照合（factcheck / judge）は {verify.runs} 回・{yen(verify.jpy)}。
        </p>
      </Card>

      <AdminControls
        halted={budget.halted}
        capJpy={budget.capJpy}
        reports={reports.map(r => ({
          id: r.id, targetKind: r.targetKind, comment: r.comment, excerpt: r.excerpt,
          createdAt: r.createdAt.toISOString(),
        }))}
      />

      {/* ★ 一覧だけでなく「配信できるようにする」まで置く。層3の指摘は
           誤りとは限らず、作り直せば同じ本文はもう手に入らない（docs/02 §5） */}
      <BlockedMaterials
        rows={blocked.map(b => ({
          id: b.id, unitId: b.unitId, reason: b.reason, createdAt: b.createdAt.toISOString(),
        }))}
      />

      <Card>
        <span className="lv-label">定時実行</span>
        <div className="lv-list">
          {cron.map(c => (
            <div className="lv-list__row" key={c.kind}>
              <span className="lv-list__key">{c.kind}</span>
              <span className="lv-list__value">
                {when(c.lastRunAt)}
                {c.lastOk === false && '（失敗）'}
                {c.stale && ' — 警告'}
              </span>
            </div>
          ))}
        </div>
      </Card>
    </Screen>
  )
}
