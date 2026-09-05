/**
 * historical-basemaps（aourednik）が持つ時点の一覧
 *
 * 版図のスナップショットは、この中の年でしか本物の境界を持てない。
 * `geo.year` がここに無ければ試験が落ちる（存在しない年を指して黙って空になるのを防ぐ）。
 *
 * 負値は紀元前（ファイル名は world_bc<n>.geojson）。取得元のコミットは
 * scripts/map/fetch-historical.mjs の HISTORICAL_BASEMAPS_COMMIT を見る。
 */
export const HISTORICAL_YEARS: readonly number[] = [
  -123000, -10000, -8000, -5000, -4000, -3000, -2000, -1500, -1000, -700, -500, -400, -323, -300, -200, -100, -1,
  100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1200, 1279, 1300, 1400, 1492, 1500, 1530, 1600, 1650,
  1700, 1715, 1783, 1800, 1815, 1880, 1900, 1914, 1920, 1930, 1938, 1945, 1960, 1994, 2000, 2010,
]

/** データ側のファイル名。紀元前は bc を付ける */
export const historicalFileName = (year: number): string =>
  year < 0 ? `world_bc${-year}.geojson` : `world_${year}.geojson`

/** 段階の年以下で最も近いデータ側の年。無ければ null（データ側の最古より前） */
export function nearestHistoricalYear(year: number): number | null {
  let best: number | null = null
  for (const y of HISTORICAL_YEARS) if (y <= year && (best === null || y > best)) best = y
  return best
}
