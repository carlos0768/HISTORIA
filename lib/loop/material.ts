/**
 * 教材の閲覧と読了記録
 *
 * 仕様: docs/07-content-pipeline.md §2、docs/11-ux.md §「読了判定」
 *
 * ★ 読了は「明示的なボタン」＋「滞在時間」の両方で判定する（docs/11）。
 *   足りない記録も material_read には残す。イベントは削らず、数えないだけである。
 * ★ blocked / failed の教材は本文を出さない。作者判断 Q4（ユニットごと配信しない）。
 */
import type { Sql } from 'postgres'
import { countsAsRead, requiredDwellMs, estimatedReadMs, CHARS_PER_MIN, READ_DWELL_RATIO }
  from '@/lib/domain/reading'

/**
 * 「学習イベントとして数える滞在時間」の SQL 側の式。
 * 定数を lib/domain/reading.ts から流し込むので、JS と SQL で閾値がずれない。
 * 相関名 s は material_section を指す前提である。
 */
export const requiredDwellExpr = (db: Sql) =>
  db`round(s.char_count::numeric / ${CHARS_PER_MIN} * 60000 * ${READ_DWELL_RATIO})`

export type MaterialStatus = 'generating' | 'ready' | 'blocked' | 'superseded' | 'failed'

export type SectionView = {
  id: string
  ord: number
  heading: string
  bodyMd: string
  charCount: number
  hidden: boolean
  hiddenReason: string | null
  kcLabels: string[]
  /** geo の KC が付いているセクションだけ、地図に出す地域の id を持つ */
  geoRegionIds: number[]
  /** 学習イベントとして数えられた読了があるか */
  read: boolean
  requiredMs: number
  estimatedMs: number
}

export type MaterialView = {
  id: string
  unitId: string
  unitLabel: string
  title: string
  status: MaterialStatus
  blockedReason: string | null
  generatedAt: Date
  /**
   * ★ 実際に使われたプロバイダ。鍵が無いと `fake:gemini` になる。
   *   これが無いと「鍵を入れ忘れて作ったでたらめな教材」を後から見分けられない。
   */
  provider: string | null
  sections: SectionView[]
  totalChars: number
  readCount: number
}

/**
 * 教材1本を読むために必要なものを1回で集める。
 * 自分の教材と共有教材（user_id IS NULL）だけを返す。
 * 他人の個別教材の id を打ち込んでも 404 になる。
 */
export async function materialView(db: Sql, userId: string, materialId: string): Promise<MaterialView | null> {
  const [m] = await db<{
    id: string; unit_id: string; unit_label: string; title: string
    status: MaterialStatus; blocked_reason: string | null; generated_at: Date
    provider: string | null
  }[]>`
    SELECT m.id, m.unit_id, u.label AS unit_label, m.title,
           m.status, m.blocked_reason, m.generated_at, m.provider
      FROM material m JOIN syllabus_unit u ON u.id = m.unit_id
     WHERE m.id = ${materialId} AND (m.user_id = ${userId} OR m.user_id IS NULL)`
  if (!m) return null

  // 配信しない教材の本文は取りに行かない。画面に渡らなければ漏れようがない
  if (m.status !== 'ready') {
    return {
      id: m.id, unitId: m.unit_id, unitLabel: m.unit_label, title: m.title,
      status: m.status, blockedReason: m.blocked_reason, generatedAt: m.generated_at,
      provider: m.provider, sections: [], totalChars: 0, readCount: 0,
    }
  }

  const rows = await db<{
    id: string; ord: number; heading: string; body_md: string; char_count: number
    hidden: boolean; hidden_reason: string | null; kc_labels: string[]
    geo_region_ids: number[]; read: boolean
  }[]>`
    SELECT s.id, s.ord, s.heading, s.body_md, s.char_count, s.hidden, s.hidden_reason,
           COALESCE(
             (SELECT array_agg(k.label ORDER BY k.id)
                FROM material_section_kc sk JOIN kc k ON k.id = sk.kc_id
               WHERE sk.section_id = s.id),
             ARRAY[]::text[]) AS kc_labels,
           -- 位置・版図の KC が付いているときだけ地図を出す。
           -- 全セクションに出すと地図が意味を失い、ただの飾りになる
           COALESCE(
             (SELECT array_agg(DISTINCT kr.region_id)
                FROM material_section_kc sk
                JOIN kc k ON k.id = sk.kc_id AND k.kind = 'geo'
                JOIN kc_region kr ON kr.kc_id = k.id
               WHERE sk.section_id = s.id),
             ARRAY[]::int[]) AS geo_region_ids,
           EXISTS (SELECT 1 FROM material_read r
                    WHERE r.section_id = s.id AND r.user_id = ${userId}
                      AND r.dwell_ms >= ${requiredDwellExpr(db)}) AS read
      FROM material_section s
     WHERE s.material_id = ${materialId}
     ORDER BY s.ord`

  const sections: SectionView[] = rows.map(r => ({
    id: r.id, ord: r.ord, heading: r.heading,
    // hidden なセクションは本文を渡さない（誤り報告・ファクトチェックで伏せたもの）
    bodyMd: r.hidden ? '' : r.body_md,
    charCount: r.char_count, hidden: r.hidden, hiddenReason: r.hidden_reason,
    kcLabels: r.kc_labels, geoRegionIds: r.geo_region_ids, read: r.read,
    requiredMs: requiredDwellMs(r.char_count), estimatedMs: estimatedReadMs(r.char_count),
  }))

  return {
    id: m.id, unitId: m.unit_id, unitLabel: m.unit_label, title: m.title,
    status: m.status, blockedReason: m.blocked_reason, generatedAt: m.generated_at,
    provider: m.provider,
    sections,
    totalChars: sections.reduce((n, s) => n + s.charCount, 0),
    readCount: sections.filter(s => s.read).length,
  }
}

