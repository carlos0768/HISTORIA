'use client'

import Link from 'next/link'
import {
  useCallback, useDeferredValue, useEffect, useMemo, useRef, useState,
  type KeyboardEvent, type PointerEvent as ReactPointerEvent, type WheelEvent,
} from 'react'
import type { Feature, GeoJsonProperties, Geometry } from 'geojson'
import { geoGraticule10, geoInterpolate, geoOrthographic, geoPath } from 'd3-geo'
import {
  formatHistoricalDate,
  type AtlasEvent, type AtlasPosition, type AtlasStory,
} from '@/lib/atlas/schema'
import { isFrontFacing, targetRotation } from '@/lib/atlas/geo'

export type AtlasCountries = Feature<Geometry, GeoJsonProperties>[]
type FeatureFlags = { route: boolean; point: boolean; area: boolean }
type Mode = 'story' | 'year'

const WIDTH = 660
const HEIGHT = 620
const GLOBE_SCALE = 300
const ATLANTIC_ROTATION: [number, number, number] = [38, -22, 0]
const CONFIDENCE_LABEL = { high: '高', medium: '中', low: '要検証' } as const
const CONFIDENCE_DETAIL = {
  high: '日付・地点・叙述が複数の記録または校閲で一致しています。',
  medium: '主要な根拠があります。一部の地点・経路は代表点や概略線です。',
  low: '出典はありますが、年代・範囲・比定の一部に推定を含みます。',
} as const

function primaryPosition(event: AtlasEvent): AtlasPosition | null {
  for (const item of event.features) {
    if (item.kind === 'point') return item.coordinates
    if (item.kind === 'route') return item.coordinates[item.coordinates.length - 1] ?? null
  }
  return null
}

/** 固有記事が無い出来事もあるため、完全一致なら記事へ、無ければ検索結果へ送る。 */
export function wikipediaHref(event: Pick<AtlasEvent, 'label'>): string {
  return `https://ja.wikipedia.org/wiki/Special:Search?search=${encodeURIComponent(event.label)}&go=Go`
}

function countryId(feature: Feature<Geometry, GeoJsonProperties>): string {
  return String(feature.id ?? '').padStart(3, '0')
}

function useReducedMotion(): boolean {
  const [reduced, setReduced] = useState(false)
  useEffect(() => {
    const media = window.matchMedia('(prefers-reduced-motion: reduce)')
    const update = () => setReduced(media.matches)
    update()
    media.addEventListener('change', update)
    return () => media.removeEventListener('change', update)
  }, [])
  return reduced
}

