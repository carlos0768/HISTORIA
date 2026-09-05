/**
 * 手で書いた教材（seed/material/*.json）を、通常の経路に流し込む
 *
 *   DATABASE_URL='postgresql://...' GEMINI_API_KEY=... \
 *     npx tsx scripts/db/seed-material.ts                 # 下見（API を1回も呼ばない）
 *     npx tsx scripts/db/seed-material.ts --apply
 *     npx tsx scripts/db/seed-material.ts wh.4.1.3 --apply
 *
 * ★ **生成だけを差し替える。検証は差し替えない。**
 *   `generateMaterial` をそのまま呼ぶので、層2（正典との機械照合）・層3（Gemini に
 *   よる二次照合）・blocked/ready の判定・設問の投入・generation_job と ai_spend への
 *   記録は API 生成とまったく同じ経路を通る。違うのは MaterialOutput の出どころだけで、
 *   だから API 版と**照合率を直接比べられる**。
 *
 * ★ **Gemini の鍵が要る。** 無いと検証側がフェイクに落ち、generate.ts の安全弁が
 *   「本物で作って偽物で検証した教材を配信しない」で止める。手書き教材でも
 *   未検証のまま配信されることはない。ANTHROPIC_API_KEY は要らない（生成を
 *   API に投げないため）。
 *
 * ★ 壊さない。DROP も TRUNCATE も DELETE も書かない。
 */
import { readdirSync, readFileSync } from 'node:fs'
import { createHash } from 'node:crypto'
import { join } from 'node:path'
import postgres from 'postgres'
import { createClient, readConfig } from '@/lib/ai/client'
import { createAuthoredProvider, AUTHORED_DIR } from '@/lib/ai/authored'
import { ensureBudgetRow, periodOf } from '@/lib/ai/budget'
import { generateMaterial } from '@/lib/pipeline/generate'
import { matchRate } from '@/lib/pipeline/factcheck'
import { MATERIAL_PROMPT_VERSION } from '@/lib/ai/prompt'

const url = process.env.DATABASE_URL
if (!url) {
  console.error('DATABASE_URL が未設定です。')
  process.exit(1)
}

const argv = process.argv.slice(2)
const apply = argv.includes('--apply')
const only = argv.filter(a => !a.startsWith('--'))

/** material.model に記録する。「Claude Code のセッションで書いた」を表す */
const AUTHORED_MODEL = 'claude-code'

const files = readdirSync(AUTHORED_DIR)
  .filter(f => f.endsWith('.json'))
  .map(f => f.replace(/\.json$/, ''))
  .filter(u => only.length === 0 || only.includes(u))
  .sort()

if (files.length === 0) {
  console.error(`${AUTHORED_DIR} に教材がありません。`)
  process.exit(1)
}

const cfg = readConfig()
/**
 * ★ genModel を差し替える。ここを既定のままにすると material.model に
 *   `claude-opus-5` と記録され、**API で作ったことになってしまう**。
 *   docs/10 §8 は来歴を証明できることを求めており、来歴の嘘は最も避けたい種類の嘘である。
 */
const authoredCfg = { ...cfg, genModel: AUTHORED_MODEL }

const shown = new URL(url)
shown.password = '***'
console.log(`接続先: ${shown.host}${shown.pathname}`)
console.log(`検証: ${cfg.verifyProvider}/${cfg.verifyModel}`)
console.log(`プロンプト版: ${MATERIAL_PROMPT_VERSION}（手書きも同じ契約に従う）`)
console.log(`教材: ${files.length} 件  ${files.join(' / ')}\n`)

const db = postgres(url, { prepare: false, max: 2, onnotice: () => {} })

