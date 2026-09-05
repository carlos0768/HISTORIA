import { readFileSync, readdirSync } from 'node:fs'
import { join } from 'node:path'
import { AtlasBundleSchema, AtlasEventSchema, AtlasStorySchema } from '../../lib/atlas/schema'

export function validateAtlas(root = join(process.cwd(), 'seed', 'atlas'), strictTarget = false) {
  const events = readdirSync(root).filter(file => file.endsWith('events.ndjson')).sort().flatMap(file => {
    const lines = readFileSync(join(root, file), 'utf8').split(/\r?\n/).filter(Boolean)
    return lines.map((line, index) => {
      try { return AtlasEventSchema.parse(JSON.parse(line)) }
      catch (error) { throw new Error(`${file}:${index + 1}: ${String(error)}`) }
    })
  })
  const stories = readdirSync(join(root, 'stories')).filter(file => file.endsWith('.json')).sort()
    .map(file => AtlasStorySchema.parse(JSON.parse(readFileSync(join(root, 'stories', file), 'utf8'))))
  const bundle = AtlasBundleSchema.parse({ version: '1.0', generatedAt: new Date().toISOString(), events, stories })

  if (strictTarget && bundle.events.length < 3000) throw new Error(`公開目標は3000件です（現在 ${bundle.events.length}件）`)
  if (strictTarget && bundle.stories.length < 75) throw new Error(`公開目標は75物語です（現在 ${bundle.stories.length}物語）`)
  return {
    events: bundle.events.length,
    stories: bundle.stories.length,
    steps: bundle.stories.reduce((sum, story) => sum + story.steps.length, 0),
    confidence: Object.fromEntries(['high', 'medium', 'low'].map(level => [
      level, bundle.events.filter(event => event.evidence.confidence === level).length,
    ])),
  }
}

if (process.argv[1]?.endsWith('validate.ts')) {
  const result = validateAtlas(undefined, process.argv.includes('--strict-target'))
  console.log(`Atlas OK: ${result.events} events / ${result.stories} stories / ${result.steps} steps`)
  console.log(result.confidence)
}
