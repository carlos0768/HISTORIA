/**
 * 教材の中の「調べる」（docs/11-ux.md §4.1）
 *
 * 語を、**教科書（生成した教材の節）**と KC・正典（canon_event）から引く。
 * 参照元の主役は教材の節で、KC と正典はその理解を助ける関連である。
 * 当たったものは **年代**（year_from / year_to）と **地域**（region_ids）を
 * 持ち帰り、画面が年表と地図に置く。節の年代と地域は、節に付いた KC から取る。
 *
 * ★ 語の一致（ILIKE）と近傍検索（pgvector の `<=>`）を**両方**使う。
 *   語だけだと「ウマイヤ朝」で「アッバース朝」が出ない（対になる語が引けない）。
 *   近傍だけだと、綴りが完全に一致する行が類似度の順で後ろに落ちることがある。
 *   よって **語の一致を先に、近傍を後に**並べる。どちらで当たったかは隠さない
 *   （`textMatch` / `similarity` を持ち帰る）。
 *
 * ★ ベクトルが無いときは語の一致だけで動く。
 *   鍵が無い（フェイクの埋め込みは意味を持たない）／PGVECTOR=off／
 *   埋め込み列がまだ空、のどれでも**検索が止まらない**ようにする。
 *   その代わり、画面には「語の一致だけ」と出す（app/material/[id]/actions.ts）。
 *
 * ★ 個人の情報は一切混ざらない。kc と canon_event は全員が同じものを読む
 *   （RLS で SELECT が全員に開いている）。user_id はここに要らない。
 */
import type { Sql } from 'postgres'
import type { Client } from '@/lib/ai/client'
import { EMBED_DIMENSIONS } from '@/lib/ai/gemini'

export type HitKind = 'kc' | 'event' | 'section'

export type ResearchHit = {
  kind: HitKind
  id: string
  label: string
  /** KC の種別（fact / distinction / causal / chronology / geo）。出来事には無い */
  kcKind: string | null
  /** KC が属する教科書の節。出来事には無い */
  unitLabels: string[]
  /** 負値は紀元前。無ければ年表には置かない */
  yearFrom: number | null
  yearTo: number | null
  precision: string | null
  /** seed/region.csv の id。先頭が主地域。空なら地図には置かない */
  regionIds: number[]
  /** 語の一致で当たったか */
  textMatch: boolean
  /** cos 類似度（1 に近いほど近い）。ベクトル検索をしていなければ null */
  similarity: number | null
  /**
   * 教材の節（kind = 'section'）だけが持つ。年代と地域は節に付いた KC から取る
   * （年代は KC の最小〜最大、地域は主地域を先頭にした和集合）。
   */
  section?: {
    materialId: string
    ord: number
    materialTitle: string
    unitLabel: string
    /** 一致した箇所の前後、または本文の先頭。記法は落としてある */
    snippet: string
  }
}

/**
 * Server Action が画面に返す形。
 * ★ どうやって引いたか（`mode`）と、引けなかった理由（`note`）を隠さない。
 *   鍵が無いときや埋め込みが空のときに「意味で引けた」顔をしない。
 */
export type ResearchResponse =
  | {
      ok: true; query: string; mode: 'hybrid' | 'text'; note: string | null
      /** 教科書（教材）の節。参照元はこちらが主役 */
      sections: ResearchHit[]
      /** 出来事（正典）と知識項目（KC）。節の理解を助ける関連 */
      hits: ResearchHit[]
    }
  | { ok: false; error: string }

/** 1回に返す件数（出来事と KC）。年表と地図に置いて読める上限 */
export const RESEARCH_LIMIT = 12
/** 1回に返す教材の節の件数。1節は読むのに数分かかるので、出来事より少なくする */
export const SECTION_LIMIT = 8
/** 埋め込みにかける本文の長さ。埋め込みモデルの入力上限（2,048 トークン）に収める */
export const SECTION_EMBED_CHARS = 1500
/** 検索語の上限。歴史用語は長くても20字程度。長文を貼れないようにする（docs/08 §4.1） */
export const QUERY_MAX_CHARS = 60
export { EMBED_DIMENSIONS }

