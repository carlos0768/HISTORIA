import { NextResponse } from 'next/server'
import { currentUserId } from '@/lib/auth/dal'
import { tryDb } from '@/lib/db/optional'
import { loadAtlasBundle } from '@/lib/atlas/catalog'
import { atlasLearningHref } from '@/lib/atlas/learning'

export const dynamic = 'force-dynamic'

export async function GET(_request: Request, context: { params: Promise<{ id: string }> }) {
  const userId = await currentUserId()
  if (!userId) return NextResponse.json({ error: 'unauthorized' }, { status: 401 })
  const { id } = await context.params
  if (!/^story\.[a-z0-9._-]+$/.test(id)) return NextResponse.json({ error: 'invalid_id' }, { status: 400 })
  const bundle = await loadAtlasBundle()
  const story = bundle.stories.find(candidate => candidate.id === id)
  if (!story) return NextResponse.json({ error: 'not_found' }, { status: 404 })
  const eventIds = new Set(story.eventIds)
  const events = bundle.events.filter(event => eventIds.has(event.id))
  const learningHref = await atlasLearningHref(tryDb(), userId, story.unitId)
  return NextResponse.json({ story, events, learningHref })
}
