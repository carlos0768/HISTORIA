import { NextResponse, type NextRequest } from 'next/server'
import { currentUserId } from '@/lib/auth/dal'
import { searchAtlasEvents } from '@/lib/atlas/catalog'
import { AtlasEventQuerySchema, searchParamsObject } from '@/lib/atlas/http'

export const dynamic = 'force-dynamic'

export async function GET(request: NextRequest) {
  if (!await currentUserId()) return NextResponse.json({ error: 'unauthorized' }, { status: 401 })
  const parsed = AtlasEventQuerySchema.safeParse(searchParamsObject(request.url))
  if (!parsed.success) {
    return NextResponse.json({ error: 'invalid_query', issues: parsed.error.issues }, { status: 400 })
  }
  const result = await searchAtlasEvents({
    q: parsed.data.q,
    year: parsed.data.year,
    unitId: parsed.data.unit,
    confidence: parsed.data.confidence,
    page: parsed.data.page,
    limit: parsed.data.limit,
  })
  return NextResponse.json(result)
}
