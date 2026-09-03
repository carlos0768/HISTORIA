/**
 * 診断プールが12セルをどれだけ覆っているかを数え、何問足せばよいかを出す
 *
 *   npx tsx scripts/db/diagnostic-coverage.ts
 *
 * ★ 鍵は要らない。CSV を読んで数えるだけである。
 *   生成（scripts/measure/generate-diagnostic.ts）を回す前に、
 *   **何をどれだけ作るのか**を先に確かめるためのもの。
 *
 * ★ 数えるのは seed/item.csv と seed/kc.csv であって DB ではない。
 *   **作者が手元で承認する前に配分を知りたい**ためである。承認されていない設問は
 *   DB に入らない（scripts/db/seed.ts）ので、DB を見ても答えが出ない。
 *
 *   （以前ここには「本番の DB には遠隔から届かない」とも書いてあった。
 *    2026-09-03 に Supabase の MCP 経由で届くようになったので消した。
 *    届く／届かないは、この道具が CSV を見る理由ではない。）
 */
import { readFileSync } from 'node:fs'
import { join } from 'node:path'
import { SEED_DIR } from './seed'
import { cellKey, ERA_IDS, GRID_IDS } from '@/lib/domain/diagnostic'
import { planCells, totalToGenerate, TARGET_PER_CELL } from '@/lib/domain/diagnostic-plan'

/** seed/validate.mjs と同じ最小の CSV 読み。ライブラリを増やさない */
function readCsv(path: string): Record<string, string>[] {
  const text = readFileSync(path, 'utf8').replace(/^﻿/, '')
  const rows: string[][] = []
  let row: string[] = [], cell = '', quoted = false
  for (let i = 0; i < text.length; i++) {
    const c = text[i]
    if (quoted) {
      if (c === '"' && text[i + 1] === '"') { cell += '"'; i++ }
      else if (c === '"') quoted = false
      else cell += c
    } else if (c === '"') quoted = true
    else if (c === ',') { row.push(cell); cell = '' }
    else if (c === '\n') { row.push(cell); rows.push(row); row = []; cell = '' }
    else if (c !== '\r') cell += c
  }
  if (cell || row.length) { row.push(cell); rows.push(row) }
  const head = rows.shift()!
  return rows.filter(r => r.some(v => v !== ''))
    .map(r => Object.fromEntries(head.map((h, i) => [h, r[i] ?? ''])))
}

const kcs = readCsv(join(SEED_DIR, 'kc.csv'))
const items = readCsv(join(SEED_DIR, 'item.csv'))
const regions = readCsv(join(SEED_DIR, 'region.csv'))
const regionGrid = new Map(regions.map(r => [r.label!, Number(r.grid_id)]))

/**
 * KC → セル。
 * ★ kc.csv の `region_primary` は**ラベル**である（region.csv の label と突き合わせる）。
 *   `region_others` は診断のセル判定には使わない。schema.sql の
 *   `kc_region.is_primary` が真の行だけがセルを決める（docs/04 §5.3）。
 */
const kcCell = new Map<string, string>()
let unclassified = 0
for (const k of kcs) {
  const era = Number(k.era_id)
  const primary = k.region_primary?.trim()
  const grid = primary ? regionGrid.get(primary) : undefined
  if (!era || !grid) { unclassified++; continue }
  kcCell.set(k.id!, cellKey(era, grid))
}

const counts = new Map<string, number>()
let itemsUnclassified = 0
for (const t of items) {
  const cell = kcCell.get(t.kc_id!)
  if (!cell) { itemsUnclassified++; continue }
  counts.set(cell, (counts.get(cell) ?? 0) + 1)
}

const plan = planCells([...counts.entries()].map(([cell, have]) => ({ cell, have })))

console.log(`KC ${kcs.length} 件（うちセルに落ちない ${unclassified} 件）`)
console.log(`設問 ${items.length} 件（うちセルに落ちない ${itemsUnclassified} 件）`)
console.log(`目標: 1セル ${TARGET_PER_CELL} 問\n`)

const eraLabel = readCsv(join(SEED_DIR, 'era.csv'))
for (const era of ERA_IDS) {
  const label = eraLabel.find(e => Number(e.id) === era)?.label ?? `時代 ${era}`
  const cells = GRID_IDS.map(g => plan.find(p => p.cell === cellKey(era, g))!)
  console.log(`${label}`)
  for (const [i, c] of cells.entries()) {
    const bar = '█'.repeat(Math.min(20, c.have)).padEnd(20, '·')
    console.log(`  グリッド${GRID_IDS[i]}  ${bar} ${String(c.have).padStart(3)} 問` +
                (c.need > 0 ? ` → あと ${c.need} 問` : ' → 足りている'))
  }
}
console.log(`\n作るべき総数: ${totalToGenerate(plan)} 問`)
if (itemsUnclassified > 0) {
  console.log(`\n★ ${itemsUnclassified} 問がどのセルにも落ちていない。`)
  console.log('  その KC に era_id か primary の地域が付いていない。診断では出題されない。')
}