export function AtlasWorkspace({
  stories, initialStory, initialEvents, initialLearningHref, countries, initialYear,
}: {
  stories: AtlasStory[]
  initialStory: AtlasStory
  initialEvents: AtlasEvent[]
  initialLearningHref: string
  countries: AtlasCountries
  initialYear?: number
}) {
  const [mode, setMode] = useState<Mode>(initialYear === undefined ? 'story' : 'year')
  const [story, setStory] = useState(initialStory)
  const [storyEvents, setStoryEvents] = useState(initialEvents)
  const [learningHref, setLearningHref] = useState(initialLearningHref)
  const [yearEvents, setYearEvents] = useState<AtlasEvent[]>([])
  const [yearTotal, setYearTotal] = useState(0)
  const [yearSelectedId, setYearSelectedId] = useState<string | null>(null)
  const [year, setYear] = useState(initialYear ?? initialStory.heroYear)
  const [stepIndex, setStepIndex] = useState(Math.min(3, initialStory.steps.length - 1))
  const [playing, setPlaying] = useState(false)
  const [focusRequest, setFocusRequest] = useState(0)
  const [query, setQuery] = useState('')
  const deferredQuery = useDeferredValue(query)
  const [flags, setFlags] = useState<FeatureFlags>({ route: true, point: true, area: true })
  const storyRequest = useRef(0)
  const filteredStories = useMemo(
    () => stories.filter(item => !deferredQuery || `${item.title} ${item.summary}`.includes(deferredQuery)),
    [deferredQuery, stories],
  )
  const eventById = useMemo(() => new Map(storyEvents.map(event => [event.id, event])), [storyEvents])
  const currentStep = story.steps[Math.min(stepIndex, story.steps.length - 1)]!
  const currentEvent = eventById.get(currentStep.eventId) ?? storyEvents[0]!
  const nextStep = story.steps[stepIndex + 1]
  const nextEvent = nextStep ? eventById.get(nextStep.eventId) ?? null : null
  const trailPositions = useMemo(() => story.steps.slice(0, stepIndex + 1).flatMap(step => {
    const event = eventById.get(step.eventId)
    const position = event ? primaryPosition(event) : null
    return position ? [position] : []
  }), [eventById, stepIndex, story.steps])
  const visibleEvents = mode === 'story'
    ? story.steps.slice(0, stepIndex + 1).flatMap(step => {
      const event = eventById.get(step.eventId)
      return event ? [event] : []
    })
    : yearEvents.slice(0, 100)

  useEffect(() => {
    if (mode !== 'year') return
    const controller = new AbortController()
    const params = new URLSearchParams({ year: String(year), limit: '100' })
    if (deferredQuery) params.set('q', deferredQuery)
    void fetch(`/api/atlas/events?${params}`, { signal: controller.signal })
      .then(async response => {
        if (!response.ok) throw new Error(String(response.status))
        return response.json() as Promise<{ total: number; items: AtlasEvent[] }>
      })
      .then(result => {
        setYearEvents(result.items)
        setYearTotal(result.total)
        setYearSelectedId(result.items[0]?.id ?? null)
      })
      .catch(error => { if (error instanceof Error && error.name !== 'AbortError') setYearEvents([]) })
    return () => controller.abort()
  }, [deferredQuery, mode, year])

  const chooseStory = useCallback(async (id: string) => {
    const next = stories.find(candidate => candidate.id === id)
    if (!next) return
    const request = ++storyRequest.current
    const response = await fetch(`/api/atlas/stories/${encodeURIComponent(id)}`)
    if (!response.ok) return
    const detail = await response.json() as { story: AtlasStory; events: AtlasEvent[]; learningHref: string }
    // 入力中に候補が続けて変わった場合、遅れて返った古い応答で巻き戻さない。
    if (request !== storyRequest.current) return
    setStory(detail.story)
    setStoryEvents(detail.events)
    setLearningHref(detail.learningHref)
    setStepIndex(0)
    setYear(next.heroYear)
    setPlaying(false)
  }, [stories])

  // 検索で現在の物語が候補から外れたら、先頭候補を実際の表示にも反映する。
  // select の option だけを絞ると、欄は新候補なのに地球と説明は旧物語のままになる。
  useEffect(() => {
    if (mode !== 'story' || filteredStories.length === 0) return
    if (filteredStories.some(item => item.id === story.id)) return
    void chooseStory(filteredStories[0]!.id)
  }, [chooseStory, filteredStories, mode, story.id])

  const selectStoryStep = useCallback((index: number) => {
    setStepIndex(index)
    setPlaying(false)
    setFocusRequest(value => value + 1)
  }, [])

  const advanceStory = useCallback(() => {
    if (stepIndex >= story.steps.length - 2) {
      setStepIndex(story.steps.length - 1)
      setPlaying(false)
    } else {
      setStepIndex(stepIndex + 1)
    }
  }, [stepIndex, story.steps.length])

  const togglePlaying = () => {
    if (playing) {
      setPlaying(false)
      return
    }
    if (stepIndex >= story.steps.length - 1) setStepIndex(0)
    setFocusRequest(0)
    setPlaying(true)
  }

  const selectYearEvent = (id: string) => {
    setYearSelectedId(id)
    setFocusRequest(value => value + 1)
  }
  const activeYearEvent = yearEvents.find(event => event.id === yearSelectedId) ?? yearEvents[0]

  return (
    <div className="hs-atlas">
      <div className="hs-atlas__toolbar">
        <label className="hs-atlas-search">
          <span aria-hidden="true">⌕</span>
          <span className="sr-only">出来事・人物・地域をさがす</span>
          <input value={query} onChange={event => setQuery(event.target.value)} placeholder="出来事・人物・地域をさがす" />
        </label>
        <div className="hs-atlas-segment" aria-label="表示モード">
          <button type="button" className={mode === 'story' ? 'is-active' : ''} onClick={() => setMode('story')}>物語</button>
          <button type="button" className={mode === 'year' ? 'is-active' : ''} onClick={() => { setMode('year'); setPlaying(false) }}>年代</button>
        </div>
        {mode === 'story' ? (
          <label className="hs-atlas-select hs-atlas-select--story">
            <span className="sr-only">選択中の物語</span>
            <select value={story.id} onChange={event => { void chooseStory(event.target.value) }}>
              {filteredStories.map(item => (
                <option key={item.id} value={item.id}>{item.title}</option>
              ))}
            </select>
          </label>
        ) : (
          <label className="hs-atlas-year">
            <span className="sr-only">表示する年</span>
            <input type="number" min="-10000" max="2100" value={year} onChange={event => {
              const next = Number(event.target.value)
              if (Number.isInteger(next) && next !== 0) setYear(next)
            }} />
            <span>年</span>
          </label>
        )}
      </div>

      <main className="hs-atlas__stage">
        <AtlasGlobe
          countries={countries} events={visibleEvents} flags={flags}
          activeEventId={mode === 'story' ? currentEvent.id : activeYearEvent?.id}
          mode={mode} playing={playing} focusRequest={focusRequest}
          trailPositions={mode === 'story' ? trailPositions : []}
          nextPosition={mode === 'story' && nextEvent ? primaryPosition(nextEvent) : null}
          travelDurationMs={nextStep?.durationMs ?? 3600}
          onTravelEnd={advanceStory} onManual={() => setPlaying(false)}
        />
        {mode === 'story' ? (
          <Playback story={story} currentEvent={currentEvent} stepIndex={stepIndex} playing={playing}
            onToggle={togglePlaying} onStep={selectStoryStep} />
        ) : <YearRail year={year} setYear={setYear} count={yearTotal} />}
      </main>

      <aside className="hs-atlas__detail" aria-live="polite">
        {mode === 'story' ? (
          <StoryDetail story={story} events={storyEvents} currentEvent={currentEvent} stepIndex={stepIndex}
            flags={flags} setFlags={setFlags} onStep={selectStoryStep}
            learningHref={learningHref} />
        ) : <YearDetail events={yearEvents} selectedId={activeYearEvent?.id}
          flags={flags} setFlags={setFlags} onSelect={selectYearEvent} />}
      </aside>
    </div>
  )
}

