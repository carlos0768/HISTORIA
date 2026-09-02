import Link from 'next/link'
import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { weakKcs, streak } from '@/lib/loop/records'
import { Screen, Card, Empty, StatusChip, MasteryBar } from '@/components/ui'
import { NotReady } from '@/components/not-ready'

export const dynamic = 'force-dynamic'

/**
 * 記録タブ（docs/11-ux.md §9）
 *
 * ★ 弱点を並べるだけの画面にしない。docs/04 §4.3 が
 *   「根拠を3件程度出す」と定めている。納得できない判定は使われなくなるうえ、
 *   **作者がアルゴリズムの誤りを見つける唯一の手段**でもある。
 */
export default async function Records() {
  const db = tryDb()
  const userId = await currentUserId()

  if (!db || !userId) {
    return (
      <Screen title="記録" tab="records">
        <NotReady />
      </Screen>
    )
  }

  const now = new Date()
  const [weak, s] = await Promise.all([weakKcs(db, userId, now), streak(db, userId, now)])

  const aside = (
    <>
      <span className="hs-side__label">続けた日数</span>
      <div className="lv-meta__row"><span className="lv-meta__key">連続</span><span>{s.current} 日</span></div>
      <div className="lv-meta__row"><span className="lv-meta__key">最長</span><span>{s.longest} 日</span></div>
      <div className="lv-meta__row"><span className="lv-meta__key">学習した日</span><span>{s.days} 日</span></div>
      {/* ★ 保護の残りを出す。黙って使われると「休んだのに続いている」が不可解になる。
           docs/11-ux.md §7.1 の「ストリーク保護を月2回まで自動適用する」 */}
      <div className="lv-meta__row">
        <span className="lv-meta__key">今月の保護</span><span>あと {s.protectionsLeft} 回</span>
      </div>
      <p className="lv-caption">
        1日か2日休んでも、月2回までは連続が切れません。数えるのは解いた日だけです。
      </p>
      <p className="lv-caption">
        弱点は「まだできていない項目」だけを弱い順に出しています。
        できるようになった項目は消えます。
      </p>
    </>
  )

  return (
    <Screen title="記録" tab="records" aside={aside}>
      <div className="hs-count">
        <span className="lv-display">{s.current}</span>
        <span className="lv-caption">日連続（最長 {s.longest} 日 / 学習した日 {s.days} 日）</span>
      </div>

      {weak.length === 0 ? (
        <Empty>
          <p className="lv-body">まだ弱点を出せるだけの解答がありません。</p>
          <p className="lv-caption">
            何問か解くと、ここに「なぜ弱点なのか」の根拠つきで並びます。
          </p>
        </Empty>
      ) : (
        <>
          <p className="lv-caption">
            弱い順に {weak.length} 件。なぜそう判定したかを各項目に添えています。
          </p>
          {weak.map(k => (
            <Card key={k.kcId}>
              <div className="lv-meta__row">
                <span className="lv-list__value">{k.label}</span>
                <StatusChip status={k.status} />
              </div>
              <MasteryBar value={k.mastery} />

              {k.evidence.length > 0 && (
                <>
                  <span className="lv-label">この弱点の根拠</span>
                  <ul className="hs-prose__list">
                    {k.evidence.map((e, i) => (
                      <li key={i} className="lv-caption">{e.text}</li>
                    ))}
                  </ul>
                </>
              )}

              {k.materialId && (
                <Link className="lv-btn" href={`/material/${k.materialId}`}>この項目の教材を読む</Link>
              )}
            </Card>
          ))}
        </>
      )}

      {/* ★ 設定への入口。タブは3つのままにする（docs/11 §9）ので、
           モバイルはここから入る。デスクトップはサイドバーにも出ている */}
      <Link className="lv-btn lv-btn--block" href="/settings">設定</Link>
    </Screen>
  )
}
