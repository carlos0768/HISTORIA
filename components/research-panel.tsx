'use client'

/**
 * 教材の中の「調べる」（docs/11-ux.md §4.1）
 *
 * 読んでいる節に出てきた語を、その場で KC と正典から引く。
 * 当たったものを **年表**（どの時代か）と **地図**（どの地域か）に置く。
 *
 * ★ この部品は DB も AI も触らない。検索は親から渡された Server Action で行う。
 * ★ 「どうやって引いたか」を隠さない。語の一致だけのときはそう書く
 *   （鍵が無い・埋め込みが空・支出上限、のどれでも起きる）。
 * ★ 検索語は意味で引くために Google（Gemini API）へ送る。送る前にそう書く
 *   （docs/08 §4.3 と同じ作法。読んでから言われても遅い）。
 */
import { useState, useTransition } from 'react'
import dynamic from 'next/dynamic'
import { ChronoChart, type ChronoItem } from './chrono-chart'
import { periodsOf, formatCentury } from '@/lib/domain/periods'
import { formatSpan } from '@/lib/loop/timeline'
import { regionLabel } from '@/lib/map/regions'
import { QUERY_MAX_CHARS, type ResearchHit, type ResearchResponse } from '@/lib/loop/research'

// 基図は約80KBある。結果に地域が付いたときだけ読む（reader.tsx と同じ理由）
const WorldMap = dynamic(() => import('@/components/world-map').then(m => m.WorldMap))

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

const KC_KIND: Record<string, string> = {
  fact: '事実', distinction: '区別', causal: '因果', chronology: '年代順', geo: '地理',
}

/** 地図に塗る地域。選んだ項目があればそれ、無ければ結果の主地域を出現順に */
export function regionsToShow(hits: readonly ResearchHit[], selected: ResearchHit | null, max = 6): number[] {
  if (selected) return [...selected.regionIds]
  const out: number[] = []
  for (const h of hits) {
    for (const r of h.regionIds) if (!out.includes(r)) out.push(r)
    if (out.length >= max) break
  }
  return out.slice(0, max)
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
  const [selectedId, setSelectedId] = useState<string | null>(null)
  const [fit, setFit] = useState(false)

  const hits = result?.ok ? result.hits : []
  const selected = hits.find(h => h.id === selectedId) ?? null
  const dated: ChronoItem[] = hits
    .filter((h): h is ResearchHit & { yearFrom: number } => h.yearFrom !== null)
    .map(h => ({ id: h.id, label: h.label, kind: h.kind, yearFrom: h.yearFrom, yearTo: h.yearTo,
                 precision: h.precision, regionIds: h.regionIds }))
  const undated = hits.filter(h => h.yearFrom === null)
  const regions = regionsToShow(hits, selected)
  const textN = hits.filter(h => h.textMatch).length

  const submit = (q: string) => {
    if (pending) return
    setSelectedId(null)
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

      {result && !result.ok && <p className="lv-field-note">{result.error}</p>}

      {result?.ok && (
        <>
          <p className="lv-caption">
            「{result.query}」: {hits.length} 件
            {hits.length > 0 && `（語の一致 ${textN}・意味が近い ${hits.length - textN}）`}
            。{result.mode === 'text' ? '語の一致だけで引いています' : '語の一致と意味の近さで引いています'}。
          </p>
          {result.note && <p className="lv-field-note">{result.note}</p>}

          {hits.length === 0 && <p className="lv-caption">見つかりませんでした。別の語で試してください。</p>}

          {/* 地図。地域の付いた結果があるときだけ。塗る先が無い地図は場所を取るだけである */}
          {regions.length > 0 && (
            <WorldMap
              highlight={regions}
              title={selected ? selected.label : `「${result.query}」に関係する地域`}
            />
          )}

          {/* 年表。年代の付いた結果があるときだけ */}
          {dated.length > 0 && (
            <div className="hs-stack">
              <div className="hs-titlerow">
                <span className="lv-label">年表</span>
                <label className="lv-caption">
                  <input type="checkbox" checked={fit} onChange={e => setFit(e.target.checked)} />
                  {' '}結果に合わせて拡大
                </label>
              </div>
              <ChronoChart items={dated} selectedId={selectedId} fit={fit}
                           onSelect={id => setSelectedId(s => s === id ? null : id)} />
            </div>
          )}

          {hits.length > 0 && (
            <div className="hs-timeline">
              {hits.map(h => {
                const active = h.id === selectedId
                const periods = h.yearFrom === null ? [] : periodsOf(h.yearFrom, h.yearTo)
                return (
                  <button
                    key={h.id} type="button"
                    className={`hs-timeline__row hs-research__hit${active ? ' hs-timeline__row--active' : ''}`}
                    aria-pressed={active}
                    onClick={() => setSelectedId(s => s === h.id ? null : h.id)}
                  >
                    <span className="hs-timeline__year">
                      {h.yearFrom === null ? '年代なし' : formatSpan({ yearFrom: h.yearFrom, yearTo: h.yearTo })}
                    </span>
                    <span className="hs-timeline__label hs-research__body">
                      <span>
                        <span className="hs-research__kind">
                          {h.kind === 'event' ? '出来事' : `KC・${KC_KIND[h.kcKind ?? ''] ?? h.kcKind}`}
                        </span>
                        {' '}{h.label}
                      </span>
                      <span className="lv-caption hs-research__meta">
                        {h.yearFrom !== null && `${formatCentury(h.yearFrom)}・${periods.map(p => p.label).join('〜')}`}
                        {h.regionIds.length > 0 && ` ・ ${h.regionIds.map(regionLabel).join('、')}`}
                        {h.regionIds.length === 0 && ' ・ 地域なし'}
                        {h.unitLabels.length > 0 && ` ・ ${h.unitLabels.join(' / ')}`}
                        {h.textMatch ? ' ・ 語が一致' : h.similarity !== null ? ` ・ 近さ ${Math.round(h.similarity * 100)}%` : ''}
                      </span>
                    </span>
                  </button>
                )
              })}
            </div>
          )}

          {undated.length > 0 && dated.length > 0 && (
            <p className="lv-caption">年代の無い {undated.length} 件は年表に置いていません。</p>
          )}
        </>
      )}
    </div>
  )
}