function AtlasGlobe({
  countries, events, flags, activeEventId, mode, playing, focusRequest,
  trailPositions, nextPosition, travelDurationMs, onTravelEnd, onManual,
}: {
  countries: AtlasCountries
  events: AtlasEvent[]
  flags: FeatureFlags
  activeEventId?: string
  mode: Mode
  playing: boolean
  focusRequest: number
  trailPositions: AtlasPosition[]
  nextPosition: AtlasPosition | null
  travelDurationMs: number
  onTravelEnd: () => void
  onManual: () => void
}) {
  const [rotation, setRotation] = useState<[number, number, number]>(ATLANTIC_ROTATION)
  const [zoom, setZoom] = useState(1)
  const drag = useRef<{ x: number; y: number; rotation: [number, number, number] } | null>(null)
  const [journeyPosition, setJourneyPosition] = useState<AtlasPosition | null>(null)
  const reducedMotion = useReducedMotion()
  const projection = useMemo(() => geoOrthographic().translate([WIDTH / 2, HEIGHT / 2])
    .scale(GLOBE_SCALE * zoom).clipAngle(90).precision(0.45).rotate(rotation), [rotation, zoom])
  const path = useMemo(() => geoPath(projection), [projection])
  const activeEvent = events.find(event => event.id === activeEventId)

  useEffect(() => {
    if (!activeEvent || (mode === 'year' && focusRequest === 0)) return
    const position = primaryPosition(activeEvent)
    if (!position) return
    const frame = window.requestAnimationFrame(() => {
      setRotation(targetRotation(position))
      if (focusRequest > 0 && !playing) setZoom(1.38)
    })
    return () => window.cancelAnimationFrame(frame)
  }, [activeEvent, focusRequest, mode, playing])

  // 再生中は現在地から次の出来事までを大円上で補間する。親の stepIndex は
  // 区間の終端でだけ進め、線の先端と地球の中心は requestAnimationFrame で連続移動させる。
  useEffect(() => {
    if (!playing || mode !== 'story' || !activeEvent || !nextPosition) return
    const from = primaryPosition(activeEvent)
    if (!from) return
    if (reducedMotion) {
      const timer = window.setTimeout(onTravelEnd, travelDurationMs)
      return () => window.clearTimeout(timer)
    }
    const interpolate = geoInterpolate(from, nextPosition)
    let frame = 0
    let zoomed = false
    const startedAt = performance.now()
    const tick = (now: number) => {
      if (!zoomed) {
        zoomed = true
        setZoom(value => Math.max(value, 1.12))
      }
      const progress = Math.min(1, (now - startedAt) / travelDurationMs)
      const position = interpolate(progress) as AtlasPosition
      setJourneyPosition(position)
      setRotation(targetRotation(position))
      if (progress < 1) frame = window.requestAnimationFrame(tick)
      else onTravelEnd()
    }
    frame = window.requestAnimationFrame(tick)
    return () => window.cancelAnimationFrame(frame)
  }, [activeEvent, mode, nextPosition, onTravelEnd, playing, reducedMotion, travelDurationMs])

  useEffect(() => {
    if (mode !== 'year' || playing || reducedMotion || focusRequest > 0) return
    const timer = window.setInterval(() => setRotation(([lambda, phi]) => [lambda + 0.18, phi, 0]), 60)
    return () => window.clearInterval(timer)
  }, [focusRequest, mode, playing, reducedMotion])

  const areas = useMemo(() => new Set(events.flatMap(event => event.features.flatMap(item =>
    item.kind === 'area' ? item.countryCodes : []))), [events])
  const points = useMemo(() => events.flatMap((event, eventIndex) => event.features.flatMap((item, featureIndex) =>
    item.kind === 'point' ? [{ event, feature: item, eventIndex, featureIndex }] : [])), [events])
  const routes = useMemo(() => events.flatMap(event => event.features.flatMap((item, featureIndex) =>
    item.kind === 'route' ? [{ event, feature: item, featureIndex }] : [])), [events])
  const liveJourneyPosition = playing ? journeyPosition : null
  const progressCoordinates = liveJourneyPosition ? [...trailPositions, liveJourneyPosition] : trailPositions
  const progressPath = progressCoordinates.length < 2 ? null
    : path({ type: 'LineString', coordinates: progressCoordinates })
  const journeyProjected = liveJourneyPosition && isFrontFacing(liveJourneyPosition, rotation)
    ? projection(liveJourneyPosition) : null

  const pointerDown = (event: ReactPointerEvent<SVGSVGElement>) => {
    onManual(); event.currentTarget.setPointerCapture(event.pointerId)
    drag.current = { x: event.clientX, y: event.clientY, rotation }
  }
  const pointerMove = (event: ReactPointerEvent<SVGSVGElement>) => {
    if (!drag.current) return
    const dx = event.clientX - drag.current.x
    const dy = event.clientY - drag.current.y
    setRotation([drag.current.rotation[0] + dx * 0.24,
      Math.max(-75, Math.min(75, drag.current.rotation[1] - dy * 0.24)), 0])
  }
  const wheel = (event: WheelEvent<SVGSVGElement>) => {
    onManual()
    setZoom(value => Math.max(0.72, Math.min(1.65, value * (event.deltaY > 0 ? 0.92 : 1.08))))
  }
  const keys = (event: KeyboardEvent<SVGSVGElement>) => {
    const step = event.shiftKey ? 10 : 4
    if (event.key === 'ArrowLeft') setRotation(([x, y]) => [x - step, y, 0])
    else if (event.key === 'ArrowRight') setRotation(([x, y]) => [x + step, y, 0])
    else if (event.key === 'ArrowUp') setRotation(([x, y]) => [x, Math.min(75, y + step), 0])
    else if (event.key === 'ArrowDown') setRotation(([x, y]) => [x, Math.max(-75, y - step), 0])
    else if (event.key === '+' || event.key === '=') setZoom(value => Math.min(1.65, value * 1.08))
    else if (event.key === '-') setZoom(value => Math.max(0.72, value * 0.92))
    else return
    event.preventDefault(); onManual()
  }

  return (
    <div className="hs-atlas-globe">
      <svg viewBox={`0 0 ${WIDTH} ${HEIGHT}`} role="img"
        aria-label="ドラッグで回転、ホイールで拡大できる歴史地球儀" tabIndex={0}
        onPointerDown={pointerDown} onPointerMove={pointerMove}
        onPointerUp={() => { drag.current = null }} onPointerCancel={() => { drag.current = null }}
        onWheel={wheel} onKeyDown={keys}>
        <defs>
          <radialGradient id="atlas-paper" cx="42%" cy="35%"><stop offset="0" stopColor="#fffdf5" /><stop offset="1" stopColor="#e8dfcd" /></radialGradient>
        </defs>
        <circle className="hs-atlas-globe__ocean" cx={WIDTH / 2} cy={HEIGHT / 2} r={GLOBE_SCALE * zoom} />
        <path className="hs-atlas-globe__graticule" d={path(geoGraticule10()) ?? undefined} />
        <g>{countries.map((country, index) => {
          const d = path(country)
          return d ? <path key={`${countryId(country)}-${index}`} d={d}
            className={flags.area && areas.has(countryId(country)) ? 'hs-atlas-country is-active' : 'hs-atlas-country'} /> : null
        })}</g>
        {flags.route && routes.map(({ event, feature, featureIndex }, index) => {
          const d = path({ type: 'LineString', coordinates: feature.coordinates })
          const active = event.id === activeEventId || index === routes.length - 1
          return d ? <path key={`${event.id}-${featureIndex}`} d={d}
            className={`hs-atlas-route${active ? ' is-active' : ''}${event.evidence.confidence === 'low' ? ' is-low' : ''}`}
            style={{ ['--route-index' as string]: index }} /> : null
        })}
        {flags.route && progressPath && <path className="hs-atlas-progress" d={progressPath} />}
        {journeyProjected && <circle className="hs-atlas-progress__head"
          cx={journeyProjected[0]} cy={journeyProjected[1]} r="7"
          data-longitude={liveJourneyPosition?.[0]} data-latitude={liveJourneyPosition?.[1]} />}
        {flags.point && points.map(({ event, feature, eventIndex, featureIndex }) => {
          if (!isFrontFacing(feature.coordinates, rotation)) return null
          const projected = projection(feature.coordinates)
          if (!projected) return null
          const active = event.id === activeEventId
          const left = projected[0] > WIDTH * .58
          return <g key={`${event.id}-${featureIndex}`} className={`hs-atlas-point${active ? ' is-active' : ''}`} transform={`translate(${projected[0]} ${projected[1]})`}>
            <circle r={active ? 12 : 8} /><text textAnchor={left ? 'end' : 'start'} x={left ? -17 : 17} y="5">
              {mode === 'story' ? `${eventIndex + 1}　${feature.label}` : feature.label}
            </text>
          </g>
        })}
        <circle className="hs-atlas-globe__rim" cx={WIDTH / 2} cy={HEIGHT / 2} r={GLOBE_SCALE * zoom} />
      </svg>
      <p className="hs-atlas-globe__hint">ドラッグで回転　・　ホイール／ピンチで拡大</p>
    </div>
  )
}

