import Link from 'next/link'
import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { textbookChapters } from '@/lib/loop/textbook'
import { Screen, Empty } from '@/components/ui'
import { NotReady } from '@/components/not-ready'

export const dynamic = 'force-dynamic'

/** 国・地域ごとに、古い年代から文章を選んで読む教科書。 */
export default async function Textbook() {
  const db = tryDb()
  const userId = await currentUserId()

  if (!db || !userId) {
    return <Screen title="教科書" tab="textbook"><NotReady /></Screen>
  }

  const chapters = await textbookChapters(db, userId)

  return (
    <Screen title="教科書" tab="textbook">
      {chapters.length === 0 ? (
        <Empty>
          <p className="lv-body">まだ読める文章がありません。</p>
          <p className="lv-caption">特訓を作ると、完成した文章が国・地域ごとの年代順に並びます。</p>
        </Empty>
      ) : (
        <div className="hs-textbook">
          <p className="lv-caption">国・地域ごとに、古い年代から並んでいます。年代未登録の教材は各一覧の最後に表示します。</p>
          {chapters.map(chapter => (
            <section className="hs-textbook__chapter" key={chapter.id}>
              <h2 className="lv-heading">{chapter.label}</h2>
              <div className="lv-list">
                {chapter.articles.map(article => (
                  <Link className="lv-list__row hs-textbook__article"
                        href={`/material/${article.materialId}`} key={article.materialId}>
                    <span>
                      <span className="lv-list__value">{article.title}</span>
                      <span className="lv-caption">{article.unitLabel}</span>
                    </span>
                    <span aria-hidden="true">›</span>
                  </Link>
                ))}
              </div>
            </section>
          ))}
        </div>
      )}
    </Screen>
  )
}
