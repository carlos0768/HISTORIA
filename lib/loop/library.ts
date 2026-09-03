/**
 * 教材の一覧（docs/06-desktop.md 画面A）
 *
 * ★ 集計とフィルタをここに置き、画面（app/library/page.tsx）には SQL を書かない。
 *   実 DB の試験から呼べるようにしておかないと、この画面だけ検証されないまま残る。
 */
import type { Sql } from 'postgres'

/** docs/schema.sql の material.status の CHECK と同じ */
export const MATERIAL_STATUSES = ['ready', 'generating', 'blocked', 'superseded', 'failed'] as const
export type MaterialStatus = typeof MATERIAL_STATUSES[number]

export type LibraryRow = {
  id: string
  unitId: string
  unitLabel: string
  chapterLabel: string | null
  title: string
  status: string
  chars: number
  sections: number
  readSections: number
  generatedAt: Date
}

export const LIBRARY_LIMIT = 300

/**
 * 自分が読める教材を一覧する。
 *
 * ★ 可視範囲は material と同じ規則（自分のもの＋共有）。
 *   ここを緩めると、他人の教材の題名が一覧から漏れる。
 *
 * ★ 伏せたセクションは字数にも読了にも数えない。
 *   伏せた本文は読めないので、分母に入れると永遠に読了しない。
 */
export async function materialLibrary(
  db: Sql, userId: string, opts: { query?: string; status?: string } = {},
): Promise<LibraryRow[]> {
  const q = opts.query?.trim() ?? ''
  // ★ 知らない状態は「絞らない」に落とす。CHECK 外の値を SQL へ渡さない
  const status = MATERIAL_STATUSES.includes(opts.status as MaterialStatus) ? opts.status! : null
  // ★ LIKE のメタ文字を無効にする。`%` を打たれると全件一致になる（絞れなくなる）
  const like = q ? `%${q.replace(/[\\%_]/g, c => `\\${c}`)}%` : null

  const rows = await db<{
    id: string; unit_id: string; unit_label: string; chapter_label: string | null
    title: string; status: string; chars: string; sections: string
    read_sections: string; generated_at: Date
  }[]>`
    SELECT m.id, m.unit_id, u.label AS unit_label, p.label AS chapter_label,
           m.title, m.status, m.generated_at,
           coalesce(sum(s.char_count), 0) AS chars,
           count(s.id) AS sections,
           count(s.id) FILTER (WHERE r.section_id IS NOT NULL) AS read_sections
      FROM material m
      JOIN syllabus_unit u ON u.id = m.unit_id
      LEFT JOIN syllabus_unit p ON p.id = u.parent_id
      LEFT JOIN material_section s ON s.material_id = m.id AND NOT s.hidden
      LEFT JOIN material_read r ON r.section_id = s.id AND r.user_id = ${userId}
     WHERE (m.user_id = ${userId} OR m.user_id IS NULL)
       AND (${status}::text IS NULL OR m.status = ${status})
       AND (${like}::text IS NULL
            OR m.title ILIKE ${like} ESCAPE '\\'
            OR u.label ILIKE ${like} ESCAPE '\\'
            OR p.label ILIKE ${like} ESCAPE '\\')
     GROUP BY m.id, u.label, p.label
     ORDER BY m.generated_at DESC
     LIMIT ${LIBRARY_LIMIT}`

  return rows.map(r => ({
    id: String(r.id), unitId: r.unit_id, unitLabel: r.unit_label,
    chapterLabel: r.chapter_label, title: r.title, status: r.status,
    chars: Number(r.chars), sections: Number(r.sections),
    readSections: Number(r.read_sections), generatedAt: r.generated_at,
  }))
}
