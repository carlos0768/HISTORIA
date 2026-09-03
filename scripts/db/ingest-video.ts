/**
 * YouTube から動画の候補を集めて seed/video.csv に書き出す
 *
 *   YOUTUBE_API_KEY=... npx tsx scripts/db/ingest-video.ts            # 何も書かない（確認だけ）
 *   YOUTUBE_API_KEY=... npx tsx scripts/db/ingest-video.ts --apply
 *
 * ★ **鍵が要るのはここだけである。** 配信側は video テーブルから返すだけなので
 *   鍵なしで完全に動く（docs/09b V1）。この道具は「作者が一度だけ回す」ものである。
 *
 * ★ 検索しない。channel_allowlist に載っているチャンネルの
 *   アップロード再生リストだけを見る（V2）。search.list は1回100ユニットで、
 *   1日の枠 10,000 をすぐ使い切る。
 *
 * ★ **承認欄は空で書き出す。** 取り込みは候補集めであって承認ではない（V4）。
 *   作者が実際に観てから ○ を入れる。
 *
 * ★ embeddable = false と ytAgeRestricted は**書き出さない**（V5）。
 *   落とした数は表示する。黙って減っていると、なぜ少ないのか分からない。
 *
 * クォータ: channels.list(1) × N + playlistItems.list(1) × ページ数 + videos.list(1) × ページ数。
 * チャンネル15本・各60本で約135ユニット（1日の枠の 1.4%）。
 */
import { writeFileSync } from 'node:fs'
import { join } from 'node:path'
import { readCsv } from './csv'
import { SEED_DIR } from './seed'
import { fetchWithRetry } from '@/lib/ai/http'

const API = 'https://www.googleapis.com/youtube/v3'

export type RawVideo = {
  id: string
  channelId: string
  title: string
  description: string
  durationSec: number
  publishedAt: string
  embeddable: boolean
  ytRating: string | null
}

