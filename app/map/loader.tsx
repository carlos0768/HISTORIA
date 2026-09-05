'use client'

import dynamic from 'next/dynamic'
import { useEffect, useState } from 'react'
import { feature } from 'topojson-client'
import type { Feature, FeatureCollection, Geometry, GeoJsonProperties } from 'geojson'
import type { GeometryCollection, Topology } from 'topojson-specification'
import type { AtlasEvent, AtlasStory } from '@/lib/atlas/schema'
import type { AtlasCountries } from '@/components/atlas/atlas-workspace'
import type { Basemap } from '@/components/map-workspace'

const AtlasWorkspace = dynamic(
  () => import('@/components/atlas/atlas-workspace').then(module => module.AtlasWorkspace),
  { ssr: false, loading: () => <AtlasLoading /> },
)

const FlatMapWorkspace = dynamic(
  () => import('@/components/map-workspace').then(module => module.MapWorkspace),
  { ssr: false, loading: () => <p className="lv-caption">地図を読み込んでいます…</p> },
)

function AtlasLoading() {
  return (
    <div className="hs-atlas-loading" role="status">
      <span className="hs-atlas-loading__globe" aria-hidden="true" />
      <span>50m世界地図を読み込んでいます…</span>
    </div>
  )
}

export function AtlasLoader({
  stories, initialStory, initialEvents, initialLearningHref, initialYear,
}: {
  stories: AtlasStory[]
  initialStory: AtlasStory
  initialEvents: AtlasEvent[]
  initialLearningHref: string
  initialYear?: number
}) {
  const [countries, setCountries] = useState<AtlasCountries | null>(null)
  const [failed, setFailed] = useState(false)

  useEffect(() => {
    let live = true
    import('world-atlas/countries-50m.json').then(module => {
      const topology = module.default as unknown as Topology<{ countries: GeometryCollection }>
      const collection = feature(topology, topology.objects.countries) as unknown as FeatureCollection<Geometry, GeoJsonProperties>
      if (live) setCountries(collection.features as Feature<Geometry, GeoJsonProperties>[])
    }).catch(() => { if (live) setFailed(true) })
    return () => { live = false }
  }, [])

  if (failed) return <p className="hs-atlas-error">世界地図を読み込めませんでした。通信を確かめて開き直してください。</p>
  if (!countries) return <AtlasLoading />
  return (
    <AtlasWorkspace
      countries={countries}
      stories={stories}
      initialStory={initialStory}
      initialEvents={initialEvents}
      initialLearningHref={initialLearningHref}
      initialYear={initialYear}
    />
  )
}

/** 特訓内の従来の平面地図は互換のまま残す。 */
export function MapLoader({ regionIds, title }: { regionIds: number[]; title: string }) {
  const [basemap, setBasemap] = useState<Basemap | null>(null)
  const [failed, setFailed] = useState(false)
  useEffect(() => {
    let live = true
    import('@/lib/map/basemap-50m')
      .then(module => { if (live) setBasemap(module as unknown as Basemap) })
      .catch(() => { if (live) setFailed(true) })
    return () => { live = false }
  }, [])
  if (failed) return <p className="lv-caption">地図を読み込めませんでした。</p>
  if (!basemap) return <p className="lv-caption">地図を読み込んでいます…</p>
  return <FlatMapWorkspace basemap={basemap} regionIds={regionIds} title={title} />
}
