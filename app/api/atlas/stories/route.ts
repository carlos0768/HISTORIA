import { NextResponse, type NextRequest } from 'next/server'
import { currentUserId } from '@/lib/auth/dal'
import { loadAtlasBundle } from '@/lib/atlas/catalog'
import { AtlasStoryQuerySchema, searchParamsObject } from '@/lib/atlas/http'

export const dynamic = 'force-dynamic'

export async function GET(request: NextRequest) {
  if (!await currentUserId()) return NextResponse.json({ error: 'unauthorized' }, { status: 401 })
  const parsed = AtlasStoryQuerySchema.safeParse(searchParamsObject(request.url))
  if (!parsed.success) return NextResponse.json({ error: 'invalid_query', issues: parsed.error.issues }, { status: 400 })
  const { stories } = await loadAtlasBundle()
  const needle = parsed.data.q?.toLocaleLowerCase('ja')
  const filtered = stories.filter(story => {
    if (parsed.data.unit && story.unitId !== parsed.data.unit) return false
    if (needle && !`${story.title} ${story.summary}`.toLocaleLowerCase('ja').includes(needle)) return false
    return true
  }).sort((a, b) => b.examWeight - a.examWeight)
  const offset = (parsed.data.page - 1) * parsed.data.limit
  return NextResponse.json({
    total: filtered.length, page: parsed.data.page, limit: parsed.data.limit,
    items: filtered.slice(offset, offset + parsed.data.limit),
  })
}
