/**
 * 本文にリンクを埋めるための語彙（docs/11-ux.md §4.2）
 *
 * 層2の正典 `person` と `canon_event` の label と aliases を読み、
 * lib/domain/term-link.ts の「本文を切る道具」を作る。
 *
 * ★ 正典は全員が同じものを読む（RLS で SELECT が全員に開いている）。user_id は要らない。
 * ★ 約1,600行・2,000表記を教材ページのたびに引くのは無駄なので、**プロセス内に一度だけ**
 *   読んで使い回す（lib/loop/territory-search.ts と同じ作法）。正典は seed の投入でしか
 *   変わらないので、写しが古くなるのは投入の直後だけである。それでも
 *   TERMS_TTL_MS を過ぎたら読み直し、デプロイを跨がずに追いつく。
 * ★ 失敗した Promise は写しに残さない。残すと二度と直らない。
 */
import type { Sql } from 'postgres'
import { createLinker, type Linker, type Term } from '@/lib/domain/term-link'

/** 写しを持つ時間。正典の投入直後でも、これだけ待てば新しい語が本文に効く */
export const TERMS_TTL_MS = 10 * 60 * 1000

let cache: { at: number; linker: Promise<Linker> } | null = null

/** 正典を読む。人物を先に並べる（同じ表記が人物にも出来事にもあるとき、人物を採るため） */
export async function loadTerms(db: Sql): Promise<Term[]> {
  const [persons, events] = await Promise.all([
    db<{ label: string; aliases: string[] }[]>`SELECT label, aliases FROM person ORDER BY id`,
    db<{ label: string; aliases: string[] }[]>`SELECT label, aliases FROM canon_event ORDER BY id`,
  ])
  return [
    ...persons.map(r => ({ kind: 'person' as const, label: r.label, aliases: r.aliases })),
    ...events.map(r => ({ kind: 'event' as const, label: r.label, aliases: r.aliases })),
  ]
}

/** 本文を切る道具。初回だけ DB を読み、以後はプロセス内の写しを返す */
export function termLinker(db: Sql, now = Date.now()): Promise<Linker> {
  if (cache && now - cache.at < TERMS_TTL_MS) return cache.linker
  const linker = loadTerms(db).then(createLinker)
  const entry = { at: now, linker }
  linker.catch(() => { if (cache === entry) cache = null })
  cache = entry
  return linker
}

/** 試験用。プロセス内の写しを捨てる */
export function resetTermLinker(): void { cache = null }
