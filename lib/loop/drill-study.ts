import type { Sql } from 'postgres'
import { drillPracticeQueue } from './today'

export type StudyDrill = {
  id: string
  title: string
}

export type DrillCard = {
  id: string
  front: string
  kcLabel: string
}

export type DrillChoice = { key: string; text: string }

export type DrillQuizItem = {
  id: string
  stem: string
  choices: DrillChoice[]
  kcLabel: string
  /** SM-2 上の位置づけ。画面で「復習」「はじめて」を小さく出すためだけに使う */
  kind: 'review' | 'new' | 'ahead'
}

/** 自分が進行中の特訓だけを学習画面から開ける。 */
export async function studyDrill(db: Sql, userId: string, drillId: string): Promise<StudyDrill | null> {
  const [drill] = await db<StudyDrill[]>`
    SELECT id, title FROM drill
     WHERE id = ${drillId} AND user_id = ${userId} AND status = 'active'`
  return drill ?? null
}

/**
 * 特訓範囲に紐づくフラッシュカード。答えは Server Action で初めて返すため、
 * この一覧には問題文と表示用ラベルだけを含める。
 */
export async function drillCards(
  db: Sql,
  userId: string,
  drillId: string,
  limit = 24,
): Promise<DrillCard[]> {
  const rows = await db<{ id: string; stem: string; kc_labels: string[] }[]>`
    SELECT i.id, i.stem, array_agg(DISTINCT k.label ORDER BY k.label) AS kc_labels
      FROM drill d
      JOIN drill_kc dk ON dk.drill_id = d.id
      JOIN item_kc ik ON ik.kc_id = dk.kc_id
      JOIN item i ON i.id = ik.item_id
      JOIN kc k ON k.id = ik.kc_id
     WHERE d.id = ${drillId} AND d.user_id = ${userId} AND d.status = 'active'
       AND i.format = 'flashcard' AND i.approved AND NOT i.hidden
       AND (i.user_id = ${userId} OR i.user_id IS NULL)
     GROUP BY i.id, i.stem
     ORDER BY i.observed_total, i.created_at DESC, i.id
     LIMIT ${Math.max(1, Math.min(limit, 50))}`

  return rows.map(row => ({
    id: row.id,
    front: row.stem,
    kcLabel: row.kc_labels.join('・'),
  }))
}

/**
 * 特訓の四択（一問一答モード）。SM-2 の due 順に KC を並べ、KC ごとに設問を1つ選ぶ。
 *
 * ★ 順序は lib/domain/scheduler.ts の drillQueue が決める。ここでは並び替えない。
 * ★ answer_key / explanation / why_wrong はここで選ばない。クライアントに渡るのは
 *   stem と choices の key/text だけである（docs/12 §6.1）。
 * ★ 同じ KC でも観測数の少ない設問を先に使う。「今日やること」と同じ選び方。
 */
export async function drillQuizItems(
  db: Sql,
  userId: string,
  drillId: string,
  now: Date,
  limit = 24,
): Promise<DrillQuizItem[]> {
  const queue = await drillPracticeQueue(db, userId, drillId, now, Math.max(1, Math.min(limit, 50)))
  if (queue.length === 0) return []
  const kcIds = queue.map(c => c.kcId)

  const rows = await db<{ id: string; stem: string; choices: DrillChoice[] | null; kc_id: string }[]>`
    SELECT DISTINCT ON (ik.kc_id)
           i.id, i.stem, ik.kc_id,
           (SELECT jsonb_agg(jsonb_build_object('key', c->>'key', 'text', c->>'text')
                             ORDER BY c->>'key')
              FROM jsonb_array_elements(i.choices) c) AS choices
      FROM item i
      JOIN item_kc ik ON ik.item_id = i.id
     WHERE ik.kc_id IN ${db(kcIds)}
       AND i.format = 'mcq4' AND i.approved AND NOT i.hidden
       AND (i.user_id = ${userId} OR i.user_id IS NULL)
       AND i.choices IS NOT NULL
     ORDER BY ik.kc_id, i.observed_total ASC, i.created_at DESC, i.id`

  const byKc = new Map(rows.map(r => [r.kc_id, r]))
  const items: DrillQuizItem[] = []
  for (const c of queue) {
    const row = byKc.get(c.kcId)
    if (!row || !row.choices || row.choices.length === 0) continue
    items.push({
      id: row.id,
      stem: row.stem,
      choices: row.choices,
      kcLabel: c.label ?? c.kcId,
      kind: c.isNew ? 'new' : c.card.dueAt.getTime() <= now.getTime() ? 'review' : 'ahead',
    })
  }
  return items
}

/** 特訓のKCに紐づく地域を、地図へ渡せるIDだけで返す。 */
export async function drillRegionIds(db: Sql, userId: string, drillId: string): Promise<number[]> {
  const rows = await db<{ region_id: number }[]>`
    SELECT DISTINCT kr.region_id
      FROM drill d
      JOIN drill_kc dk ON dk.drill_id = d.id
      JOIN kc_region kr ON kr.kc_id = dk.kc_id
     WHERE d.id = ${drillId} AND d.user_id = ${userId} AND d.status = 'active'
     ORDER BY kr.region_id`
  return rows.map(row => row.region_id)
}
