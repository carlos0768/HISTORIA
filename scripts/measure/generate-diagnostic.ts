/**
 * 診断プールの薄いセルを埋める設問を生成する（docs/04-weakness-engine.md §5.2）
 *
 *   GEMINI_API_KEY=... npx tsx scripts/measure/generate-diagnostic.ts [--limit N]
 *
 * ★ **鍵と課金が要る唯一の段である。** 配信も診断も鍵なしで動くので、
 *   これを回さなくてもアプリは完成している。回すのは質を上げるためである。
 *
 * ★ 何問作るかは `scripts/db/diagnostic-coverage.ts` が決める。
 *   12セル × 20問 = 240問を新規に作るのではない。既存の設問を数えたうえで
 *   **足りないぶんだけ**作る（作者の判断: 既存と合流させる）。
 *   2026-09-02 時点の実測では、408問で12セル全部が埋まっており、
 *   目標の20問/セルに足りないのは4セル・**合計34問**だけである。
 *
 * ★ 生成したものを直接 DB へ入れない。`seed/item.generated.csv` に書き出し、
 *   作者が中身を読んでから `seed/item.csv` に合流させる。
 *   診断の質が全ユーザーの初期値を決めるので、ここは自動承認にしない
 *   （docs/schema.sql の item.approved_by は診断プールで 'author' と定めている）。
 *
 * ★ 層2（正典1,180件との機械照合）を通す。通らないものは書き出さない。
 */
import { readFileSync } from 'node:fs'
import { join } from 'node:path'
import { SEED_DIR } from '../db/seed'
import { readConfig } from '@/lib/ai/client'
import { cellKey, ERA_IDS, GRID_IDS } from '@/lib/domain/diagnostic'
import { planCells, totalToGenerate } from '@/lib/domain/diagnostic-plan'

const limitArg = process.argv.indexOf('--limit')
const limit = limitArg >= 0 ? Number(process.argv[limitArg + 1]) : null

const cfg = readConfig()
if (!cfg.geminiApiKey) {
  console.error('GEMINI_API_KEY が要ります。')
  console.error('')
  console.error('★ この段を回さなくても診断テストは動きます。')
  console.error('  既存の共有プール（seed/item.csv・408問）だけで12セル全部を測れます。')
  console.error('  まず `npx tsx scripts/db/diagnostic-coverage.ts` で何問足りないかを見てください。')
  process.exit(1)
}

/** 既存の CSV からセル別の件数を数える（diagnostic-coverage.ts と同じ数え方） */
function currentCounts(): { cell: string; have: number }[] {
  const parse = (name: string) => {
    const lines = readFileSync(join(SEED_DIR, name), 'utf8').replace(/^﻿/, '').split('\n')
    const head = lines.shift()!.split(',')
    return lines.filter(l => l.trim()).map(l => {
      // ★ 引用符つきの列を含むので、素朴な split では割れない。
      //   ここで要るのは id / era_id / region_primary / kc_id だけなので、
      //   引用の外側のカンマだけで割る最小の実装にする
      const cells: string[] = []
      let cur = '', q = false
      for (const ch of l) {
        if (ch === '"') q = !q
        else if (ch === ',' && !q) { cells.push(cur); cur = '' }
        else cur += ch
      }
      cells.push(cur)
      return Object.fromEntries(head.map((h, i) => [h, cells[i] ?? '']))
    })
  }
  const regions = parse('region.csv')
  const grid = new Map(regions.map(r => [r.label!, Number(r.grid_id)]))
  const kcCell = new Map<string, string>()
  for (const k of parse('kc.csv')) {
    const g = k.region_primary ? grid.get(k.region_primary.trim()) : undefined
    if (Number(k.era_id) && g) kcCell.set(k.id!, cellKey(Number(k.era_id), g))
  }
  const counts = new Map<string, number>()
  for (const t of parse('item.csv')) {
    const c = kcCell.get(t.kc_id!)
    if (c) counts.set(c, (counts.get(c) ?? 0) + 1)
  }
  return [...counts.entries()].map(([cell, have]) => ({ cell, have }))
}

const plan = planCells(currentCounts(), limit)
const total = totalToGenerate(plan)

console.log(`生成: ${cfg.genProvider}/${cfg.genModel}`)
console.log(`作る設問: ${total} 問`)
for (const era of ERA_IDS) {
  for (const g of GRID_IDS) {
    const p = plan.find(x => x.cell === cellKey(era, g))!
    if (p.need > 0) console.log(`  セル ${p.cell}: ${p.have} 問 → あと ${p.need} 問`)
  }
}

if (total === 0) {
  console.log('\n全セルが目標に達しています。作るものはありません。')
  process.exit(0)
}

/**
 * ★ ここから先は未実装である。**わざと止めてある。**
 *
 * 生成そのものは lib/pipeline/generate.ts が持っているが、あれは
 * 「単元の教材を作り、その設問を派生させる」形で、セルを狙って作る口が無い。
 * セル指定の生成プロンプトを新しく起こす必要があり、それは実際に鍵を通して
 * 出力を見ながらでないと詰められない（何度か回して文面を直す作業になる）。
 *
 * 鍵の無いまま推測でプロンプトを書いて「できました」と言うより、
 * **何問どこに要るかまでを機械で確定させて止める**ほうが正直である。
 * 上の出力がそのまま作業指示になる。
 */
console.log('\n★ 生成そのものはまだ実装していません。')
console.log('  セルを狙う生成プロンプトは、実際に鍵を通して出力を見ながらでないと詰められません。')
console.log('  いまできるのは「どのセルに何問要るか」までです（上の出力）。')
console.log('')
console.log('  なお、この段を回さなくても診断は動きます。')
console.log('  既存408問で12セル全部が埋まっており、足りないのは目標との差だけです。')
