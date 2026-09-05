/**
 * 版図の境界データの一覧（自動生成。scripts/map/build-territories.mjs が作る。手で編集しない）
 *
 * ★ 動的 import だけ。国家ごとに別 chunk になり、版図を開いたときにその国家の分だけ読む。
 *   静的に import すると全国家分が初回の転送に乗る（components/desktop.test.tsx が見張る）。
 */
import type { TerritoryGeoModule } from './types'

export const TERRITORY_GEO: Readonly<Record<string, () => Promise<TerritoryGeoModule>>> = {
  ottoman: () => import('./ottoman'),
}