/**
 * 検索語を整える。空や長すぎるものは理由を返す。
 * ★ 例外にしない。画面がそのまま出せる文にする。
 */
export function parseQuery(raw: string): { query: string } | { error: string } {
  const query = raw.replace(/\s+/g, ' ').trim()
  if (query === '') return { error: '調べたい語を入れてください。' }
  if (query.length > QUERY_MAX_CHARS) {
    return { error: `検索語は ${QUERY_MAX_CHARS} 字までです（いま ${query.length} 字）。` }
  }
  return { query }
}

/** LIKE のメタ文字を無効にする。`%` を打たれると全件一致になる */
export const likePattern = (q: string): string =>
  `%${q.replace(/[\\%_]/g, c => `\\${c}`)}%`

/**
 * pgvector の入力形式（`[0.1,0.2,…]`）。JSON の配列表記と同じ。
 * ★ 次元を検査する。768 以外を `::vector` に通すと DB 側で落ちるが、
 *   その文面（"expected 768 dimensions"）からは呼び出し元が分からない。
 */
export function toVectorLiteral(vec: readonly number[]): string {
  if (vec.length !== EMBED_DIMENSIONS) {
    throw new Error(`埋め込みの次元が ${vec.length} です（${EMBED_DIMENSIONS} が必要）`)
  }
  for (const n of vec) {
    if (!Number.isFinite(n)) throw new Error('埋め込みに数値でない要素があります')
  }
  return `[${vec.join(',')}]`
}

type Row = {
  id: string; label: string; kc_kind: string | null; unit_labels: string[] | null
  year_from: number | null; year_to: number | null; precision: string | null
  region_ids: number[]; text_match: boolean; similarity: number | null
}

/**
 * 並び順。語の一致 → 類似度の高い順 → 年代順。
 * ★ 類似度が無い（null）ものは後ろ。並べ替えに使う基準が無いのだから前には出せない。
 */
export function rankHits(hits: readonly ResearchHit[]): ResearchHit[] {
  return [...hits].sort((a, b) => {
    if (a.textMatch !== b.textMatch) return a.textMatch ? -1 : 1
    const sa = a.similarity ?? -Infinity, sb = b.similarity ?? -Infinity
    if (sa !== sb) return sb - sa
    const ya = a.yearFrom ?? Infinity, yb = b.yearFrom ?? Infinity
    if (ya !== yb) return ya - yb
    return a.label.localeCompare(b.label, 'ja')
  })
}

