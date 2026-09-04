/**
 * 本番の DB に教材をまとめて作る
 *
 *   DATABASE_URL='postgresql://...' \
 *   GEMINI_API_KEY=... ANTHROPIC_API_KEY=... VERIFY_MODEL=... \
 *     npx tsx scripts/db/generate-remote.ts                 # 下見だけ（API を呼ばない）
 *     npx tsx scripts/db/generate-remote.ts --limit 10 --apply
 *
 * ★ 下見が既定。`--apply` を付けるまで API を1回も呼ばない。
 *   1本あたり実費が約50円かかるので、`seed-remote.ts` と同じ流儀にする。
 *
 * ★ **止めてよい。再開できる。** 教材は (unit, prompt_version) で冪等で、
 *   既に作った単元は下見の対象から外れる。Ctrl-C で止めて、直してから
 *   続きを流せる。1本ごとに結果を出すのはそのためである。
 *
 * ★ 壊さない。DROP も TRUNCATE も DELETE も書かない。
 *   足すのは material / material_section / item / generation_job / ai_spend だけ。
 */
import postgres from 'postgres'
import { createClient, readConfig } from '@/lib/ai/client'
import { ensureBudgetRow, periodOf, budgetStatus } from '@/lib/ai/budget'
import { generateMaterial, pendingUnits } from '@/lib/pipeline/generate'
import { MATERIAL_PROMPT_VERSION } from '@/lib/ai/prompt'
import { matchRate } from '@/lib/pipeline/factcheck'

const url = process.env.DATABASE_URL
if (!url) {
  console.error('DATABASE_URL が未設定です。')
  console.error("  DATABASE_URL='postgresql://...' npx tsx scripts/db/generate-remote.ts")
  process.exit(1)
}

const apply = process.argv.includes('--apply')
const limitArg = process.argv.indexOf('--limit')
const limit = limitArg >= 0 ? Number(process.argv[limitArg + 1]) : null
const userArg = process.argv.indexOf('--user')
const userOverride = userArg >= 0 ? process.argv[userArg + 1] : null

/**
 * ★ 系統的な失敗で金を燃やさない。鍵の失効・モデル名の誤り・レート制限は
 *   1本目で分かるのに、止めなければ 75 本ぶん同じ失敗を繰り返す。
 */
const ABORT_AFTER_CONSECUTIVE_FAILURES = 3

const cfg = readConfig()
const ai = createClient(cfg)
const usingFake = ai.genProviderName.startsWith('fake:') || ai.verifyProviderName.startsWith('fake:')
/**
 * ★ 鍵を要求するのは `--apply` のときだけ。下見は API を1回も呼ばないので、
 *   何が作られるのかは鍵が無くても読めるべきである。
 *   逆に `--apply` では必ず止める — **フェイクで本番に書き込むと、
 *   でたらめな教材が「検証済み」として配信される**（PR #28 の安全弁と同じ理由）。
 */
if (apply && usingFake) {
  console.error('鍵がありません。フェイクで本番に書き込むと、でたらめな教材が配信されます。')
  console.error(`  生成 ${cfg.genProvider} / 検証 ${cfg.verifyProvider} の両方の鍵が要ります。`)
  process.exit(1)
}

// パスワードは出さない（seed-remote.ts と同じ）
const shown = new URL(url)
shown.password = '***'
console.log(`接続先: ${shown.host}${shown.pathname}`)
console.log(`生成: ${ai.genProviderName}/${cfg.genModel}`)
console.log(`検証: ${ai.verifyProviderName}/${cfg.verifyModel}`)
if (usingFake) console.log('  ※ 鍵が無いので下見のみ。--apply には両方の鍵が要ります')
console.log(`プロンプト: ${MATERIAL_PROMPT_VERSION}\n`)

const db = postgres(url, { prepare: false, max: 2, onnotice: () => {} })

/** 1本あたりの実測（docs/08 §3.4・2026-09-04 の wh.4.1.3） */
const JPY_PER_UNIT = 52
const SEC_PER_UNIT = 195

