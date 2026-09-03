/**
 * 年表（docs/06-desktop.md 画面B）
 *
 * ★ これは Phase5 の「歴史タイムライン」ではない。docs/11-ux.md:302 が
 *   「タイムラインは Phase2 に回った」としているのは、**学習機能としての**
 *   年表（自分の進捗を時代軸に重ねるもの）のことである。
 *   ここで作るのは、既に在る `canon_event` 1,180件を並べて地図と対照させる
 *   **デスクトップの閲覧画面**であり、新しいデータも新しい表も要らない。
 */
import type { Sql } from 'postgres'

export type TimelineEvent = {
  id: string
  label: string
  yearFrom: number
  yearTo: number | null
  precision: string
  regionIds: number[]
}

export const TIMELINE_LIMIT = 400

/** 年の見せ方。負値は紀元前（seed の year は負値で紀元前を表す） */
export function formatYear(year: number): string {
  return year < 0 ? `前${-year}` : String(year)
}

/** 出来事の年の範囲。1年で終わるものは1つだけ出す */
export function formatSpan(e: Pick<TimelineEvent, 'yearFrom' | 'yearTo'>): string {
  if (e.yearTo === null || e.yearTo === e.yearFrom) return formatYear(e.yearFrom)
  return `${formatYear(e.yearFrom)}–${formatYear(e.yearTo)}`
}

/**
 * 年表を引く。
 *
 * ★ 1,180件を全部渡さない。年の範囲か語で絞る。
 *   全部渡すと初回の転送が重くなるうえ、画面としても読めない。
 *
 * ★ 正典は全員が同じものを読む（RLS で SELECT が全員に開いている）。
 *   個人の情報が混ざらないので、絞り込みに user_id は要らない。
 */
export async function timeline(
  db: Sql,
  opts: { from?: number | null; to?: number | null; query?: string; regionId?: number | null } = {},
): Promise<TimelineEvent[]> {
  const q = opts.query?.trim() ?? ''
  // ★ LIKE のメタ文字を無効にする。`%` を打たれると全件一致になる
  const like = q ? `%${q.replace(/[\\%_]/g, c => `\\${c}`)}%` : null
  const from = opts.from ?? null
  const to = opts.to ?? null
  const regionId = opts.regionId ?? null

  const rows = await db<{
    id: string; label: string; year_from: number; year_to: number | null
    precision: string; region_ids: number[]
  }[]>`
    SELECT id, label, year_from, year_to, precision, region_ids
      FROM canon_event
     WHERE (${from}::int IS NULL OR coalesce(year_to, year_from) >= ${from})
       AND (${to}::int   IS NULL OR year_from <= ${to})
       AND (${like}::text IS NULL OR label ILIKE ${like} ESCAPE '\\'
            OR EXISTS (SELECT 1 FROM unnest(aliases) a WHERE a ILIKE ${like} ESCAPE '\\'))
       AND (${regionId}::smallint IS NULL OR ${regionId} = ANY(region_ids))
     ORDER BY year_from, id
     LIMIT ${TIMELINE_LIMIT}`

  return rows.map(r => ({
    id: r.id, label: r.label, yearFrom: r.year_from, yearTo: r.year_to,
    precision: r.precision, regionIds: r.region_ids,
  }))
}
