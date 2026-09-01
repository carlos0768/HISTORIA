import { ALGO_VERSION, SCHED_VERSION } from '@/lib/domain/params'

/**
 * 暫定のホーム。閉ループの画面は lib/domain のテストが揃ってから差し替える。
 * いまは「何が実装済みか」を示す足場として置いている。
 */
export default function Home() {
  return (
    <main className="lv-screen">
      <header className="lv-appbar">
        <span className="lv-appbar__title">HISTORIA</span>
      </header>
      <section style={{ padding: 'var(--lv-space-6)' }}>
        <h1 className="lv-title">構築中</h1>
        <p className="lv-body">
          仕様は <code>docs/</code> に、マスタは <code>seed/</code> にあります。
          学習ロジック（SM-2・弱点推定・スケジューラ）から実装しています。
        </p>
        <dl className="lv-list">
          <div className="lv-list__row">
            <dt className="lv-list__key">algo_version</dt>
            <dd className="lv-list__value">{ALGO_VERSION}</dd>
          </div>
          <div className="lv-list__row">
            <dt className="lv-list__key">sched_version</dt>
            <dd className="lv-list__value">{SCHED_VERSION}</dd>
          </div>
        </dl>
      </section>
    </main>
  )
}
