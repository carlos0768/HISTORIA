import { z } from 'zod'

export const AtlasConfidenceSchema = z.enum(['high', 'medium', 'low'])
export type AtlasConfidence = z.infer<typeof AtlasConfidenceSchema>

export const HistoricalDateSchema = z.object({
  year: z.number().int().min(-10_000).max(2100).refine(year => year !== 0, '西暦0年は存在しません'),
  month: z.number().int().min(1).max(12).optional(),
  day: z.number().int().min(1).max(31).optional(),
  precision: z.enum(['day', 'month', 'year', 'decade', 'century']),
  approximate: z.boolean().default(false),
  label: z.string().min(1).optional(),
}).superRefine((date, ctx) => {
  if (date.day !== undefined && date.month === undefined) {
    ctx.addIssue({ code: 'custom', message: '日を指定するときは月も必要です', path: ['day'] })
  }
})
export type HistoricalDate = z.infer<typeof HistoricalDateSchema>

const PositionSchema = z.tuple([
  z.number().min(-180).max(180),
  z.number().min(-90).max(90),
])
export type AtlasPosition = z.infer<typeof PositionSchema>

const PointFeatureSchema = z.object({
  kind: z.literal('point'),
  coordinates: PositionSchema,
  label: z.string().min(1),
})

const RouteFeatureSchema = z.object({
  kind: z.literal('route'),
  coordinates: z.array(PositionSchema).min(2),
  label: z.string().min(1),
})

const AreaFeatureSchema = z.object({
  kind: z.literal('area'),
  countryCodes: z.array(z.string().regex(/^\d{3}$/)).min(1),
  label: z.string().min(1),
  approximation: z.literal('current-borders'),
})

export const AtlasFeatureSchema = z.discriminatedUnion('kind', [
  PointFeatureSchema,
  RouteFeatureSchema,
  AreaFeatureSchema,
])
export type AtlasFeature = z.infer<typeof AtlasFeatureSchema>

