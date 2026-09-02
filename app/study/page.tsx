import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { todaysPlan } from '@/lib/loop/today'
import { Screen, Empty } from '@/components/ui'
import { Quiz, type QuizItem } from './quiz'
import { DEFAULT_MAX_DAILY } from '@/lib/domain/scheduler'

export const dynamic = 'force-dynamic'

export default async function Study() {
  const db = tryDb()
  const userId = await currentUserId()
  if (!db || !userId) {
    return (
      <Screen title="今日やること" tab="home">
        <Empty><p className="lv-body">データベースに接続していません。</p></Empty>
      </Screen>
    )
  }

  const now = new Date()
  const plan = await todaysPlan(db, userId, now, DEFAULT_MAX_DAILY)
  const kcIds = plan.queue.map(q => q.kcId)

  // ★ answer_key / explanation / why_wrong はここで選ばない。
  //   クライアントに渡るのは stem と choices の key/text だけである（docs/12 §6.1）。
  const rows = kcIds.length
    ? await db<{ id: string; stem: string; choices: { key: string; text: string }[] | null; kc_label: string }[]>`
        SELECT DISTINCT ON (ik.kc_id)
               i.id, i.stem,
               (SELECT jsonb_agg(jsonb_build_object('key', c->>'key', 'text', c->>'text')
                                 ORDER BY c->>'key')
                  FROM jsonb_array_elements(i.choices) c) AS choices,
               k.label AS kc_label
          FROM item i
          JOIN item_kc ik ON ik.item_id = i.id
          JOIN kc k ON k.id = ik.kc_id
         WHERE ik.kc_id IN ${db(kcIds)}
           AND i.approved AND NOT i.hidden
           AND (i.user_id = ${userId} OR i.user_id IS NULL)
         ORDER BY ik.kc_id, i.observed_total ASC, i.created_at DESC`
    : []

  const items: QuizItem[] = rows
    .filter(r => r.choices && r.choices.length > 0)
    .map(r => ({ id: r.id, stem: r.stem, choices: r.choices!, kcLabel: r.kc_label }))

  return (
    <Screen title="今日やること" tab="home">
      {items.length === 0 ? (
        <Empty>
          <p className="lv-body">出題できる設問がまだありません。</p>
          <p className="lv-caption">教材を生成すると設問も作られます。</p>
        </Empty>
      ) : (
        <Quiz items={items} />
      )}
    </Screen>
  )
}
