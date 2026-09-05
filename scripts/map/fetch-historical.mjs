/**
 * 版図の元データ（historical-basemaps の GeoJSON）を取ってくる
 *
 *   node scripts/map/fetch-historical.mjs 1700 1880 1914     # 指定した年だけ
 *   node scripts/map/fetch-historical.mjs                    # 引数なし: lib/map/territories.ts が指す年を全部
 *
 * 出典: https://github.com/aourednik/historical-basemaps（A. Ourednik）。ライセンスは GPL-3.0。
 *   派生物（lib/map/territory-geo/*.ts）を配信する以上、同ディレクトリに LICENSE の写しを置き、
 *   画面と docs/10 §8 に出典を書く。
 *
 * ★ コミットを固定する。master を追うと、同じ年でも境界が変わり、再生成で差分が出る。
 *   上げるときはここを書き換え、build-territories を流し直して差分を読む。
 * ★ 保存先は gitignore（1本 1.5MB。取り直せるものを版に残さない。/seed/out/ と同じ扱い）。
 * ★ Node の fetch はプロキシの環境変数を見ないので curl を使う（手元と CI の両方で通る）。
 */
import { execFileSync } from 'node:child_process'
import { existsSync, mkdirSync, writeFileSync, statSync } from 'node:fs'
import { join } from 'node:path'

export const HISTORICAL_BASEMAPS_COMMIT = '62d8f1a03a71f2d3ff17f2d166f7553f256bce68'
export const HISTORICAL_BASEMAPS_REPO = 'https://github.com/aourednik/historical-basemaps'
export const DATA_DIR = 'scripts/map/data/historical-basemaps'

const raw = p => `https://raw.githubusercontent.com/aourednik/historical-basemaps/${HISTORICAL_BASEMAPS_COMMIT}/${p}`
const fileName = year => (year < 0 ? `world_bc${-year}.geojson` : `world_${year}.geojson`)

function download(url, to) {
  execFileSync('curl', ['-sSfL', '--retry', '3', url, '-o', to], { stdio: 'inherit' })
}

async function yearsFromTerritories() {
  // tsx で実行されているときだけ TS を読める。素の node なら引数で年を渡す
  const { POLITIES } = await import('../../lib/map/territories.ts')
  const years = new Set()
  for (const p of POLITIES) for (const s of p.snapshots) if (s.geo) years.add(s.geo.year)
  return [...years].sort((a, b) => a - b)
}

const args = process.argv.slice(2).map(Number).filter(n => Number.isInteger(n))
const years = args.length > 0 ? args : await yearsFromTerritories()
if (years.length === 0) {
  console.error('取る年がありません。引数で年を渡すか、territories.ts に geo を付けてください。')
  process.exit(1)
}

mkdirSync(DATA_DIR, { recursive: true })
if (!existsSync(join(DATA_DIR, 'LICENSE'))) download(raw('LICENSE'), join(DATA_DIR, 'LICENSE'))
writeFileSync(join(DATA_DIR, 'SOURCE.md'),
  `# 出典\n\n${HISTORICAL_BASEMAPS_REPO}\n\ncommit: ${HISTORICAL_BASEMAPS_COMMIT}\n取得日: ${new Date().toISOString().slice(0, 10)}\nライセンス: GPL-3.0（LICENSE を参照）\n`)

for (const y of years) {
  const name = fileName(y)
  const to = join(DATA_DIR, name)
  if (existsSync(to)) { console.log(`${name}: あり（${(statSync(to).size / 1024).toFixed(0)}KB）`); continue }
  download(raw(`geojson/${name}`), to)
  console.log(`${name}: 取得（${(statSync(to).size / 1024).toFixed(0)}KB）`)
}
