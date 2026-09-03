import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { Screen, Card } from '@/components/ui'
import { NotReady } from '@/components/not-ready'
import { commandsFor } from '@/lib/loop/commands'
import { REGION_SHAPES } from '@/lib/map/regions'
import { MapLoader } from './loader'

export const dynamic = 'force-dynamic'

/**
 * 地図ワークスペース（docs/06-desktop.md 04）
 *
 * ★ 教材に埋まっている地図（components/world-map.tsx）とは別物である。
 *   あちらは「いま読んでいる節の地域を示す小さな図」で、こちらは
 *   「地図そのものを見る場所」。基図の解像度も操作もパン・ズームも違う。
 *
 * ★ 地域は URL で選ぶ（`?region=1&region=7`）。
 *   状態を URL に置けば、見ている範囲をそのまま人に渡せる。
 */
export default async function MapPage({
  searchParams,
}: {
  searchParams: Promise<{ region?: string | string[] }>
}) {
  const db = tryDb()
  const userId = await currentUserId()
  const { region } = await searchParams

  if (!db || !userId) {
    return <Screen title="地図" tab="map"><NotReady /></Screen>
  }

  const asked = (Array.isArray(region) ? region : region ? [region] : [])
    .map(Number)
    .filter(n => Number.isInteger(n))
  // ★ 知らない id は落とす。塗れない id を渡しても静かに何も起きないので、
  //   ここで弾いておくと「選んだのに塗られない」の原因が分かる
  const known = new Set(REGION_SHAPES.map(s => s.id))
  const regionIds = asked.filter(n => known.has(n))

  return (
    <Screen title="地図" tab="map" commands={await commandsFor(db)}>
      <Card>
        <span className="lv-label">地域を塗る</span>
        <form className="hs-report__row" method="get">
          <select className="lv-input" name="region" aria-label="塗る地域">
            <option value="">選ばない</option>
            {REGION_SHAPES.map(s => (
              <option key={s.id} value={s.id}>{s.label}</option>
            ))}
          </select>
          <button type="submit" className="lv-btn">塗る</button>
        </form>
        <p className="lv-caption">
          ドラッグで移動、ホイールで拡大縮小。PNG で保存できます。
        </p>
      </Card>

      <MapLoader regionIds={regionIds} title="世界地図" />
    </Screen>
  )
}
