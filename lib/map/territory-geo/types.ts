/**
 * 版図の境界データの型（lib/map/territory-geo/<国家id>.ts が持つもの）
 *
 * 生成物は scripts/map/build-territories.mjs が作る。手で編集しない。
 * 出典: historical-basemaps（A. Ourednik、GPL-3.0）。同ディレクトリの LICENSE と README.md を見る。
 */

export type TerritoryPath = {
  /** 基図と同じ投影（Natural Earth 1、660×340）で焼いたパス。`M…Z` のみ */
  d: string
  /** historical-basemaps の BORDERPRECISION の最小値。1=概略、2=中程度、3=国際法で確定 */
  precision: 1 | 2 | 3
  /** 合わせたフィーチャの NAME（重複なし・並び順固定） */
  names: readonly string[]
}

/** データ側の年 → パス */
export type TerritoryPaths = Readonly<Record<number, TerritoryPath>>

export type TerritoryGeoModule = { TERRITORY_PATHS: TerritoryPaths }
