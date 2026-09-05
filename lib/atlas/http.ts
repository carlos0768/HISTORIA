import { z } from 'zod'
import { AtlasConfidenceSchema } from './schema'

const optionalYear = z.preprocess(value => value === null || value === '' ? undefined : value,
  z.coerce.number().int().min(-10_000).max(2100).refine(year => year !== 0).optional())

export const AtlasEventQuerySchema = z.object({
  q: z.string().trim().max(100).optional(),
  year: optionalYear,
  unit: z.string().regex(/^[a-z0-9.]+$/).optional(),
  confidence: AtlasConfidenceSchema.optional(),
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(50),
})

export const AtlasStoryQuerySchema = z.object({
  q: z.string().trim().max(100).optional(),
  unit: z.string().regex(/^[a-z0-9.]+$/).optional(),
  page: z.coerce.number().int().min(1).default(1),
  limit: z.coerce.number().int().min(1).max(100).default(50),
})

export function searchParamsObject(url: string): Record<string, string> {
  return Object.fromEntries(new URL(url).searchParams.entries())
}
