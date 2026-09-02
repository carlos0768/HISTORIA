import Link from 'next/link'
import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { Screen, Empty } from '@/components/ui'
import { NotReady } from '@/components/not-ready'
import { nextQuestion } from '@/lib/loop/diagnostic'
import { MAX_ITEMS } from '@/lib/domain/diagnostic'
import { DiagnosticQuiz } from './quiz'

export const dynamic = 'force-dynamic'

/**
 * 適応的診断テスト（docs/04-weakness-engine.md §5）
 *
 * ★ これが閉路を断ち切る唯一の入口である（§5.1）。
 *   弱点は確認テストから生まれ、確認テストは特訓の中にあり、特訓の教材は
 *   弱点から作られる。新規ユーザーはこの環のどこからも起動できない。
 *
 * ★ 出題は共有プール（`item.user_id IS NULL`）だけ。生成待ちが無いのはここだけである（§5.2）。
 */
export default async function DiagnosticPage() {
  const db = tryDb()
  const userId = await currentUserId()

  if (!db || !userId) {
    return (
      <Screen title="診断テスト">
        <NotReady />
      </Screen>
    )
  }

  const { question, state } = await nextQuestion(db, userId)

  if (!question) {
    return (
      <Screen title="診断テスト">
        <Empty>
          {state.answered > 0 ? (
            <>
              <p className="lv-body">診断は終わっています。</p>
              <Link className="lv-btn" href="/diagnostic/result">結果を見る</Link>
            </>
          ) : (
            <>
              <p className="lv-body">まだ診断に使える設問がありません。</p>
              <p className="lv-caption">
                共有の設問プールが承認されるまで、診断は始められません。
                そのあいだも特訓と教材は使えます。
              </p>
              <Link className="lv-btn" href="/">ホームへ</Link>
            </>
          )}
        </Empty>
      </Screen>
    )
  }

  return (
    <Screen title="診断テスト">
      {state.answered === 0 && (
        <div className="lv-card">
          <div className="lv-card__pad hs-stack">
            <span className="lv-label">はじめに</span>
            <p className="lv-body">
              最大 {MAX_ITEMS} 問・10分ほどです。いまの得意不得意のあたりを付けるためのもので、
              点数は付きません。
            </p>
            <p className="lv-caption">
              分からない問題があって当たり前です。まだ習っていない範囲も混ざります。
            </p>
          </div>
        </div>
      )}
      <DiagnosticQuiz first={{
        itemId: question.itemId,
        stem: question.stem,
        choices: (question.choices as { key: string; text: string }[] | null) ?? [],
        index: question.index,
        total: question.total,
      }} />
    </Screen>
  )
}
