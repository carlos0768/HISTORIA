import Link from 'next/link'
import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { Screen, Card } from '@/components/ui'
import { NotReady } from '@/components/not-ready'
import { ResearchResults } from '@/components/research-results'
import { runResearch } from '@/lib/loop/research-service'
import { QUERY_MAX_CHARS } from '@/lib/loop/research'

export const dynamic = 'force-dynamic'

/** 最初に押せる語。空の画面に「何を入れればよいか」を示す */
const EXAMPLES = ['アッバース朝', 'ハンムラビ法典', '宗教改革', 'アヘン戦争', '冷戦'] as const

/**
 * 調べる（docs/11-ux.md §4.1）
 *
 * ★ 教材の中のパネルと同じ検索を、教材から離れて自由に使う場所。
 *   引く先（KC と正典）も引き方（語の一致＋近傍）も同じで、入口は
 *   lib/loop/research-service.ts の1つである。ここで別の検索を作らない。
 *
 * ★ 検索語は URL で持つ（`?q=`）。結果をそのまま人に渡せるし、戻るボタンが効く。
 *   教材のパネルからも「専用ページで調べる」でここへ飛べる。
 *
 * ★ 検索はサーバーで行う（Server Component）。埋め込みの API 呼び出しと
 *   支出遮断器はサーバーにしか無い。地図と年表の連動だけがクライアントである。
 */
export default async function Research({
  searchParams,
}: {
  searchParams: Promise<{ q?: string }>
}) {
  const db = tryDb()
  const userId = await currentUserId()
  const { q = '' } = await searchParams

  if (!db || !userId) {
    return <Screen title="調べる" tab="research"><NotReady /></Screen>
  }

  const result = q.trim() === '' ? null : await runResearch(db, q, { userId })

  return (
    <Screen title="調べる" tab="research">
      <Card>
        <span className="lv-label">語を入れて調べる</span>
        <form className="hs-report__row" method="get">
          <input className="lv-input" type="search" name="q" defaultValue={q}
                 maxLength={QUERY_MAX_CHARS}
                 placeholder="例: アッバース朝" aria-label="調べたい語" autoFocus />
          <button type="submit" className="lv-btn lv-btn--primary">調べる</button>
        </form>
        <p className="lv-caption">
          教科書（生成した教材の本文）から該当する節を引き、関連する出来事と知識項目（KC）も並べて、
          地域を地図に、年代を年表に置きます。
          意味の近い項目を引くため、入れた語だけを Google（Gemini API）へ送ります。
          氏名などの個人の情報は入れないでください。
        </p>
        {result === null && (
          <div className="lv-chips">
            {EXAMPLES.map(e => (
              <Link key={e} className="lv-chip" href={`/research?q=${encodeURIComponent(e)}`}>{e}</Link>
            ))}
          </div>
        )}
      </Card>

      {result && (
        <div className="hs-research">
          <ResearchResults key={q} result={result} />
        </div>
      )}
    </Screen>
  )
}
