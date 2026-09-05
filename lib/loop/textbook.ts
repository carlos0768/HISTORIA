/**
 * 教科書 — 読める本文を章ごとに並べる。
 *
 * 一覧で本文や進捗まで展開しない。ここは章と文章の題名だけを見せ、
 * 本文は既存の教材ビューアで読む。
 */
import type { Sql } from 'postgres'

export type TextbookArticle = {
  materialId: string
  unitId: string
  unitLabel: string
  title: string
}

export type TextbookChapter = {
  id: string
  label: string
  articles: TextbookArticle[]
}

/**
 * 利用者が読める ready 教材を、教科書の章・節順で返す。
 *
 * 同じ節に個人版と共有版がある場合、弱点に合わせた個人版を優先する。
 * 他人の個別教材は題名すら返さない。
 */
export async function textbookChapters(db: Sql, userId: string): Promise<TextbookChapter[]> {
  const rows = await db<{
    chapter_id: string
    chapter_label: string
    material_id: string
    unit_id: string
    unit_label: string
    title: string
  }[]>`
    SELECT chapter.id AS chapter_id, chapter.label AS chapter_label,
           chosen.id AS material_id, unit.id AS unit_id,
           unit.label AS unit_label, chosen.title
      FROM syllabus_unit unit
      JOIN syllabus_unit chapter ON chapter.id = unit.parent_id AND chapter.level = 2
      JOIN LATERAL (
        SELECT m.id, m.title
          FROM material m
         WHERE m.unit_id = unit.id
           AND m.status = 'ready'
           AND (m.user_id = ${userId} OR m.user_id IS NULL)
         ORDER BY (m.user_id IS NULL), m.generated_at DESC
         LIMIT 1
      ) chosen ON true
     WHERE unit.level = 3
     ORDER BY unit.subject, chapter.ord, unit.ord`

  const chapters: TextbookChapter[] = []
  for (const row of rows) {
    let chapter = chapters.at(-1)
    if (!chapter || chapter.id !== row.chapter_id) {
      chapter = { id: row.chapter_id, label: row.chapter_label, articles: [] }
      chapters.push(chapter)
    }
    chapter.articles.push({
      materialId: row.material_id,
      unitId: row.unit_id,
      unitLabel: row.unit_label,
      title: row.title,
    })
  }
  return chapters
}
