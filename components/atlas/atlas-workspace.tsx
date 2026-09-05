'use client'

import Link from 'next/link'
import {
  useDeferredValue, useEffect, useMemo, useRef, useState,
  type KeyboardEvent, type PointerEvent as ReactPointerEvent, type WheelEvent,
} from 'react'
import type { Feature, GeoJsonProperties, Geometry } from 'geojson'
import { geoGraticule10, geoOrthographic, geoPath } from 'd3-geo'
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
  const [year, setYear] = useState(initialYear ?? initialStory.heroYear)
  const [stepIndex, setStepIndex] = useState(Math.min(3, initialStory.steps.length - 1))
  const [playing, setPlaying] = useState(false)
  const [query, setQuery] = useState('')
  const deferredQuery = useDeferredValue(query)
  const [flags, setFlags] = useState<FeatureFlags>({ route: true, point: true, area: true })
  const eventById = useMemo(() => new Map(storyEvents.map(event => [event.id, event])), [storyEvents])
  const currentStep = story.steps[Math.min(stepIndex, story.steps.length - 1)]!
  const currentEvent = eventById.get(currentStep.eventId) ?? storyEvents[0]!
  const visibleEvents = mode === 'story'
    ? story.steps.slice(0, stepIndex + 1).flatMap(step => {
      const event = eventById.get(step.eventId)
      return event ? [event] : []
    })
    : yearEvents.slice(0, 100)

  useEffect(() => {
    if (!playing || mode !== 'story') return
    const step = story.steps[stepIndex]
    const timer = window.setTimeout(() => {
      if (stepIndex >= story.steps.length - 1) setPlaying(false)
      else setStepIndex(index => index + 1)
    }, step?.durationMs ?? 3600)
    return () => window.clearTimeout(timer)
  }, [mode, playing, stepIndex, story.steps])

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
      .then(result => { setYearEvents(result.items); setYearTotal(result.total) })
      .catch(error => { if (error instanceof Error && error.name !== 'AbortError') setYearEvents([]) })
    return () => controller.abort()
  }, [deferredQuery, mode, year])

  const chooseStory = async (id: string) => {
    const next = stories.find(candidate => candidate.id === id)
    if (!next) return
    const response = await fetch(`/api/atlas/stories/${encodeURIComponent(id)}`)
    if (!response.ok) return
    const detail = await response.json() as { story: AtlasStory; events: AtlasEvent[]; learningHref: string }
    setStory(detail.story)
    setStoryEvents(detail.events)
    setLearningHref(detail.learningHref)
    setStepIndex(0)
    setYear(next.heroYear)
    setPlaying(false)
  }

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
              {stories.filter(item => !query || `${item.title} ${item.summary}`.includes(query)).map(item => (
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
          activeEventId={mode === 'story' ? currentEvent.id : yearEvents[0]?.id}
          mode={mode} playing={playing} onManual={() => setPlaying(false)}
        />
        {mode === 'story' ? (
          <Playback story={story} currentEvent={currentEvent} stepIndex={stepIndex} playing={playing}
            onPlaying={setPlaying} onStep={index => { setStepIndex(index); setPlaying(false) }} />
        ) : <YearRail year={year} setYear={setYear} count={yearTotal} />}
      </main>

      <aside className="hs-atlas__detail" aria-live="polite">
        {mode === 'story' ? (
          <StoryDetail story={story} events={storyEvents} currentEvent={currentEvent} stepIndex={stepIndex}
            flags={flags} setFlags={setFlags} onStep={index => { setStepIndex(index); setPlaying(false) }}
            learningHref={learningHref} />
        ) : <YearDetail events={yearEvents} flags={flags} setFlags={setFlags} />}
      </aside>
    </div>
  )
}

function AtlasGlobe({
  countries, events, flags, activeEventId, mode, playing, onManual,
}: {
  countries: AtlasCountries
  events: AtlasEvent[]
  flags: FeatureFlags
  activeEventId?: string
  mode: Mode
  playing: boolean
  onManual: () => void
}) {
  const [rotation, setRotation] = useState<[number, number, number]>(ATLANTIC_ROTATION)
  const [zoom, setZoom] = useState(1)
  const drag = useRef<{ x: number; y: number; rotation: [number, number, number] } | null>(null)
  const reducedMotion = useReducedMotion()
  const projection = useMemo(() => geoOrthographic().translate([WIDTH / 2, HEIGHT / 2])
    .scale(GLOBE_SCALE * zoom).clipAngle(90).precision(0.45).rotate(rotation), [rotation, zoom])
  const path = useMemo(() => geoPath(projection), [projection])
  const activeEvent = events.find(event => event.id === activeEventId)

  useEffect(() => {
    if (mode !== 'story' || !activeEvent) return
    const position = primaryPosition(activeEvent)
    if (!position) return
    const frame = window.requestAnimationFrame(() => {
      setRotation(targetRotation(position))
    })
    return () => window.cancelAnimationFrame(frame)
  }, [activeEvent, mode])

  useEffect(() => {
    if (mode !== 'year' || playing || reducedMotion) return
    const timer = window.setInterval(() => setRotation(([lambda, phi]) => [lambda + 0.18, phi, 0]), 60)
    return () => window.clearInterval(timer)
  }, [mode, playing, reducedMotion])

  const areas = useMemo(() => new Set(events.flatMap(event => event.features.flatMap(item =>
    item.kind === 'area' ? item.countryCodes : []))), [events])
  const points = useMemo(() => events.flatMap((event, eventIndex) => event.features.flatMap((item, featureIndex) =>
    item.kind === 'point' ? [{ event, feature: item, eventIndex, featureIndex }] : [])), [events])
  const routes = useMemo(() => events.flatMap(event => event.features.flatMap((item, featureIndex) =>
    item.kind === 'route' ? [{ event, feature: item, featureIndex }] : [])), [events])

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

function Playback({ story, currentEvent, stepIndex, playing, onPlaying, onStep }: {
  story: AtlasStory; currentEvent: AtlasEvent; stepIndex: number; playing: boolean
  onPlaying: (value: boolean) => void; onStep: (value: number) => void
}) {
  return <section className="hs-atlas-playback" aria-label="物語の再生">
    <div className="hs-atlas-playback__buttons">
      <button type="button" disabled={stepIndex === 0} onClick={() => onStep(stepIndex - 1)}>◀　前へ</button>
      <button type="button" className="is-primary" onClick={() => onPlaying(!playing)}>{playing ? '■　停止' : '▶　再生'}</button>
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
      <a href={source.url} target="_blank" rel="noreferrer">出典 ↗</a>
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

function YearDetail({ events, flags, setFlags }: { events: AtlasEvent[]; flags: FeatureFlags; setFlags: (next: FeatureFlags) => void }) {
  return <><FeatureSwitches flags={flags} setFlags={setFlags} />
    <p className="hs-atlas-note">一度に描くのは最大100件です。低信頼度も「要検証」として表示します。</p>
    <section className="hs-atlas-steps hs-atlas-steps--year"><h2>この年代の出来事 <small>（{events.length}件）</small></h2>
      {events.length === 0 ? <p className="hs-atlas-empty">この年に表示できる出来事はありません。</p> : <ol>
        {events.slice(0, 100).map((event, index) => <li key={event.id}>
          <div className={`hs-atlas-event-row is-${event.evidence.confidence}`}>
            <span>{index + 1}</span><strong>{event.label}</strong><time>{formatHistoricalDate(event.start)}</time>
            <small>{CONFIDENCE_LABEL[event.evidence.confidence]} ・ {event.summary}</small>
          </div>
        </li>)}
      </ol>}
    </section>
  </>
}
