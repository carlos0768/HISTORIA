/**
 * 動画が教材ページまで届くかを予行する。
 *
 *   TEST_DATABASE_URL=postgres://... npx tsx scripts/db/rehearse-video.ts
 *
 * ★ **行が入っただけでは画面に出ない。** 動画は
 *   `video_kc → kc → material_section_kc → 節` と4つ跨いで初めて節に着く。
 *   どこか1つでも繋がっていなければ、DB には 39 本あるのに
 *   ページには1本も出ないという状態になる。数えるだけでは気づけない。
 *
 * ★ `app/material/[id]/page.tsx:72` と同じ呼び方（videosForKcs を
 *   節の kcIds と MAX_PER_SECTION で呼ぶ）をなぞる。
 */
import { readdirSync, readFileSync } from 'node:fs'
import { join } from 'node:path'
import postgres from 'postgres'
import { applySchema } from './schema'
import { seedMasters, seedKc, seedVideo, SEED_DIR } from './seed'
import { AUTHORED_DIR } from '@/lib/ai/authored'
import { parseMaterialOutput } from '@/lib/ai/schema'
import { videosForKcs, MAX_PER_SECTION } from '@/lib/loop/video'

const ADMIN = process.env.TEST_DATABASE_URL
if (!ADMIN) throw new Error('TEST_DATABASE_URL が未設定です')
const NAME = 'historia_video_rehearsal'

const admin = postgres(ADMIN, { prepare: false, max: 1, onnotice: () => {} })
await admin.unsafe(`DROP DATABASE IF EXISTS "${NAME}"`)
await admin.unsafe(`CREATE DATABASE "${NAME}"`)
await admin.end({ timeout: 5 })

const url = new URL(ADMIN)
url.pathname = `/${NAME}`
const db = postgres(url.toString(), { prepare: false, max: 4, onnotice: () => {} })
await applySchema(db, { pgvector: process.env.PGVECTOR !== 'off' })
await seedMasters(db, SEED_DIR)
await seedKc(db, SEED_DIR)
const v = await seedVideo(db, SEED_DIR)
console.log(`入れた: チャンネル ${v.channel} / 動画 ${v.video} / KC の結び ${v.videoKc}` +
  `（承認欄で落とした ${v.skipped} / 埋め込めず落とした ${v.unsafe}）`)

/**
 * 手元の教材の節が持つ KC で引く。教材そのものは入れない
 * （本文は本番と同じものが既に入っている。ここで見たいのは動画の届き方だけ）。
 */
const units = readdirSync(AUTHORED_DIR).filter(f => f.endsWith('.json')).sort()
let sectionsWithVideo = 0
let unitsWithVideo = 0
let cards = 0
const reached: string[] = []
for (const f of units) {
  const parsed = parseMaterialOutput(JSON.parse(readFileSync(join(AUTHORED_DIR, f), 'utf8')))
  if (!parsed.success) continue
  let hit = 0
  for (const s of parsed.data.sections) {
    const got = await videosForKcs(db, s.kc_ids, MAX_PER_SECTION)
    if (got.length > 0) { sectionsWithVideo++; hit++; cards += got.length }
  }
  if (hit > 0) { unitsWithVideo++; reached.push(f.replace(/\.json$/, '')) }
}

// ★ 1本も届かない動画がいないか。入れたのに誰にも出ないなら、結ぶ KC を間違えている
const [orphan] = await db<{ n: string }[]>`
  SELECT count(*)::text AS n FROM video v
   WHERE v.status = 'approved'
     AND NOT EXISTS (SELECT 1 FROM video_kc vk WHERE vk.video_id = v.id)`

console.log(`\n届いた単元 ${unitsWithVideo}/${units.length}`)
console.log(`届いた節 ${sectionsWithVideo}／出る動画カード ${cards} 枚`)
console.log(`どの節にも出ない動画 ${orphan!.n} 本`)
console.log(`単元: ${reached.join(' ')}`)

const ok = v.video > 0 && unitsWithVideo > 0 && orphan!.n === '0'
console.log(ok ? '\n✓ 画面に出ます' : '\n✗ 画面に出ません')
await db.end({ timeout: 5 })
process.exit(ok ? 0 : 1)
