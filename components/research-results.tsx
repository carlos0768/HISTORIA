'use client'

/**
 * 「調べる」の結果（docs/11-ux.md §4.1）
 *
 * 参照元の主役は **教科書（教材）の節** で、出来事と KC はその理解を助ける関連として下に並べる。
 * 地図・年表・一覧の3つを、1つの「選んでいる項目」で連動させる。
 * 教材の中のパネル（research-panel.tsx）と専用ページ（/research）の両方が使う。
 *
 * ★ この部品は検索をしない。結果を受け取って描くだけである。
 * ★ 「どうやって引いたか」を隠さない。語の一致だけのときはそう書く。
 * ★ 節の年代と地域は節に付いた KC から取った概数である。そう書く。
 */
import { useState } from 'react'
import Link from 'next/link'
import { ChronoChart, type ChronoItem } from './chrono-chart'
import { WorldMap } from './world-map'
import { periodsOf, formatCentury } from '@/lib/domain/periods'
import { formatSpan } from '@/lib/loop/timeline'
import { regionLabel } from '@/lib/map/regions'
import type { ResearchHit, ResearchResponse } from '@/lib/loop/research'

// 基図は約80KBだが、検索結果の描画中に別チャンクとしては読まない。
// モバイルのPWAをデプロイをまたいで開いたままにすると、古いクライアントが
// 既に消えた遅延チャンクを要求し、検索した瞬間にReactのエラー境界まで落ちる。
// 検索結果そのものが主要機能なので、ここは初回のクライアントチャンクに含める。

const KC_KIND: Record<string, string> = {
  fact: '事実', distinction: '区別', causal: '因果', chronology: '年代順', geo: '地理',
}

/** 地図に塗る地域。選んだ項目があればそれ、無ければ結果の主地域を出現順に（節を先に） */
export function regionsToShow(hits: readonly ResearchHit[], selected: ResearchHit | null, max = 6): number[] {
  if (selected) return [...selected.regionIds]
  const out: number[] = []
  for (const h of hits) {
    for (const r of h.regionIds) if (!out.includes(r)) out.push(r)
    if (out.length >= max) break
  }
  return out.slice(0, max)
}

const howMatched = (h: ResearchHit) =>
  h.textMatch ? '語が一致' : h.similarity !== null ? `近さ ${Math.round(h.similarity * 100)}%` : ''

/** 年代・時代・地域の1行 */
function Meta({ h, approx }: { h: ResearchHit; approx?: boolean }) {
  const periods = h.yearFrom === null ? [] : periodsOf(h.yearFrom, h.yearTo)
  return (
    <span className="lv-caption hs-research__meta">
      {h.yearFrom !== null
        ? `${approx ? 'KC の年代 ' : ''}${formatSpan({ yearFrom: h.yearFrom, yearTo: h.yearTo })}・${formatCentury(h.yearFrom)}・${periods.map(p => p.label).join('〜')}`
        : '年代なし'}
      {h.regionIds.length > 0 ? ` ・ ${h.regionIds.map(regionLabel).join('、')}` : ' ・ 地域なし'}
      {h.kind !== 'section' && h.unitLabels.length > 0 && ` ・ ${h.unitLabels.join(' / ')}`}
      {howMatched(h) && ` ・ ${howMatched(h)}`}
    </span>
  )
}

export function ResearchResults({ result }: { result: ResearchResponse }) {
  const [selectedId, setSelectedId] = useState<string | null>(null)
  const [full, setFull] = useState(false)

  if (!result.ok) return <p className="lv-field-note">{result.error}</p>

  const { sections, hits } = result
  const all = [...sections, ...hits]
  const selected = all.find(h => h.id === selectedId) ?? null
  const dated: ChronoItem[] = all
    .filter((h): h is ResearchHit & { yearFrom: number } => h.yearFrom !== null)
    .map(h => ({ id: h.id, label: h.label, kind: h.kind, yearFrom: h.yearFrom, yearTo: h.yearTo,
                 precision: h.precision, regionIds: h.regionIds }))
  const undated = all.filter(h => h.yearFrom === null)
  const regions = regionsToShow(all, selected)
  const textN = all.filter(h => h.textMatch).length
  const toggle = (id: string) => setSelectedId(s => s === id ? null : id)

  return (
    <>
      <p className="lv-caption">
        「{result.query}」: 教材の節 {sections.length} 件・出来事と KC {hits.length} 件
        {all.length > 0 && `（語の一致 ${textN}・意味が近い ${all.length - textN}）`}
        。{result.mode === 'text' ? '語の一致だけで引いています' : '語の一致と意味の近さで引いています'}。
      </p>
      {result.note && <p className="lv-field-note">{result.note}</p>}

      {all.length === 0 && <p className="lv-caption">見つかりませんでした。別の語で試してください。</p>}

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
              <input type="checkbox" checked={full} onChange={e => setFull(e.target.checked)} />
              {' '}全範囲（前3000〜2000年）を表示
            </label>
          </div>
          <ChronoChart items={dated} selectedId={selectedId} full={full} onSelect={toggle} />
        </div>
      )}

      {/* 教科書の節。参照元の主役なので先に出す */}
      {sections.length > 0 && (
        <div className="hs-stack">
          <span className="lv-label">教材の節</span>
          <div className="hs-timeline">
            {sections.map(h => {
              const sec = h.section!
              const active = h.id === selectedId
              return (
                <div key={h.id} className={`hs-research__section${active ? ' hs-research__section--active' : ''}`}>
                  <button type="button" className="hs-research__pick" aria-pressed={active}
                          onClick={() => toggle(h.id)}>
                    <span className="hs-research__crumb">{sec.unitLabel} › {sec.materialTitle} › §{sec.ord}</span>
                    <span className="hs-research__heading">{h.label}</span>
                    <span className="hs-research__snippet">{sec.snippet}</span>
                    <Meta h={h} approx />
                  </button>
                  <Link className="lv-chip hs-research__open"
                        href={`/material/${sec.materialId}?s=${sec.ord}`}>
                    教材を開く →
                  </Link>
                </div>
              )
            })}
          </div>
        </div>
      )}

      {/* 出来事と KC。節の理解を助ける関連 */}
      {hits.length > 0 && (
        <div className="hs-stack">
          <span className="lv-label">{sections.length > 0 ? '関連する出来事と知識項目' : '出来事と知識項目'}</span>
          <div className="hs-timeline">
            {hits.map(h => {
              const active = h.id === selectedId
              return (
                <button
                  key={h.id} type="button"
                  className={`hs-timeline__row hs-research__hit${active ? ' hs-timeline__row--active' : ''}`}
                  aria-pressed={active}
                  onClick={() => toggle(h.id)}
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
                    <Meta h={h} />
                  </span>
                </button>
              )
            })}
          </div>
        </div>
      )}

      {undated.length > 0 && dated.length > 0 && (
        <p className="lv-caption">年代の無い {undated.length} 件は年表に置いていません。</p>
      )}
    </>
  )
}
