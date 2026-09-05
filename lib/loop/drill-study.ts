import type { Sql } from 'postgres'

export type StudyDrill = {
  id: string
  title: string
}

export type DrillCard = {
  id: string
  front: string
  kcLabel: string
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