function Playback({ story, currentEvent, stepIndex, playing, onToggle, onStep }: {
  story: AtlasStory; currentEvent: AtlasEvent; stepIndex: number; playing: boolean
  onToggle: () => void; onStep: (value: number) => void
}) {
  return <section className="hs-atlas-playback" aria-label="物語の再生">
    <div className="hs-atlas-playback__buttons">
      <button type="button" disabled={stepIndex === 0} onClick={() => onStep(stepIndex - 1)}>◀　前へ</button>
      <button type="button" className="is-primary" onClick={onToggle}>{playing ? '■　停止' : '▶　再生'}</button>
      <button type="button" disabled={stepIndex === story.steps.length - 1} onClick={() => onStep(stepIndex + 1)}>次へ　▶</button>
    </div>
    <label className="hs-atlas-scrub"><span className="sr-only">物語の位置</span>
      <input type="range" min="0" max={story.steps.length - 1} value={stepIndex} onChange={event => onStep(Number(event.target.value))} />
      <span>{stepIndex + 1} / {story.steps.length}</span>
    </label>
    <p className="hs-atlas-now"><mark>{formatHistoricalDate(currentEvent.start)}</mark><strong>{story.steps[stepIndex]?.title}</strong></p>
  </section>
}

function FeatureSwitches({ flags, setFlags }: { flags: FeatureFlags; setFlags: (next: FeatureFlags) => void }) {
  const labels: [keyof FeatureFlags, string][] = [['route', '航路'], ['point', '地点'], ['area', '範囲']]
  return <div className="hs-atlas-switches">{labels.map(([key, label]) =>
    <button key={key} type="button" className={flags[key] ? 'is-active' : ''} aria-pressed={flags[key]}
      onClick={() => setFlags({ ...flags, [key]: !flags[key] })}>
      <span aria-hidden="true">{flags[key] ? '☑' : '□'}</span> {label}
    </button>)}</div>
}

