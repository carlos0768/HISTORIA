import { sql } from '../../lib/db/client'
import { readAtlasBundle } from '../../lib/atlas/files'

export async function ingestAtlas(apply: boolean) {
  const bundle = await readAtlasBundle()
  if (!apply) return { applied: false, events: bundle.events.length, stories: bundle.stories.length }
  const db = sql()
  await db.begin(async tx => {
    for (const event of bundle.events) {
      for (const source of event.sources) {
        await tx`INSERT INTO atlas_source (id, url, title, publisher, accessed_at, license)
          VALUES (${source.id}, ${source.url}, ${source.title}, ${source.publisher}, ${source.accessedAt}, ${source.license ?? null})
          ON CONFLICT (id) DO UPDATE SET url = EXCLUDED.url, title = EXCLUDED.title,
            publisher = EXCLUDED.publisher, accessed_at = EXCLUDED.accessed_at, license = EXCLUDED.license`
      }
      await tx`INSERT INTO atlas_event
        (id, canon_event_id, wikidata_id, label, aliases, summary, start_year, start_date,
         end_year, end_date, exam_weight, confidence, features, evidence, tags, updated_at)
        VALUES (${event.id}, ${event.canonEventId ?? null}, ${event.wikidataId ?? null}, ${event.label},
          ${event.aliases}, ${event.summary}, ${event.start.year}, ${tx.json(event.start)},
          ${event.end?.year ?? null}, ${event.end ? tx.json(event.end) : null}, ${event.examWeight},
          ${event.evidence.confidence}, ${tx.json(event.features)}, ${tx.json(event.evidence)}, ${event.tags}, now())
        ON CONFLICT (id) DO UPDATE SET canon_event_id = EXCLUDED.canon_event_id,
          wikidata_id = EXCLUDED.wikidata_id, label = EXCLUDED.label, aliases = EXCLUDED.aliases,
          summary = EXCLUDED.summary, start_year = EXCLUDED.start_year, start_date = EXCLUDED.start_date,
          end_year = EXCLUDED.end_year, end_date = EXCLUDED.end_date, exam_weight = EXCLUDED.exam_weight,
          confidence = EXCLUDED.confidence, features = EXCLUDED.features, evidence = EXCLUDED.evidence,
          tags = EXCLUDED.tags, updated_at = now()`
      await tx`DELETE FROM atlas_event_source WHERE event_id = ${event.id}`
      await tx`DELETE FROM atlas_event_unit WHERE event_id = ${event.id}`
      await tx`DELETE FROM atlas_event_kc WHERE event_id = ${event.id}`
      for (const source of event.sources) {
        await tx`INSERT INTO atlas_event_source (event_id, source_id, claims)
          VALUES (${event.id}, ${source.id}, ${source.claims})`
      }
      for (const unitId of event.unitIds) {
        await tx`INSERT INTO atlas_event_unit (event_id, unit_id) VALUES (${event.id}, ${unitId})`
      }
      for (const kcId of event.kcIds) {
        await tx`INSERT INTO atlas_event_kc (event_id, kc_id) VALUES (${event.id}, ${kcId})`
      }
    }
    for (const story of bundle.stories) {
      await tx`INSERT INTO atlas_story (id, title, summary, unit_id, kind, hero_year, exam_weight)
        VALUES (${story.id}, ${story.title}, ${story.summary}, ${story.unitId}, ${story.kind}, ${story.heroYear}, ${story.examWeight})
        ON CONFLICT (id) DO UPDATE SET title = EXCLUDED.title, summary = EXCLUDED.summary,
          unit_id = EXCLUDED.unit_id, kind = EXCLUDED.kind, hero_year = EXCLUDED.hero_year,
          exam_weight = EXCLUDED.exam_weight`
      await tx`DELETE FROM atlas_story_step WHERE story_id = ${story.id}`
      for (const step of story.steps) {
        await tx`INSERT INTO atlas_story_step (id, story_id, event_id, ord, title, narration, duration_ms)
          VALUES (${step.id}, ${story.id}, ${step.eventId}, ${step.ord}, ${step.title}, ${step.narration}, ${step.durationMs})`
      }
    }
  })
  return { applied: true, events: bundle.events.length, stories: bundle.stories.length }
}

if (process.argv[1]?.endsWith('ingest.ts')) {
  const result = await ingestAtlas(process.argv.includes('--apply'))
  console.log(result.applied ? 'AtlasをDBへ反映しました。' : 'dry-run: DBは変更していません。--apply で反映します。')
  console.log(`${result.events} events / ${result.stories} stories`)
}
