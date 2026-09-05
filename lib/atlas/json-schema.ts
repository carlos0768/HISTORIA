import { z } from 'zod'
import { AtlasBundleSchema } from './schema'

/** 外部取得器とTypeScript実装が同じ制約を使える、Zod由来のJSON Schema。 */
export const AtlasBundleJsonSchema = z.toJSONSchema(AtlasBundleSchema, {
  target: 'draft-2020-12',
  io: 'output',
})
