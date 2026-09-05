import { currentUserId } from '@/lib/auth/dal'
import { tryDb } from '@/lib/db/optional'
import { loadAtlasBundle } from '@/lib/atlas/catalog'
import { atlasLearningHref } from '@/lib/atlas/learning'
import { Screen } from '@/components/ui'
import { NotReady } from '@/components/not-ready'
import { AtlasLoader } from './loader'

export const dynamic = 'force-dynamic'

export default async function MapPage({
  searchParams,
}: {
  searchParams: Promise<{ story?: string; year?: string }>
}) {
  const userId = await currentUserId()
  if (!userId) return <Screen title="歴史地球儀" tab="map"><NotReady /></Screen>

  const bundle = await loadAtlasBundle()
  const db = tryDb()
  const query = await searchParams
  const initialStory = bundle.stories.find(story => story.id === query.story) ?? bundle.stories[0]!
  const eventIds = new Set(initialStory.eventIds)
  const initialEvents = bundle.events.filter(event => eventIds.has(event.id))
  const initialLearningHref = await atlasLearningHref(db, userId, initialStory.unitId)
  const parsedYear = Number(query.year)

  return (
    <Screen title="歴史地球儀" tab="map" layout="workspace">
      <AtlasLoader
        stories={bundle.stories}
        initialStory={initialStory}
        initialEvents={initialEvents}
        initialLearningHref={initialLearningHref}
        initialYear={Number.isInteger(parsedYear) && parsedYear !== 0 ? parsedYear : undefined}
      />
    </Screen>
  )
}
