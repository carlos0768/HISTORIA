import { readFile, readdir } from 'node:fs/promises'
import path from 'node:path'
import {
  AtlasBundleSchema,
  AtlasEventSchema,
  AtlasStorySchema,
  type AtlasBundleV1,
} from './schema'

export async function readAtlasBundle(root = path.join(process.cwd(), 'seed', 'atlas')): Promise<AtlasBundleV1> {
  const eventFiles = (await readdir(root)).filter(file => file.endsWith('events.ndjson')).sort()
  const events = (await Promise.all(eventFiles.map(async file => {
    const eventText = await readFile(path.join(root, file), 'utf8')
    return eventText.split(/\r?\n/).filter(Boolean).map((line, index) => {
      try { return AtlasEventSchema.parse(JSON.parse(line)) }
      catch (error) { throw new Error(`${file}:${index + 1}: ${String(error)}`) }
    })
  }))).flat()

  const storyDir = path.join(root, 'stories')
  const storyFiles = (await readdir(storyDir)).filter(file => file.endsWith('.json')).sort()
  const stories = await Promise.all(storyFiles.map(async file => {
    const body = await readFile(path.join(storyDir, file), 'utf8')
    return AtlasStorySchema.parse(JSON.parse(body))
  }))

  return AtlasBundleSchema.parse({
    version: '1.0',
    generatedAt: new Date().toISOString(),
    events,
    stories,
  })
}
