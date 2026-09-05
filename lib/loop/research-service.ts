/**
 * 「調べる」の入口（docs/11-ux.md §4.1）
 *
 * 教材の中のパネル（Server Action）と専用ページ（/research）の両方がここを通る。
 * 入口を1つにしておかないと、「鍵が無いときの文言」や「上限」が2か所でずれる。
 *
 * ★ 検索語は**利用者が入れた語そのもの**を埋め込みの API へ送る。
 *   docs/08 §4.1 が自由入力を送らないとしているのは学習データの話で、
 *   ここは「範囲指定の自然文」と同じ例外である（同 §4.1 の但し書き）。
 *   それでも上限（QUERY_MAX_CHARS）と UUID の検査は通し、画面には送る旨を先に書く。
 *
 * ★ 意味で引けないときは語の一致だけで引き、**そう言う**。
 *   鍵が無い（フェイクの埋め込みは意味を持たない）／PGVECTOR=off／
 *   支出上限／埋め込みがまだ空、のどれでも検索そのものは止めない。
 *
 * ★ 個人の情報は返さない。kc と canon_event は全員が同じものを読む正典である。
 */
import type { Sql } from 'postgres'
import { createClient, type Client } from '@/lib/ai/client'
import { BudgetExceededError } from '@/lib/ai/budget'
import { assertNoIdentifiers } from '@/lib/ai/redact'
import { parseQuery, research, embedCoverage, type ResearchResponse } from './research'

export async function runResearch(
  db: Sql,
  rawQuery: string,
  opts: { userId?: string | null; client?: Client; now?: Date; pgvector?: boolean } = {},
): Promise<ResearchResponse> {
  const parsed = parseQuery(typeof rawQuery === 'string' ? rawQuery : '')
  if ('error' in parsed) return { ok: false, error: parsed.error }
  const { query } = parsed

  const now = opts.now ?? new Date()
  const client = opts.client ?? createClient()
  const pgvector = opts.pgvector ?? process.env.PGVECTOR !== 'off'
  let vector: number[] | null = null
  let note: string | null = null

  if (client.embedProviderName.startsWith('fake')) {
    note = 'AI の鍵が無いため、語の一致だけで引いています。'
  } else if (!pgvector) {
    note = 'このデータベースには pgvector が無いため、語の一致だけで引いています。'
  } else {
    try {
      assertNoIdentifiers(query)
    } catch {
      return { ok: false, error: '検索語に識別子（UUID）が含まれています。語だけを入れてください。' }
    }
    try {
      const out = await client.embed({ db, texts: [query], now })
      vector = out.vectors[0] ?? null
    } catch (e) {
      note = e instanceof BudgetExceededError
        ? '今月の AI 支出が上限に達しているため、語の一致だけで引いています。'
        : '意味の近さでは引けなかったため、語の一致だけで引いています。'
    }
  }

  const { sections, hits } = await research(db, { query, vector, userId: opts.userId ?? null })
  const mode = vector === null ? 'text' : 'hybrid'

  // ベクトルは作れたのに近傍が1件も無い＝索引がまだ空。黙って「語の一致だけ」の顔をしない
  if (mode === 'hybrid' && [...sections, ...hits].every(h => h.similarity === null)) {
    const c = await embedCoverage(db)
    if (c.kc.embedded === 0 && c.canonEvent.embedded === 0 && c.section.embedded === 0) {
      note = '埋め込みの索引がまだ作られていないため、語の一致だけで引けています（npm run db:embed-index）。'
    }
  }

  return { ok: true, query, mode, note, sections, hits }
}
