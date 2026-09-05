/**
 * 版図（国家）を意味で引く（docs/11-ux.md §4.1）
 *
 * 国家の名前（別名込み）を埋め込み、検索語のベクトルと cos 類似度で比べる。
 * 最も近い1つを主に、他の近いものを候補として返す。
 *
 * ★ 国家は lib/map/territories.ts の暫定マスタ（20件）で DB に無い。
 *   埋め込みは**プロセス内に一度だけ**作って使い回す（モデル名で鍵を付ける）。
 *   20件の短い名前なので、初回の1回だけ支出遮断器を通り、以後は往復も費用も無い。
 * ★ フェイクの埋め込みは意味を持たないので使わない。そのときは語の一致だけで引く。
 * ★ 閾値は実測で調整する前提の暫定値。gemini-embedding-001 の cos 類似度は
 *   無関係な語でも 0.4 前後になることがあるため、主は 0.55、候補は 0.5 から始める。
 */
import type { Sql } from 'postgres'
import type { Client } from '@/lib/ai/client'
import { POLITIES, findPolities, type Polity } from '@/lib/map/territories'

/** 主として出す最低の近さ（語の一致があれば閾値は見ない） */
export const POLITY_TOP_MIN = 0.55
/** 候補として並べる最低の近さ */
export const POLITY_CANDIDATE_MIN = 0.5
/** 候補の上限。主を含めて5つまで */
export const POLITY_CANDIDATES = 4

export type PolityMatch = { id: string; label: string; similarity: number | null; textMatch: boolean }

/** 埋め込みにかける文。別名も入れる（「トルコ」「東ローマ」は別名にしか無い） */
export function embedTextOfPolity(p: Polity): string {
  return p.aliases.length === 0 ? p.label : `${p.label}（${p.aliases.join('、')}）`
}

export function cosine(a: readonly number[], b: readonly number[]): number {
  let dot = 0, na = 0, nb = 0
  for (let i = 0; i < a.length && i < b.length; i++) {
    dot += a[i]! * b[i]!; na += a[i]! * a[i]!; nb += b[i]! * b[i]!
  }
  return na === 0 || nb === 0 ? 0 : dot / Math.sqrt(na * nb)
}

// モデル名 → 国家ごとのベクトル（POLITIES と同じ順）
const cache = new Map<string, Promise<number[][]>>()

/**
 * 国家のベクトル。初回だけ埋め込みを呼び、以後はプロセス内の写しを返す。
 * ★ 失敗したら写しを捨てる。失敗した Promise を残すと二度と直らない。
 */
export function polityVectors(db: Sql, client: Pick<Client, 'embed' | 'config'>, now: Date): Promise<number[][]> {
  const key = client.config.embedModel
  let p = cache.get(key)
  if (!p) {
    p = client.embed({ db, texts: POLITIES.map(embedTextOfPolity), now }).then(r => r.vectors)
    p.catch(() => cache.delete(key))
    cache.set(key, p)
  }
  return p
}

/** 試験用。プロセス内の写しを捨てる */
export function resetPolityVectors(): void { cache.clear() }

/**
 * 順位付け。語の一致 → 類似度の高い順。
 * ベクトルが無ければ語の一致だけ（findPolities の順）。
 */
export function rankPolities(
  query: string, queryVector: readonly number[] | null, vectors: readonly (readonly number[])[] | null,
): PolityMatch[] {
  const textIds = new Set(findPolities(query, POLITIES.length).map(p => p.id))
  const rows = POLITIES.map((p, i) => ({
    id: p.id, label: p.label,
    similarity: queryVector && vectors?.[i] ? cosine(queryVector, vectors[i]!) : null,
    textMatch: textIds.has(p.id),
  }))
  return rows
    .filter(r => r.textMatch || (r.similarity !== null && r.similarity >= POLITY_CANDIDATE_MIN))
    .sort((a, b) => {
      if (a.textMatch !== b.textMatch) return a.textMatch ? -1 : 1
      return (b.similarity ?? -1) - (a.similarity ?? -1)
    })
}

/**
 * 主と候補に分ける。主は語の一致か、近さが POLITY_TOP_MIN 以上のもの。
 * 主が無ければ候補も出さない（「何となく近い」だけの版図を主役にしない）。
 */
export function pickPolities(ranked: readonly PolityMatch[]): PolityMatch[] {
  const top = ranked[0]
  if (!top) return []
  if (!top.textMatch && (top.similarity === null || top.similarity < POLITY_TOP_MIN)) return []
  return [top, ...ranked.slice(1, 1 + POLITY_CANDIDATES)]
}