function StoryDetail({ story, events, currentEvent, stepIndex, flags, setFlags, onStep, learningHref }: {
  story: AtlasStory; events: AtlasEvent[]; currentEvent: AtlasEvent; stepIndex: number
  flags: FeatureFlags; setFlags: (next: FeatureFlags) => void
  onStep: (index: number) => void; learningHref: string
}) {
  const source = currentEvent.sources[0]!
  return <>
    <section className="hs-atlas-evidence">
      <div><span>信頼度</span><strong className={`is-${currentEvent.evidence.confidence}`}>{CONFIDENCE_LABEL[currentEvent.evidence.confidence]}</strong></div>
      <div className="hs-atlas-evidence__links">
        <a href={wikipediaHref(currentEvent)} target="_blank" rel="noreferrer">Wikipedia ↗</a>
        <a href={source.url} target="_blank" rel="noreferrer">出典 ↗</a>
      </div>
      <p>{CONFIDENCE_DETAIL[currentEvent.evidence.confidence]}</p>
    </section>
    <FeatureSwitches flags={flags} setFlags={setFlags} />
    <p className="hs-atlas-note">地点・航路は史料に基づく。範囲は現在の国境で近似。</p>
    <section className="hs-atlas-steps"><h2>物語のステップ <small>（全 {story.steps.length} ステップ）</small></h2>
      <ol>{story.steps.map((step, index) => {
        const event = events.find(item => item.id === step.eventId)
        return event ? <li key={step.id}><button type="button" className={index === stepIndex ? 'is-active' : ''} onClick={() => onStep(index)}>
          <span>{index + 1}</span><strong>{step.title}</strong><time>{formatHistoricalDate(event.start)}</time><small>{step.narration}</small>
        </button></li> : null
      })}</ol>
    </section>
    <section className="hs-atlas-source"><h2>主な出典</h2>
      {currentEvent.sources.map(item => <a key={item.id} href={item.url} target="_blank" rel="noreferrer">
        <strong>{item.title}</strong><span>{item.publisher} ↗</span></a>)}
      <p>{currentEvent.summary}</p>
    </section>
    <Link className="hs-atlas-learn" href={learningHref}>この単元を学習する　›</Link>
  </>
}

