'use client'

/**
 * 教材の中の「調べる」（docs/11-ux.md §4.1）
 *
 * 読んでいる節に出てきた語を、その場で教科書（教材の節）と KC・正典から引く。
 * 当たったものを **年表**（どの時代か）と **地図**（どの地域か）に置く。
 *
 * ★ この部品は DB も AI も触らない。検索は親から渡された Server Action で行う。
 * ★ 「どうやって引いたか」を隠さない。語の一致だけのときはそう書く
 *   （鍵が無い・埋め込みが空・支出上限、のどれでも起きる）。
 * ★ 検索語は意味で引くために Google（Gemini API）へ送る。送る前にそう書く
 *   （docs/08 §4.3 と同じ作法。読んでから言われても遅い）。
 */
import { useState, useTransition } from 'react'
import Link from 'next/link'
import { ResearchResults } from './research-results'
import { QUERY_MAX_CHARS, type ResearchResponse } from '@/lib/loop/research'

export type SearchFn = (query: string) => Promise<ResearchResponse>

/**
 * 検索の状態。親（節の画面）が持ち、KC のチップからも同じ経路で引けるようにする。
 * ★ effect の中で検索を始めない。始めるのは必ず操作（送信・チップ・選択語）である。
 */
export function useResearch(search: SearchFn) {
  const [query, setQuery] = useState('')
  const [result, setResult] = useState<ResearchResponse | null>(null)
  const [pending, startTransition] = useTransition()

  const run = (q: string) => {
    setQuery(q)
    startTransition(async () => {
      let r: ResearchResponse
      try {
        r = await search(q)
      } catch (e) {
        r = { ok: false, error: e instanceof Error ? e.message : '検索に失敗しました' }
      }
      startTransition(() => setResult(r))
    })
  }
  return { query, setQuery, result, pending, run }
}

export function ResearchPanel({
  research, suggestions, selection,
}: {
  research: ReturnType<typeof useResearch>
  /** この節の KC。押すとその語で引く */
  suggestions: readonly string[]
  /** 本文で選択している文字列。押すとその語で引く */
  selection: string | null
}) {
  const { query, setQuery, result, pending, run } = research

  const submit = (q: string) => {
    if (pending) return
    run(q)
  }

  return (
    <div className="hs-research">
      <form
        className="hs-report__row"
        onSubmit={e => { e.preventDefault(); submit(query) }}
      >
        <input
          className="lv-input" type="search" value={query} maxLength={QUERY_MAX_CHARS}
          onChange={e => setQuery(e.target.value)}
          placeholder="語を入れて調べる（例: アッバース朝）" aria-label="調べたい語"
        />
        <button type="submit" className="lv-btn lv-btn--primary" disabled={pending}>
          {pending ? '調べています…' : '調べる'}
        </button>
      </form>
      <p className="lv-caption">
        意味の近い項目を引くため、入れた語だけを Google（Gemini API）へ送ります。
        氏名などの個人の情報は入れないでください。
      </p>

      {(suggestions.length > 0 || selection) && (
        <div className="lv-chips">
          {selection && (
            <button type="button" className="lv-chip lv-chip--marker" onClick={() => submit(selection)}>
              「{selection}」を調べる
            </button>
          )}
          {suggestions.map(s => (
            <button key={s} type="button" className="lv-chip" onClick={() => submit(s)}>{s}</button>
          ))}
        </div>
      )}

      {/* ★ 結果は専用ページと同じ部品で描く。key で検索ごとに選択を捨てる */}
      {result && <ResearchResults key={result.ok ? result.query : 'error'} result={result} />}

      {result?.ok && (
        <p className="lv-caption">
          <Link href={`/research?q=${encodeURIComponent(result.query)}`}>専用のページで調べる →</Link>
        </p>
      )}
    </div>
  )
}