export type ReadResult = { counted: boolean; requiredMs: number; readCount: number; total: number }

/**
 * 「読み終えた」を記録する。
 * 滞在時間が足りなくても行は残す。数えるかどうかは countsAsRead が決める。
 */
export async function recordRead(
  db: Sql,
  a: { userId: string; sectionId: string; dwellMs: number; scrollPct: number | null; now: Date },
): Promise<ReadResult> {
  const [s] = await db<{ char_count: number; material_id: string; hidden: boolean }[]>`
    SELECT s.char_count, s.material_id, s.hidden
      FROM material_section s JOIN material m ON m.id = s.material_id
     WHERE s.id = ${a.sectionId} AND m.status = 'ready'
       AND (m.user_id = ${a.userId} OR m.user_id IS NULL)`
  if (!s) throw new Error('セクションが見つかりません')
  if (s.hidden) throw new Error('このセクションは表示していません')

  // 負の滞在時間や桁違いの値を弾く。int の上限を超えると INSERT が落ちる
  const dwell = Math.max(0, Math.min(Math.round(a.dwellMs), 24 * 3600 * 1000))
  const scroll = a.scrollPct === null ? null : Math.max(0, Math.min(1, a.scrollPct))

  await db`
    INSERT INTO material_read (user_id, section_id, dwell_ms, scroll_pct, read_at)
    VALUES (${a.userId}, ${a.sectionId}, ${dwell}, ${scroll}, ${a.now})`

  const [n] = await db<{ read: string; total: string }[]>`
    SELECT count(*) FILTER (WHERE EXISTS (
             SELECT 1 FROM material_read r
              WHERE r.section_id = s.id AND r.user_id = ${a.userId}
                AND r.dwell_ms >= ${requiredDwellExpr(db)}
           )) AS read,
           count(*) AS total
      FROM material_section s WHERE s.material_id = ${s.material_id}`

  return {
    counted: countsAsRead(dwell, s.char_count),
    requiredMs: requiredDwellMs(s.char_count),
    readCount: Number(n?.read ?? 0),
    total: Number(n?.total ?? 0),
  }
}

export type UnitMaterial = {
  unitId: string
  unitLabel: string
  materialId: string | null
  status: MaterialStatus | 'none'
  blockedReason: string | null
  readCount: number
  sectionCount: number
}

/**
 * 特訓の範囲に対する教材の状態を一覧する。
 * 「生成中」「配信不可」を隠さずホームに出すために使う（docs/08 §5 層5）。
 */
export async function drillMaterials(db: Sql, userId: string, drillId: string): Promise<UnitMaterial[]> {
  const rows = await db<{
    unit_id: string; unit_label: string; material_id: string | null
    status: MaterialStatus | null; blocked_reason: string | null
    read_count: string; section_count: string
  }[]>`
    SELECT du.unit_id, u.label AS unit_label,
           m.id AS material_id, m.status, m.blocked_reason,
           COALESCE((SELECT count(*) FROM material_section s
                      WHERE s.material_id = m.id
                        AND EXISTS (SELECT 1 FROM material_read r
                                     WHERE r.section_id = s.id AND r.user_id = ${userId}
                                       AND r.dwell_ms >= ${requiredDwellExpr(db)})
                    ), 0) AS read_count,
           COALESCE((SELECT count(*) FROM material_section s WHERE s.material_id = m.id), 0) AS section_count
      FROM drill_unit du
      JOIN syllabus_unit u ON u.id = du.unit_id
      LEFT JOIN LATERAL (
        SELECT x.* FROM material x
         WHERE (x.user_id = ${userId} OR x.user_id IS NULL)
           AND x.unit_id = du.unit_id AND x.status <> 'superseded'
         -- 同じ単元に個別版と共有版があれば個別版を優先する。
         -- 個別版はその人の弱点に寄せて作り直したものだからである
         -- 同じ単元に複数あるときは「今いちばん意味のある1本」を選ぶ。
         -- 配信できるものが最優先、次に生成中、最後に止まっているもの
         ORDER BY CASE x.status WHEN 'ready' THEN 1 WHEN 'generating' THEN 2
                                WHEN 'blocked' THEN 3 ELSE 4 END,
                  (x.user_id IS NULL),
                  x.generated_at DESC
         LIMIT 1
      ) m ON true
     WHERE du.drill_id = ${drillId}
     ORDER BY du.unit_id`

  return rows.map(r => ({
    unitId: r.unit_id, unitLabel: r.unit_label, materialId: r.material_id,
    status: r.status ?? 'none', blockedReason: r.blocked_reason,
    readCount: Number(r.read_count), sectionCount: Number(r.section_count),
  }))
}