/** Markdown の記法（見出し・強調・箇条書き）を落として素の文にする */
export function plainText(md: string): string {
  return md
    .replace(/^#{1,6}\s+/gm, '')
    .replace(/\*\*([^*]+)\*\*/g, '$1')
    .replace(/^\s*[-*]\s+/gm, '')
    .replace(/\s+/g, ' ')
    .trim()
}

/**
 * 一致した箇所の前後を切り出す。語が本文に無ければ（見出しで当たった・近傍で当たった）先頭を出す。
 */
export function snippetOf(body: string, query: string, opts: { before?: number; after?: number } = {}): string {
  const text = plainText(body)
  const before = opts.before ?? 30, after = opts.after ?? 90
  const at = query === '' ? -1 : text.toLowerCase().indexOf(query.toLowerCase())
  if (at < 0) return text.length > before + after ? `${text.slice(0, before + after)}…` : text
  const start = Math.max(0, at - before)
  const end = Math.min(text.length, at + query.length + after)
  return `${start > 0 ? '…' : ''}${text.slice(start, end)}${end < text.length ? '…' : ''}`
}

export type ResearchResult = { sections: ResearchHit[]; hits: ResearchHit[] }

/**
 * 教材の節と、KC・正典を引く。
 *
 * @param vector 検索語の埋め込み。null なら語の一致だけで引く
 * @param userId 節は「共有の教材」と「その人の教材」だけを出す。null なら共有だけ
 */
export async function research(
  db: Sql,
  opts: {
    query: string; vector: readonly number[] | null
    userId?: string | null; limit?: number; sectionLimit?: number
  },
): Promise<ResearchResult> {
  const parsed = parseQuery(opts.query)
  if ('error' in parsed) return { sections: [], hits: [] }
  const limit = Math.max(1, Math.min(opts.limit ?? RESEARCH_LIMIT, 50))
  const sectionLimit = Math.max(0, Math.min(opts.sectionLimit ?? SECTION_LIMIT, 50))
  const userId = opts.userId ?? null
  const like = likePattern(parsed.query)
  const vec = opts.vector === null ? null : toVectorLiteral(opts.vector)

  // ★ `<=>` は pgvector が無いと**構文の時点で**落ちる（演算子が存在しない）。
  //   CASE で避けても解析は通らないので、ベクトルの有無で文そのものを分ける。
  const kcSim = vec === null ? db`NULL::real` : db`(1 - (k.embedding <=> ${vec}::vector))::real`
  const kcWhere = vec === null ? db`false` : db`k.embedding IS NOT NULL`
  const kcRows = await db<Row[]>`
    SELECT k.id, k.label, k.kind AS kc_kind,
           (SELECT array_agg(u.label ORDER BY u.id)
              FROM kc_syllabus_unit ku JOIN syllabus_unit u ON u.id = ku.unit_id
             WHERE ku.kc_id = k.id) AS unit_labels,
           k.year_from, k.year_to, k.year_precision AS precision,
           COALESCE((SELECT array_agg(kr.region_id ORDER BY kr.is_primary DESC, kr.region_id)
                       FROM kc_region kr WHERE kr.kc_id = k.id), '{}') AS region_ids,
           (k.label ILIKE ${like} ESCAPE '\\') AS text_match,
           ${kcSim} AS similarity
      FROM kc k
     WHERE NOT k.retired
       AND (k.label ILIKE ${like} ESCAPE '\\' OR ${kcWhere})
     ORDER BY text_match DESC, similarity DESC NULLS LAST, k.year_from NULLS LAST, k.id
     LIMIT ${limit}`

  const evSim = vec === null ? db`NULL::real` : db`(1 - (e.embedding <=> ${vec}::vector))::real`
  const evWhere = vec === null ? db`false` : db`e.embedding IS NOT NULL`
  const evRows = await db<Row[]>`
    SELECT e.id, e.label, NULL::text AS kc_kind, NULL::text[] AS unit_labels,
           e.year_from, e.year_to, e.precision,
           e.region_ids::int[] AS region_ids,
           (e.label ILIKE ${like} ESCAPE '\\'
            OR EXISTS (SELECT 1 FROM unnest(e.aliases) a WHERE a ILIKE ${like} ESCAPE '\\')) AS text_match,
           ${evSim} AS similarity
      FROM canon_event e
     WHERE (e.label ILIKE ${like} ESCAPE '\\'
            OR EXISTS (SELECT 1 FROM unnest(e.aliases) a WHERE a ILIKE ${like} ESCAPE '\\')
            OR ${evWhere})
     ORDER BY text_match DESC, similarity DESC NULLS LAST, e.year_from, e.id
     LIMIT ${limit}`

  const toHit = (kind: HitKind) => (r: Row): ResearchHit => ({
    kind, id: r.id, label: r.label, kcKind: r.kc_kind, unitLabels: r.unit_labels ?? [],
    yearFrom: r.year_from, yearTo: r.year_to, precision: r.precision,
    regionIds: r.region_ids, textMatch: r.text_match,
    similarity: r.similarity === null ? null : Number(r.similarity),
  })
  const hits = rankHits([...kcRows.map(toHit('kc')), ...evRows.map(toHit('event'))]).slice(0, limit)

  // ★ 教材の節。配信中（ready）で伏せていない節だけ。他人の個別教材は出さない
  //   （materialView と同じ境界。ここを緩めると本文が検索経由で漏れる）。
  const secSim = vec === null ? db`NULL::real` : db`(1 - (s.embedding <=> ${vec}::vector))::real`
  const secWhere = vec === null ? db`false` : db`s.embedding IS NOT NULL`
  const secRows = sectionLimit === 0 ? [] : await db<{
    id: string; heading: string; body_md: string; ord: number
    material_id: string; material_title: string; unit_label: string
    year_from: number | null; year_to: number | null; region_ids: number[]
    text_match: boolean; similarity: number | null
  }[]>`
    SELECT s.id, s.heading, s.body_md, s.ord,
           m.id AS material_id, m.title AS material_title, u.label AS unit_label,
           (SELECT min(k.year_from) FROM material_section_kc sk JOIN kc k ON k.id = sk.kc_id
             WHERE sk.section_id = s.id) AS year_from,
           (SELECT max(coalesce(k.year_to, k.year_from)) FROM material_section_kc sk JOIN kc k ON k.id = sk.kc_id
             WHERE sk.section_id = s.id) AS year_to,
           COALESCE((SELECT array_agg(t.region_id ORDER BY t.prim DESC, t.region_id)
                       FROM (SELECT kr.region_id, bool_or(kr.is_primary) AS prim
                               FROM material_section_kc sk JOIN kc_region kr ON kr.kc_id = sk.kc_id
                              WHERE sk.section_id = s.id GROUP BY kr.region_id) t), '{}') AS region_ids,
           (s.heading ILIKE ${like} ESCAPE '\\' OR s.body_md ILIKE ${like} ESCAPE '\\') AS text_match,
           ${secSim} AS similarity
      FROM material_section s
      JOIN material m ON m.id = s.material_id
      JOIN syllabus_unit u ON u.id = m.unit_id
     WHERE m.status = 'ready' AND NOT s.hidden
       AND (m.user_id IS NULL OR m.user_id = ${userId}::uuid)
       AND (s.heading ILIKE ${like} ESCAPE '\\' OR s.body_md ILIKE ${like} ESCAPE '\\' OR ${secWhere})
     ORDER BY text_match DESC, similarity DESC NULLS LAST, m.generated_at DESC, s.ord
     LIMIT ${sectionLimit}`

  const sections = rankHits(secRows.map((r): ResearchHit => ({
    kind: 'section', id: r.id, label: r.heading, kcKind: null, unitLabels: [r.unit_label],
    yearFrom: r.year_from, yearTo: r.year_to, precision: null,
    regionIds: r.region_ids, textMatch: r.text_match,
    similarity: r.similarity === null ? null : Number(r.similarity),
    section: {
      materialId: r.material_id, ord: r.ord, materialTitle: r.material_title, unitLabel: r.unit_label,
      snippet: snippetOf(r.body_md, parsed.query),
    },
  })))

  return { sections, hits }
}

/**
 * 埋め込みにかける文。
 * ★ 別名も入れる。「フビライ／クビライ」のような表記ゆれは別名にしか無い。
 */
export function embedTextOfKc(k: { label: string; kind: string }): string {
  return k.label
}
export function embedTextOfEvent(e: { label: string; aliases: readonly string[] }): string {
  return e.aliases.length === 0 ? e.label : `${e.label}（${e.aliases.join('、')}）`
}
/** 節は見出し＋本文の先頭。長い本文は入力上限に収まるよう切る */
export function embedTextOfSection(s: { heading: string; bodyMd: string }): string {
  return `${s.heading}\n${plainText(s.bodyMd)}`.slice(0, SECTION_EMBED_CHARS)
}

/** 1回の呼び出しで送る件数。Gemini の batchEmbedContents は 100 件まで */
export const EMBED_BATCH = 64

export type EmbedIndexResult = { kc: number; canonEvent: number; section: number; model: string | null }

/**
 * 埋め込みが空の行を埋める。
 *
 * ★ 何度流しても同じ。埋まっている行には触れない（NULL の行だけを引く）。
 *   モデルを替えたときは列を NULL に戻してから流す（次元は同じ 768 のまま）。
 * ★ フェイクのクライアントを通すかどうかは呼び出し側が決める。
 *   scripts/db/embed-index.ts は鍵が無ければ拒む。ここでは拒まない
 *   （試験はフェイクで書き込みの経路を確かめる）。
 */
export async function embedMissing(
  db: Sql,
  client: Pick<Client, 'embed'>,
  opts: { now: Date; batch?: number; onProgress?: (done: number, table: string) => void } = { now: new Date() },
): Promise<EmbedIndexResult> {
  const batch = Math.max(1, Math.min(opts.batch ?? EMBED_BATCH, 100))
  let model: string | null = null

  const fill = async (
    table: 'kc' | 'canon_event' | 'material_section',
    pick: () => Promise<Array<{ id: string; text: string }>>,
  ): Promise<number> => {
    let done = 0
    for (;;) {
      const rows = await pick()
      if (rows.length === 0) return done
      const out = await client.embed({ db, texts: rows.map(r => r.text), now: opts.now })
      model = out.model
      const ids = rows.map(r => r.id)
      const lits = out.vectors.map(toVectorLiteral)
      // ★ 1文で書く。1,000件を1行ずつ UPDATE すると往復が1,000回になる
      // ★ id は kc / canon_event が text、material_section が uuid。text に寄せて比べる
      await db`
        UPDATE ${db(table)} t SET embedding = v.e::vector
          FROM unnest(${ids}::text[], ${lits}::text[]) AS v(id, e)
         WHERE t.id::text = v.id`
      done += rows.length
      opts.onProgress?.(done, table)
    }
  }

  const kc = await fill('kc', async () =>
    (await db<{ id: string; label: string; kind: string }[]>`
      SELECT id, label, kind FROM kc
       WHERE embedding IS NULL AND NOT retired ORDER BY id LIMIT ${batch}`)
      .map(r => ({ id: r.id, text: embedTextOfKc(r) })))

  const canonEvent = await fill('canon_event', async () =>
    (await db<{ id: string; label: string; aliases: string[] }[]>`
      SELECT id, label, aliases FROM canon_event
       WHERE embedding IS NULL ORDER BY id LIMIT ${batch}`)
      .map(r => ({ id: r.id, text: embedTextOfEvent(r) })))

  // ★ 節は配信中で伏せていないものだけ。伏せた節を埋め込むと近傍で顔を出す
  const section = await fill('material_section', async () =>
    (await db<{ id: string; heading: string; body_md: string }[]>`
      SELECT s.id, s.heading, s.body_md
        FROM material_section s JOIN material m ON m.id = s.material_id
       WHERE s.embedding IS NULL AND NOT s.hidden AND m.status = 'ready'
       ORDER BY s.id LIMIT ${batch}`)
      .map(r => ({ id: r.id, text: embedTextOfSection({ heading: r.heading, bodyMd: r.body_md }) })))

  return { kc, canonEvent, section, model }
}

/** 埋め込みの充足率。「まだ空」を画面と CLI が正直に言うために使う */
export async function embedCoverage(db: Sql): Promise<{
  kc: { total: number; embedded: number }
  canonEvent: { total: number; embedded: number }
  /** 配信中で伏せていない節 */
  section: { total: number; embedded: number }
}> {
  const [r] = await db<{ kt: string; ke: string; et: string; ee: string; st: string; se: string }[]>`
    SELECT (SELECT count(*) FROM kc WHERE NOT retired) AS kt,
           (SELECT count(*) FROM kc WHERE NOT retired AND embedding IS NOT NULL) AS ke,
           (SELECT count(*) FROM canon_event) AS et,
           (SELECT count(*) FROM canon_event WHERE embedding IS NOT NULL) AS ee,
           (SELECT count(*) FROM material_section s JOIN material m ON m.id = s.material_id
             WHERE NOT s.hidden AND m.status = 'ready') AS st,
           (SELECT count(*) FROM material_section s JOIN material m ON m.id = s.material_id
             WHERE NOT s.hidden AND m.status = 'ready' AND s.embedding IS NOT NULL) AS se`
  return {
    kc: { total: Number(r!.kt), embedded: Number(r!.ke) },
    canonEvent: { total: Number(r!.et), embedded: Number(r!.ee) },
    section: { total: Number(r!.st), embedded: Number(r!.se) },
  }
}