function YearRail({ year, setYear, count }: { year: number; setYear: (year: number) => void; count: number }) {
  return <section className="hs-atlas-yearrail">
    <div><strong>{year < 0 ? `前${Math.abs(year)}年` : `${year}年`}</strong><span>{count}件</span></div>
    <input type="range" min="-3000" max="2000" step="1" value={year} onChange={event => {
      const next = Number(event.target.value); setYear(next === 0 ? 1 : next)
    }} aria-label="年代を移動" />
    <div className="hs-atlas-yearrail__ticks"><span>前3000</span><span>1</span><span>1000</span><span>2000</span></div>
  </section>
}

function YearDetail({ events, selectedId, flags, setFlags, onSelect }: {
  events: AtlasEvent[]; selectedId?: string; flags: FeatureFlags
  setFlags: (next: FeatureFlags) => void; onSelect: (id: string) => void
}) {
  const selected = events.find(event => event.id === selectedId) ?? events[0]
  return <>{selected && <div className="hs-atlas-year-heading">
      <strong>{selected.label}</strong>
      <a href={wikipediaHref(selected)} target="_blank" rel="noreferrer">Wikipedia ↗</a>
    </div>}
    <FeatureSwitches flags={flags} setFlags={setFlags} />
    <p className="hs-atlas-note">一度に描くのは最大100件です。低信頼度も「要検証」として表示します。</p>
    <section className="hs-atlas-steps hs-atlas-steps--year"><h2>この年代の出来事 <small>（{events.length}件）</small></h2>
      {events.length === 0 ? <p className="hs-atlas-empty">この年に表示できる出来事はありません。</p> : <ol>
        {events.slice(0, 100).map((event, index) => <li key={event.id}>
          <button type="button" onClick={() => onSelect(event.id)}
            className={`hs-atlas-event-row is-${event.evidence.confidence}${event.id === selected?.id ? ' is-active' : ''}`}>
            <span>{index + 1}</span><strong>{event.label}</strong><time>{formatHistoricalDate(event.start)}</time>
            <small>{CONFIDENCE_LABEL[event.evidence.confidence]} ・ {event.summary}</small>
          </button>
        </li>)}
      </ol>}
    </section>
  </>
}
