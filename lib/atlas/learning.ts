import 'server-only'
import type { Sql } from 'postgres'

export async function atlasLearningHref(db: Sql | null, userId: string, unitId: string): Promise<string> {
  if (db) {
    const rows = await db<{ id: string }[]>`
      SELECT id FROM material
       WHERE unit_id = ${unitId} AND status = 'ready'
         AND (user_id = ${userId} OR user_id IS NULL)
       ORDER BY (user_id = ${userId}) DESC, generated_at DESC
       LIMIT 1`
    const material = rows[0]
    if (material) return `/material/${material.id}`
  }
  return `/drills/new?unit=${encodeURIComponent(unitId)}`
}