try {
  const [has] = await db<{ ok: boolean }[]>`SELECT to_regclass('public.kc') IS NOT NULL AS ok`
  if (!has?.ok) {
    console.error('kc 表がありません。先に docs/schema.sql と seed を流してください。')
    process.exit(1)
  }

  /**
   * ★ **中身を見せてから使う。「繋がった」は「正しい DB だ」ではない。**
   *
   *   2026-09-04、作者が**別プロジェクトの接続文字列**を貼った。
   *   名前解決に失敗したので事故にはならなかったが、通っていれば
   *   **無関係な DB に教材10本を書き込んでいた**。この道具は接続先の
   *   ホスト名を出すだけで、そこが正しい DB かを何も確かめていなかった。
   *
   *   ref を焼き込んで判定しない（リポジトリに本番の識別子を書かないため）。
   *   **入っているデータで見分ける。** 見慣れた数字が出れば正しい DB だと
   *   作者が自分で分かる。
   */
  const [c] = await db<{ kc: string; ce: string; pe: string; item: string; unit: string }[]>`
    SELECT (SELECT count(*) FROM kc)                              AS kc,
           (SELECT count(*) FROM canon_event)                     AS ce,
           (SELECT count(*) FROM person)                          AS pe,
           (SELECT count(*) FROM item WHERE user_id IS NULL)      AS item,
           (SELECT count(DISTINCT unit_id) FROM kc_syllabus_unit) AS unit`
  console.log(`中身: kc ${c!.kc} / canon_event ${c!.ce} / person ${c!.pe} / 共有設問 ${c!.item} / KC を持つ節 ${c!.unit}`)
  console.log('  ↑ 見覚えのない数字なら、接続先が違います\n')

  /**
   * ★ 正典が空なら `--apply` させない。層2（正典との機械照合）が
   *   何も照合できないまま 75 本ぶん課金することになる。
   *   2026-09-04 に測定用の道具で同じ穴を踏んでおり（正典を入れ忘れて
   *   照合率 0.0% を出した）、こちらは**お金がかかる側**である。
   */
  if (apply && (c!.ce === '0' || c!.kc === '0')) {
    console.error('正典（canon_event）か KC が空です。接続先が違うか、seed がまだです。')
    console.error('  このまま作ると層2が何も照合できないまま課金だけが進みます。')
    console.error('  DATABASE_URL=... npx tsx scripts/db/check-remote.ts で本番の状態を確かめてください。')
    process.exit(1)
  }

  // 済んだものを除いた一覧。数え方は generate.ts に1箇所だけ持つ
  const pending = await pendingUnits(db)

  const [done] = await db<{ ready: string; blocked: string }[]>`
    SELECT count(*) FILTER (WHERE status = 'ready')   AS ready,
           count(*) FILTER (WHERE status = 'blocked') AS blocked
      FROM material
     WHERE user_id IS NULL AND prompt_version = ${MATERIAL_PROMPT_VERSION}`

  const targets = limit === null ? pending : pending.slice(0, limit)
  console.log(`済み: ready ${done!.ready} / blocked ${done!.blocked}`)
  console.log(`未生成: ${pending.length} 単元` + (limit === null ? '' : `（今回は先頭 ${targets.length} 件）`))
  console.log(`見込み: 約 ${targets.length * JPY_PER_UNIT} 円 / 約 ${Math.round(targets.length * SEC_PER_UNIT / 60)} 分\n`)

  if (targets.length === 0) {
    console.log('作るものがありません。')
    process.exit(0)
  }

  if (!apply) {
    for (const t of targets) console.log(`  ${t.id.padEnd(14)} KC ${String(t.kcs).padStart(2)}  ${t.label}`)
    console.log('\n下見だけで終わります。実行するには --apply を付けてください。')
    console.log('  npx tsx scripts/db/generate-remote.ts --limit 10 --apply')
    process.exit(0)
  }

  const now = new Date()
  await ensureBudgetRow(db, periodOf(now))

  const [u] = userOverride
    ? await db<{ id: string }[]>`SELECT id FROM app_user WHERE id = ${userOverride}`
    : await db<{ id: string }[]>`SELECT id FROM app_user ORDER BY created_at LIMIT 1`
  if (!u) {
    console.error('app_user がありません。--user <uuid> で指定するか、先に1人登録してください。')
    process.exit(1)
  }
  // ★ 誰に紐づくかを出す。設問は user_id 付きで入る（generate.ts）ので、
  //   知らないうちに別人の出題プールへ混ざる、を防ぐ
  console.log(`設問の紐づけ先: ${u.id}\n`)

  let ready = 0, blocked = 0, failed = 0, streak = 0
  const rates: number[] = []
  const t0 = Date.now()

  for (const [i, t] of targets.entries()) {
    const head = `[${String(i + 1).padStart(2)}/${targets.length}] ${t.id.padEnd(14)}`
    const s0 = Date.now()

    // ★ 遮断器が止めていたらそこで終わる。止まっているのに投げ続けない
    const b = await budgetStatus(db, now)
    if (b.halted) {
      console.log(`\n遮断器が停止しています（使用 ${b.usedJpy.toFixed(0)}円 / 上限 ${b.capJpy}円）。ここで止めます。`)
      break
    }

    let r
    try {
      r = await generateMaterial(db, ai, { userId: u.id, unitId: t.id, now: new Date() })
    } catch (e) {
      failed++; streak++
      console.log(`${head} ✗ 例外  ${e instanceof Error ? e.message : String(e)}`)
      if (streak >= ABORT_AFTER_CONSECUTIVE_FAILURES) {
        console.log(`\n${streak} 連続で失敗しました。同じ原因を繰り返している可能性が高いので止めます。`)
        break
      }
      continue
    }

    const sec = ((Date.now() - s0) / 1000).toFixed(0)
    if (r.status === 'ready') {
      ready++; streak = 0
      const rate = matchRate(r.check)
      if (rate !== null) rates.push(rate)
      const pct = rate === null ? '—' : `${(rate * 100).toFixed(0)}%`
      console.log(`${head} ✓ ready    ${String(sec).padStart(3)}秒  設問${String(r.itemCount).padStart(3)}  照合${pct.padStart(4)}  ${t.label}`)
    } else if (r.status === 'blocked') {
      blocked++; streak = 0
      console.log(`${head} ▲ blocked  ${String(sec).padStart(3)}秒  ${t.label}`)
      console.log(`${' '.repeat(head.length)}   ${r.reason.slice(0, 160)}`)
    } else {
      failed++; streak++
      console.log(`${head} ✗ failed   ${String(sec).padStart(3)}秒  ${r.reason.slice(0, 160)}`)
      if (streak >= ABORT_AFTER_CONSECUTIVE_FAILURES) {
        console.log(`\n${streak} 連続で失敗しました。同じ原因を繰り返している可能性が高いので止めます。`)
        break
      }
    }
  }

  const mins = ((Date.now() - t0) / 60000).toFixed(1)
  console.log(`\n結果: ready ${ready} / blocked ${blocked} / failed ${failed}（${mins} 分）`)
  if (rates.length > 0) {
    const mean = rates.reduce((a, b) => a + b, 0) / rates.length
    const under = rates.filter(x => x < 0.8).length
    console.log(`層2の機械照合率: 平均 ${(mean * 100).toFixed(1)}%（目標80% / 下回った教材 ${under}/${rates.length} 本）`)
  }

  const b = await budgetStatus(db, now)
  console.log(`予算: 使用 ${b.usedJpy.toFixed(0)}円 / 上限 ${b.capJpy}円 / 残り ${b.remainingJpy.toFixed(0)}円 / 停止 ${b.halted}`)

  if (blocked > 0) {
    console.log(`\n▲ blocked が ${blocked} 本あります。事実確認で誤りが見つかった教材で、配信されません。`)
    console.log('  中身を見るには:')
    console.log(`    SELECT unit_id, title, blocked_reason FROM material`)
    console.log(`     WHERE user_id IS NULL AND status = 'blocked' ORDER BY generated_at DESC;`)
    console.log('  正典の側が誤っている場合もあります（seed/canon_event.csv を直して作り直す）。')
  }
} finally {
  await db.end({ timeout: 10 })
}
