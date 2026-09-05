/**
 * 教科書 — 読める本文を国・地域ごとの時系列に並べる。
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

// 節の扱う範囲で分類する。個人版の KC の偏りで所属国が変わらないようにする。
// 複数国を扱う節は、無理に一国へ割り当てず地域・国際関係にまとめる。
const COUNTRY_UNITS: { id: string; label: string; units: string[] }[] = [
  { id: 'china', label: '中国', units: ['wh.2.3.1', 'wh.2.3.2', 'wh.3.2.1', 'wh.3.4.1'] },
  { id: 'japan', label: '日本', units: [
    'gh.2.3.1', 'gh.2.3.2', 'gh.2.4.1', 'gh.2.4.2', 'gh.3.2.1',
    'gh.3.3.2', 'gh.3.4.1', 'gh.3.4.2', 'gh.4.1.1', 'gh.4.1.2', 'gh.4.2.1', 'gh.4.2.2',
  ] },
  { id: 'east-asia', label: '東アジア', units: ['wh.2.3.3', 'wh.4.3.3'] },
  { id: 'india', label: 'インド', units: ['wh.2.2.1', 'wh.3.4.3', 'wh.4.3.2'] },
  { id: 'southeast-asia', label: '東南アジア', units: ['wh.2.2.2'] },
  { id: 'inner-asia', label: 'モンゴル・内陸アジア', units: ['wh.2.4.1', 'wh.3.2.2'] },
  { id: 'west-asia', label: '西アジア・イスラーム世界', units: [
    'wh.2.5.1', 'wh.2.5.2', 'wh.3.1.1', 'wh.3.4.2', 'wh.4.3.1',
  ] },
  { id: 'orient', label: '古代オリエント', units: ['wh.2.1.1'] },
  { id: 'greece', label: 'ギリシア', units: ['wh.2.1.2'] },
  { id: 'rome', label: 'ローマ', units: ['wh.2.1.3'] },
  { id: 'britain', label: 'イギリス', units: ['wh.4.1.1'] },
  { id: 'france', label: 'フランス', units: ['wh.4.1.3'] },
  { id: 'germany-italy', label: 'ドイツ・イタリア', units: ['wh.4.2.2'] },
  { id: 'russia', label: 'ロシア', units: ['wh.4.5.2'] },
  { id: 'europe', label: 'ヨーロッパ', units: [
    'wh.2.6.1', 'wh.2.6.2', 'wh.2.6.3', 'wh.3.3.1', 'wh.3.3.2', 'wh.3.3.3',
    'wh.3.6.1', 'wh.3.6.2', 'wh.3.6.3', 'wh.4.2.1',
  ] },
  { id: 'usa', label: 'アメリカ合衆国', units: ['wh.4.1.2'] },
  { id: 'atlantic', label: '欧米・大西洋世界', units: [
    'wh.3.5.2', 'wh.4.2.3', 'gh.2.1.2', 'gh.2.2.1', 'gh.2.2.2',
  ] },
  { id: 'asia-africa', label: 'アジア・アフリカ', units: [
    'wh.3.1.2', 'wh.4.4.2', 'wh.4.4.3', 'wh.5.1.2', 'gh.2.1.1',
  ] },
]

type TextbookRow = {
  material_id: string
  unit_id: string
  unit_label: string
  title: string
  year_from: number | null
}

export function groupTextbookArticles(rows: TextbookRow[]): TextbookChapter[] {
  const groups = new Map<string, TextbookChapter>()
  const sorted = [...rows].sort((a, b) =>
    (a.year_from ?? Infinity) - (b.year_from ?? Infinity)
    || a.unit_id.localeCompare(b.unit_id, 'en', { numeric: true })
    || a.material_id.localeCompare(b.material_id))

  for (const row of sorted) {
    const country = COUNTRY_UNITS.find(group => group.units.includes(row.unit_id))
      ?? { id: 'world', label: '世界・国際関係' }
    let group = groups.get(country.id)
    if (!group) {
      group = { id: country.id, label: country.label, articles: [] }
      groups.set(country.id, group)
    }
    group.articles.push({
      materialId: row.material_id, unitId: row.unit_id,
      unitLabel: row.unit_label, title: row.title,
    })
  }
  return [...COUNTRY_UNITS.map(country => country.id), 'world']
    .flatMap(id => groups.has(id) ? [groups.get(id)!] : [])
}

/**
 * 利用者が読める ready 教材を、国・地域ごとの年代順で返す。
 * 年代は節に紐づく KC の開始年。年代未登録の節は各グループの末尾に置く。
 *
 * 同じ節に個人版と共有版がある場合、弱点に合わせた個人版を優先する。
 * 他人の個別教材は題名すら返さない。
 */
export async function textbookChapters(db: Sql, userId: string): Promise<TextbookChapter[]> {
  const rows = await db<TextbookRow[]>`
    SELECT chosen.id AS material_id, unit.id AS unit_id,
           unit.label AS unit_label, chosen.title,
           (SELECT min(k.year_from)
              FROM kc_syllabus_unit ku JOIN kc k ON k.id = ku.kc_id
             WHERE ku.unit_id = unit.id AND NOT k.retired) AS year_from
      FROM syllabus_unit unit
      JOIN syllabus_unit chapter ON chapter.id = unit.parent_id AND chapter.level = 2
      JOIN LATERAL (
        SELECT m.id, m.title
          FROM material m
         WHERE m.unit_id = unit.id
           AND m.status = 'ready'
           AND (m.user_id = ${userId} OR m.user_id IS NULL)
         ORDER BY (m.user_id IS NULL), m.generated_at DESC, m.id
         LIMIT 1
      ) chosen ON true
     WHERE unit.level = 3`

  return groupTextbookArticles(rows)
}
