/**
 * 地域マスタ（seed/region.csv）を地図上の範囲に対応させる
 *
 * ★★ ここは暫定である。★★
 *   経緯度の枠は「だいたいこのあたり」を示すための仮置きであり、
 *   歴史上の版図でも現在の国境でもない。
 *   地図のデザインが決まったら、この表ごと差し替える前提で書いてある。
 *   差し替えるのはこのファイルだけで済むようにしてある（描画側は触らない）。
 *
 * id は seed/region.csv の id と一致させること。ずれると地図が別の場所を指す。
 * 親地域（ヨーロッパ・アメリカ等）は子の範囲を含む大きな枠にしてある。
 */

/** 経度・緯度の範囲。[西, 南, 東, 北] */
export type RegionBox = readonly [number, number, number, number]

export type RegionShape = {
  id: number
  label: string
  /** 子を持つ地域（ヨーロッパ・西アジア等）。地図では枠を薄くする */
  isParent: boolean
  box: RegionBox
}

export const REGION_SHAPES: readonly RegionShape[] = [
  { id: 1,  label: 'ヨーロッパ',            isParent: true,  box: [-10,  35,  60,  71] },
  { id: 2,  label: '西欧',                  isParent: false, box: [-10,  42,  16,  59] },
  { id: 3,  label: '南欧・地中海',          isParent: false, box: [ -9,  35,  28,  47] },
  { id: 4,  label: '東欧・ロシア',          isParent: false, box: [ 16,  44,  60,  66] },
  { id: 5,  label: '北欧',                  isParent: false, box: [  4,  55,  31,  71] },

  { id: 6,  label: 'アメリカ',              isParent: true,  box: [-170, -55, -34,  72] },
  { id: 7,  label: '北アメリカ',            isParent: false, box: [-168,  25, -52,  72] },
  { id: 8,  label: 'ラテンアメリカ',        isParent: false, box: [-118, -55, -34,  32] },

  { id: 9,  label: '西アジア',              isParent: true,  box: [ 26,  12,  63,  42] },
  { id: 10, label: 'メソポタミア・イラン',  isParent: false, box: [ 38,  25,  63,  40] },
  { id: 11, label: 'アナトリア・シリア',    isParent: false, box: [ 26,  31,  45,  42] },
  { id: 12, label: 'アラビア半島',          isParent: false, box: [ 34,  12,  60,  32] },

  { id: 13, label: 'アフリカ',              isParent: true,  box: [-18, -35,  52,  37] },
  { id: 14, label: 'エジプト・北アフリカ',  isParent: false, box: [-17,  20,  36,  37] },
  { id: 15, label: 'サハラ以南アフリカ',    isParent: false, box: [-18, -35,  52,  18] },

  { id: 16, label: '南アジア',              isParent: false, box: [ 66,   6,  92,  36] },
  { id: 17, label: '東南アジア',            isParent: false, box: [ 92, -10, 141,  24] },

  { id: 18, label: '内陸アジア',            isParent: true,  box: [ 46,  33, 120,  55] },
  { id: 19, label: '中央アジア',            isParent: false, box: [ 46,  35,  88,  50] },
  { id: 20, label: 'モンゴル高原',          isParent: false, box: [ 87,  41, 120,  53] },

  { id: 21, label: '東アジア',              isParent: true,  box: [ 73,  18, 146,  53] },
  { id: 22, label: '中国',                  isParent: false, box: [ 73,  18, 135,  50] },
  { id: 23, label: '朝鮮',                  isParent: false, box: [124,  33, 131,  43] },
  { id: 24, label: '日本',                  isParent: false, box: [129,  31, 146,  46] },
] as const

const BY_ID = new Map(REGION_SHAPES.map(r => [r.id, r]))
export const regionShape = (id: number): RegionShape | undefined => BY_ID.get(id)

/** seed/region.csv と id が食い違っていないかを検査に使う */
export const REGION_IDS: readonly number[] = REGION_SHAPES.map(r => r.id)
