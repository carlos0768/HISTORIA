/**
 * 地域マスタ（seed/region.csv）を地図上の国の集合に対応させる
 *
 * ★★ ここは暫定である。★★
 *   現在の国境で歴史上の地域を近似しているにすぎない。
 *   アケメネス朝の版図とイラン・イラクの国境は当然一致しない。
 *   デザインと史料が固まったら、この表ごと差し替える前提で書いてある。
 *   差し替えるのはこのファイルだけで済むようにしてある（描画側は触らない）。
 *
 * id は seed/region.csv の id と一致させること。ずれると地図が別の場所を指す。
 * 親地域（ヨーロッパ・西アジア等）は子の和集合として計算する。ここには書かない。
 *
 * 国のコードは ISO 3166-1 の数値。lib/map/basemap.ts の COUNTRY_NAMES で
 * 名前を確認できる。1:110m に無い極小国（マルタ・バーレーン・ルクセンブルク等）と
 * コソボ（world-atlas では id=-99）は入っていない。地域の塗りには影響しない。
 */
import { COUNTRY_NAMES } from './basemap'

export type RegionShape = {
  id: number
  label: string
  /** 子を持つ地域。自分では国を持たず、子の和集合になる */
  isParent: boolean
  /** ISO 3166-1 数値コード。親地域では空 */
  countries: readonly string[]
}

/** 親 → 子の id。seed/region.csv の parent_label に対応する */
const CHILDREN: Readonly<Record<number, readonly number[]>> = {
  1: [2, 3, 4, 5],      // ヨーロッパ
  6: [7, 8],            // アメリカ
  9: [10, 11, 12],      // 西アジア
  13: [14, 15],         // アフリカ
  18: [19, 20],         // 内陸アジア
  21: [22, 23, 24],     // 東アジア
}

const LEAF: Readonly<Record<number, { label: string; countries: readonly string[] }>> = {
  2:  { label: '西欧', countries: ['250','276','826','372','528','056','756','040'] },
  3:  { label: '南欧・地中海', countries: ['380','724','620','300','196'] },
  4:  { label: '東欧・ロシア', countries: ['643','616','804','112','203','703','348','642','100','688','191','070','008','498','440','428','233','705','499'] },
  5:  { label: '北欧', countries: ['578','752','246','208','352'] },
  7:  { label: '北アメリカ', countries: ['840','124'] },
  8:  { label: 'ラテンアメリカ', countries: ['484','076','032','604','152','170','862','068','218','600','858','192','320','340','558','188','591','214','332','388','222','084','328','740','780'] },
  10: { label: 'メソポタミア・イラン', countries: ['368','364'] },
  11: { label: 'アナトリア・シリア', countries: ['792','760','422','376','400','275'] },
  12: { label: 'アラビア半島', countries: ['682','887','512','784','414','634'] },
  14: { label: 'エジプト・北アフリカ', countries: ['818','434','788','012','504','732'] },
  15: { label: 'サハラ以南アフリカ', countries: ['566','231','404','834','800','288','466','686','729','728','706','148','562','120','180','178','024','894','716','508','450','710','072','516','324','854','204','384','430','694','478','140','266','454','646','108','232','262','768','624','270','426'] },
  16: { label: '南アジア', countries: ['356','586','050','144','524','064'] },
  17: { label: '東南アジア', countries: ['764','704','116','418','104','458','360','608','096','626'] },
  19: { label: '中央アジア', countries: ['398','860','795','417','762','004'] },
  20: { label: 'モンゴル高原', countries: ['496'] },
  22: { label: '中国', countries: ['156','158'] },
  23: { label: '朝鮮', countries: ['408','410'] },
  24: { label: '日本', countries: ['392'] },
}

const PARENT_LABEL: Readonly<Record<number, string>> = {
  1: 'ヨーロッパ', 6: 'アメリカ', 9: '西アジア', 13: 'アフリカ', 18: '内陸アジア', 21: '東アジア',
}

function build(): RegionShape[] {
  const out: RegionShape[] = []
  for (const [idStr, leaf] of Object.entries(LEAF)) {
    out.push({ id: Number(idStr), label: leaf.label, isParent: false, countries: leaf.countries })
  }
  for (const [idStr, kids] of Object.entries(CHILDREN)) {
    const id = Number(idStr)
    const countries = [...new Set(kids.flatMap(k => LEAF[k]?.countries ?? []))]
    out.push({ id, label: PARENT_LABEL[id]!, isParent: true, countries })
  }
  return out.sort((a, b) => a.id - b.id)
}

export const REGION_SHAPES: readonly RegionShape[] = build()

const BY_ID = new Map(REGION_SHAPES.map(r => [r.id, r]))
export const regionShape = (id: number): RegionShape | undefined => BY_ID.get(id)

/** 基図に存在しない国コードを指していないか。試験と開発時の確認に使う */
export function unknownCountryCodes(): string[] {
  return [...new Set(REGION_SHAPES.flatMap(r => r.countries))].filter(c => !(c in COUNTRY_NAMES))
}