/** ISO 8601 の再生時間（PT1H2M3S）を秒に直す */
export function durationToSec(iso: string): number {
  const m = /^P(?:(\d+)D)?T?(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?$/.exec(iso)
  if (!m) return 0
  const [, d, h, mi, s] = m
  return Number(d ?? 0) * 86400 + Number(h ?? 0) * 3600 + Number(mi ?? 0) * 60 + Number(s ?? 0)
}

/** 埋め込んでよい動画か（V5）。DB の CHECK と同じ条件をここでも見る */
export const isEmbeddable = (v: { embeddable: boolean; ytRating: string | null }): boolean =>
  v.embeddable && v.ytRating !== 'ytAgeRestricted'

type Json = Record<string, unknown>
const get = async (path: string, params: Record<string, string>, key: string): Promise<Json> => {
  const q = new URLSearchParams({ ...params, key })
  const res = await fetchWithRetry(`${API}/${path}?${q}`, { method: 'GET' }, { provider: 'youtube' })
  return await res.json() as Json
}

/** チャンネルの「アップロード」再生リストの id を引く */
export async function uploadsPlaylist(channelId: string, key: string): Promise<string | null> {
  const j = await get('channels', { part: 'contentDetails', id: channelId }, key)
  const items = (j.items ?? []) as Json[]
  const rel = (items[0]?.contentDetails as Json | undefined)?.relatedPlaylists as Json | undefined
  return (rel?.uploads as string | undefined) ?? null
}

/** 再生リストから動画 id を集める（1ページ50件） */
export async function playlistVideoIds(
  playlistId: string, key: string, max: number,
): Promise<string[]> {
  const ids: string[] = []
  let pageToken: string | undefined
  while (ids.length < max) {
    const j = await get('playlistItems', {
      part: 'contentDetails', playlistId, maxResults: '50',
      ...(pageToken ? { pageToken } : {}),
    }, key)
    for (const it of (j.items ?? []) as Json[]) {
      const id = (it.contentDetails as Json | undefined)?.videoId as string | undefined
      if (id) ids.push(id)
    }
    pageToken = j.nextPageToken as string | undefined
    if (!pageToken) break
  }
  return ids.slice(0, max)
}

/** 動画のメタデータを引く（1ページ50件）。M10 が「取れること」を確かめる項目 */
export async function videoDetails(ids: string[], key: string): Promise<RawVideo[]> {
  const out: RawVideo[] = []
  for (let i = 0; i < ids.length; i += 50) {
    const j = await get('videos', {
      part: 'snippet,contentDetails,status', id: ids.slice(i, i + 50).join(','),
    }, key)
    for (const it of (j.items ?? []) as Json[]) {
      const sn = it.snippet as Json
      const cd = it.contentDetails as Json
      const st = it.status as Json
      out.push({
        id: it.id as string,
        channelId: sn.channelId as string,
        title: sn.title as string,
        description: ((sn.description as string | undefined) ?? '').slice(0, 300),
        durationSec: durationToSec((cd.duration as string | undefined) ?? ''),
        publishedAt: (sn.publishedAt as string | undefined) ?? '',
        embeddable: (st.embeddable as boolean | undefined) ?? false,
        ytRating: ((cd.contentRating as Json | undefined)?.ytRating as string | undefined) ?? null,
      })
    }
  }
  return out
}

const q = (v: string): string => (/[",\n]/.test(v) ? `"${v.replaceAll('"', '""')}"` : v)

/** seed/video.csv の中身を組み立てる。承認欄は空のまま */
export function toCsv(videos: RawVideo[]): string {
  const head = 'approve,id,channel_id,title,description,duration_sec,published_at,embeddable,yt_rating,note'
  const rows = videos.map(v => [
    '', v.id, v.channelId, q(v.title), q(v.description), String(v.durationSec),
    v.publishedAt, String(v.embeddable), v.ytRating ?? '', '',
  ].join(','))
  return [head, ...rows].join('\n') + '\n'
}

if (process.argv[1]?.endsWith('ingest-video.ts')) {
  const key = process.env.YOUTUBE_API_KEY
  if (!key) {
    console.error('YOUTUBE_API_KEY が未設定です。')
    console.error('')
    console.error('★ 配信には要りません。docs/09b V1 のとおり、実行時に YouTube を呼ばないためです。')
    console.error('  この道具は候補を集めて seed/video.csv に書き出すだけの、作者が一度回すものです。')
    console.error('  Google Cloud で YouTube Data API v3 を有効にして鍵を作ってください。')
    process.exit(1)
  }
  const perChannel = Number(process.env.PER_CHANNEL ?? 60)
  const channels = readCsv(join(SEED_DIR, 'channel_allowlist.csv')).filter(c => c.approve === '○')
  if (channels.length === 0) {
    console.error('承認済みのチャンネルがありません。')
    console.error('  seed/channel_allowlist.csv の approve に ○ を入れてください（docs/09b V4）。')
    process.exit(1)
  }

  const all: RawVideo[] = []
  for (const c of channels) {
    const pl = await uploadsPlaylist(c.id!, key)
    if (!pl) { console.error(`  ${c.channel_title}: 再生リストが引けません（${c.id}）`); continue }
    const ids = await playlistVideoIds(pl, key, perChannel)
    const details = await videoDetails(ids, key)
    console.log(`  ${c.channel_title}: ${details.length} 本`)
    all.push(...details)
  }

  const safe = all.filter(isEmbeddable)
  console.log('')
  console.log(`集めた ${all.length} 本 / 埋め込める ${safe.length} 本（落とした ${all.length - safe.length} 本）`)
  console.log('  落とした理由: embeddable = false または年齢制限（docs/09b V5）')

  if (!process.argv.includes('--apply')) {
    console.log('\n書き出すには --apply を付けてください。')
    process.exit(0)
  }
  const path = join(SEED_DIR, 'video.csv')
  const before = readCsv(path)
  writeFileSync(path, toCsv(safe))
  console.log(`\n${path} に書き出した（${before.length} → ${safe.length} 行）`)
  console.log('★ 承認欄は空です。実際に観てから ○ を入れてください（docs/09b V4）。')
  console.log('  そのあと video_kc.csv に KC との対応を書きます。')
}