export const SourceRefSchema = z.object({
  id: z.string().regex(/^src\.[a-z0-9._-]+$/),
  url: z.url().refine(url => /^https?:\/\//.test(url), 'HTTP(S) URL が必要です'),
  title: z.string().min(1),
  publisher: z.string().min(1),
  accessedAt: z.iso.date(),
  claims: z.array(z.string().min(1)).min(1),
  license: z.string().min(1).optional(),
})
export type SourceRef = z.infer<typeof SourceRefSchema>

const EvidencePartSchema = z.object({
  status: z.enum(['direct', 'inferred', 'disputed']),
  sourceIds: z.array(z.string()).min(1),
  note: z.string().min(1).optional(),
})

export const AtlasEvidenceSchema = z.object({
  confidence: AtlasConfidenceSchema,
  date: EvidencePartSchema,
  location: EvidencePartSchema,
  narrative: EvidencePartSchema,
  reviewedAt: z.iso.date().optional(),
})
export type AtlasEvidence = z.infer<typeof AtlasEvidenceSchema>

export const AtlasEventSchema = z.object({
  id: z.string().regex(/^ae\.[a-z0-9._-]+$/),
  canonEventId: z.string().optional(),
  wikidataId: z.string().regex(/^Q\d+$/).optional(),
  label: z.string().min(1),
  aliases: z.array(z.string()).default([]),
  summary: z.string().min(1),
  start: HistoricalDateSchema,
  end: HistoricalDateSchema.optional(),
  /** 空配列は、Wikidataから取得済みだが受験単元への比定が未校閲の探索用データ。 */
  unitIds: z.array(z.string().min(1)).default([]),
  kcIds: z.array(z.string().min(1)).default([]),
  examWeight: z.number().min(0).max(3),
  features: z.array(AtlasFeatureSchema).min(1),
  sources: z.array(SourceRefSchema).min(1),
  evidence: AtlasEvidenceSchema,
  tags: z.array(z.string().min(1)).default([]),
}).superRefine((event, ctx) => {
  const sourceIds = new Set(event.sources.map(source => source.id))
  const used = [event.evidence.date, event.evidence.location, event.evidence.narrative]
    .flatMap(part => part.sourceIds)
  for (const sourceId of used) {
    if (!sourceIds.has(sourceId)) {
      ctx.addIssue({ code: 'custom', message: `存在しない出典 ${sourceId} を参照しています`, path: ['evidence'] })
    }
  }
  if (event.end && dateKey(event.end) < dateKey(event.start)) {
    ctx.addIssue({ code: 'custom', message: '終了日は開始日以降である必要があります', path: ['end'] })
  }
})
export type AtlasEvent = z.infer<typeof AtlasEventSchema>

export const AtlasStoryStepSchema = z.object({
  id: z.string().regex(/^as\.[a-z0-9._-]+$/),
  eventId: z.string(),
  ord: z.number().int().min(1),
  title: z.string().min(1),
  narration: z.string().min(1),
  durationMs: z.number().int().min(1200).max(20_000).default(3600),
})
export type AtlasStoryStep = z.infer<typeof AtlasStoryStepSchema>

export const AtlasStorySchema = z.object({
  id: z.string().regex(/^story\.[a-z0-9._-]+$/),
  title: z.string().min(1),
  summary: z.string().min(1),
  unitId: z.string().min(1),
  kind: z.enum(['journey', 'diffusion', 'chronology', 'conflict', 'exchange']),
  heroYear: z.number().int().refine(year => year !== 0),
  examWeight: z.number().min(0).max(3),
  eventIds: z.array(z.string()).min(1),
  steps: z.array(AtlasStoryStepSchema).min(4).max(12),
}).superRefine((story, ctx) => {
  const eventIds = new Set(story.eventIds)
  const orders = story.steps.map(step => step.ord)
  if (new Set(orders).size !== orders.length || !orders.every((ord, index) => ord === index + 1)) {
    ctx.addIssue({ code: 'custom', message: 'step.ord は1から連番である必要があります', path: ['steps'] })
  }
  for (const [index, step] of story.steps.entries()) {
    if (!eventIds.has(step.eventId)) {
      ctx.addIssue({ code: 'custom', message: `${step.eventId} が eventIds にありません`, path: ['steps', index, 'eventId'] })
    }
  }
})
export type AtlasStory = z.infer<typeof AtlasStorySchema>

export const AtlasBundleSchema = z.object({
  version: z.literal('1.0'),
  generatedAt: z.iso.datetime(),
  events: z.array(AtlasEventSchema),
  stories: z.array(AtlasStorySchema),
}).superRefine((bundle, ctx) => {
  const eventIds = new Set(bundle.events.map(event => event.id))
  if (eventIds.size !== bundle.events.length) {
    ctx.addIssue({ code: 'custom', message: 'イベントIDが重複しています', path: ['events'] })
  }
  for (const [storyIndex, story] of bundle.stories.entries()) {
    for (const eventId of story.eventIds) {
      if (!eventIds.has(eventId)) {
        ctx.addIssue({
          code: 'custom', message: `${eventId} がイベント台帳にありません`,
          path: ['stories', storyIndex, 'eventIds'],
        })
      }
    }
  }
})
export type AtlasBundleV1 = z.infer<typeof AtlasBundleSchema>

export function dateKey(date: HistoricalDate): number {
  return date.year * 10_000 + (date.month ?? 1) * 100 + (date.day ?? 1)
}

export function formatHistoricalDate(date: HistoricalDate): string {
  if (date.label) return date.label
  const year = date.year < 0 ? `前${Math.abs(date.year)}年` : `${date.year}年`
  if (!date.month) return year
  if (!date.day) return `${year}${date.month}月`
  return `${year}${date.month}月${date.day}日`
}