try {
  const [c] = await db<{ kc: string; ce: string; pe: string; unit: string }[]>`
    SELECT (SELECT count(*) FROM kc)                              AS kc,
           (SELECT count(*) FROM canon_event)                     AS ce,
           (SELECT count(*) FROM person)                          AS pe,
           (SELECT count(DISTINCT ku.unit_id) FROM kc_syllabus_unit ku
              JOIN kc k ON k.id = ku.kc_id AND NOT k.retired)     AS unit`
  console.log(`中身: kc ${c!.kc} / canon_event ${c!.ce} / person ${c!.pe} / 教材を作る節 ${c!.unit}`)
  console.log('  ↑ 見覚えのない数字なら、接続先が違います\n')

  // ★ 正典が空なら層2が何も照合できない。手書き教材でこそ照合率が知りたいので拒む
  if (c!.ce === '0' || c!.kc === '0') {
    console.error('正典（canon_event）か KC が空です。先に seed-remote.ts を流してください。')
    process.exit(1)
  }

  for (const unitId of files) {
    const path = join(AUTHORED_DIR, `${unitId}.json`)
    const text = readFileSync(path, 'utf8')
    const sha = createHash('sha256').update(text).digest('hex').slice(0, 12)
    const [u] = await db<{ label: string }[]>`SELECT label FROM syllabus_unit WHERE id = ${unitId}`
    console.log(`  ${unitId.padEnd(12)} ${sha}  ${u?.label ?? '（節が見つかりません）'}`)
  }

  if (!apply) {
    console.log('\n下見だけで終わります。投入するには --apply を付けてください。')
    console.log('  DATABASE_URL=... GEMINI_API_KEY=... npx tsx scripts/db/seed-material.ts --apply')
    process.exit(0)
  }

  const now = new Date()
  await ensureBudgetRow(db, periodOf(now))

  const [user] = await db<{ id: string }[]>`SELECT id FROM app_user ORDER BY created_at LIMIT 1`
  if (!user) {
    console.error('app_user がありません。先に1人登録してください。')
    process.exit(1)
  }
  console.log(`\n設問の紐づけ先: ${user.id}\n`)

  let ready = 0, blocked = 0, failed = 0
  const rates: number[] = []

  for (const unitId of files) {
    const text = readFileSync(join(AUTHORED_DIR, `${unitId}.json`), 'utf8')
    const sha = createHash('sha256').update(text).digest('hex').slice(0, 12)

    // ★ 単元ごとにプロバイダを作る。1プロバイダ1単元（authored.ts の注記）。
    //   差し替えるのは**生成だけ**。検証は authoredCfg の verifyProvider（Gemini）が
    //   そのまま担うので、層3は消えない
    const ai = createClient(authoredCfg, {}, {
      gen: createAuthoredProvider({ unitId, model: AUTHORED_MODEL }),
    })

    const head = `${unitId.padEnd(12)}`
    const t0 = Date.now()
    let r
    try {
      r = await generateMaterial(db, ai, { userId: user.id, unitId, now: new Date(), force: true })
    } catch (e) {
      failed++
      console.log(`${head} ✗ 例外  ${e instanceof Error ? e.message : String(e)}`)
      continue
    }
    const sec = ((Date.now() - t0) / 1000).toFixed(0)

    if (r.status === 'ready') {
      ready++
      const rate = matchRate(r.check)
      if (rate !== null) rates.push(rate)
      const pct = rate === null ? '—' : `${(rate * 100).toFixed(0)}%`
      console.log(`${head} ✓ ready    ${sec.padStart(3)}秒  設問${String(r.itemCount).padStart(3)}  照合${pct.padStart(4)}`)
      await recordProvenance(r.materialId, sha)
    } else if (r.status === 'blocked') {
      blocked++
      console.log(`${head} ▲ blocked  ${sec.padStart(3)}秒`)
      console.log(`${' '.repeat(head.length)}   ${r.reason.slice(0, 200)}`)
      await recordProvenance(r.materialId, sha)
    } else {
      failed++
      console.log(`${head} ✗ failed   ${sec.padStart(3)}秒  ${r.reason.slice(0, 200)}`)
    }
  }

  console.log(`\n結果: ready ${ready} / blocked ${blocked} / failed ${failed}`)
  if (rates.length > 0) {
    const mean = rates.reduce((a, b) => a + b, 0) / rates.length
    console.log(`層2の機械照合率: 平均 ${(mean * 100).toFixed(1)}%（目標80%）`)
    console.log('  ★ 同じ単元の API 版と比べてください。差がこの試みの答えです。')
  }
} finally {
  await db.end({ timeout: 10 })
}


/**
 * 来歴を残す（docs/10 §8）。
 * ★ 何のファイルから入れたかを sha で残す。後から中身を差し替えても辿れる
 */
async function recordProvenance(materialId: string, sha: string): Promise<void> {
  await db`
    UPDATE material
       SET human_edit_log = human_edit_log || ${db.json([{
         at: new Date().toISOString(),
         by: 'author',
         action: 'seed_authored_material',
         source: 'seed/material',
         sha256_12: sha,
       }] as never)}::jsonb
     WHERE id = ${materialId}`
}
