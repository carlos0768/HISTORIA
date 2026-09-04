/**
 * 事実確認で止まった教材を、作者の判断で配信可能にする
 *
 *   DATABASE_URL='postgresql://...' \
 *     npx tsx scripts/db/approve-material.ts                    # 止まっている教材の一覧
 *     npx tsx scripts/db/approve-material.ts wh.4.1.3           # 中身を読む（下見）
 *     npx tsx scripts/db/approve-material.ts wh.4.1.3 --full    # 本文も全部読む
 *     npx tsx scripts/db/approve-material.ts wh.4.1.3 --apply --note "1614年10月招集で正しい"
 *
 * ★ 下見が既定。`--apply` と `--note` の両方が揃うまで1行も書き換えない。
 *   `generate-remote.ts` / `seed-remote.ts` と同じ流儀である。
 *
 * ★ **判断するのは作者であって、この道具ではない。** ここがやるのは
 *   「読むべきものを全部出す」ことと「決めたことを記録する」ことだけである。
 *   だから理由（--note）を省略できない。docs/10 §8 の human_edit_log は
 *   「人間による編集・監修の痕跡」として置かれており、理由の無い承認は
 *   痕跡にならない。
 *
 * ★ 壊さない。DROP も TRUNCATE も DELETE も書かない。
 *   動かすのは material.status / supersedes_id / human_edit_log と
 *   item.approved の4列だけである。
 */
import postgres from 'postgres'
import {
  approvalTarget, approveMaterial, blockedMaterialsForUnit, MAX_NOTE_CHARS,
} from '@/lib/loop/approve'
import { blockedMaterials } from '@/lib/loop/admin'

const url = process.env.DATABASE_URL
if (!url) {
  console.error('DATABASE_URL が未設定です。')
  console.error("  DATABASE_URL='postgresql://...' npx tsx scripts/db/approve-material.ts")
  process.exit(1)
}

const argv = process.argv.slice(2)
const apply = argv.includes('--apply')
const full = argv.includes('--full')
const noteAt = argv.indexOf('--note')
const note = noteAt >= 0 ? (argv[noteAt + 1] ?? '') : ''
// 旗でもなく --note の値でもない、最初のもの。単元 id か教材の uuid
// ★ --note が無いときは noteAt が -1 になる。noteAt + 1 をそのまま使うと
//   添字 0 を除いてしまい、`approve-material.ts wh.4.1.3` が一覧表示に落ちる
const noteValueAt = noteAt >= 0 ? noteAt + 1 : -1
const target = argv.find((a, i) => !a.startsWith('--') && i !== noteValueAt) ?? null

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i

// パスワードは出さない（seed-remote.ts と同じ）
const shown = new URL(url)
shown.password = '***'
console.log(`接続先: ${shown.host}${shown.pathname}\n`)

const db = postgres(url, { prepare: false, max: 2, onnotice: () => {} })

const rule = (s: string) => console.log(`\n── ${s} ${'─'.repeat(Math.max(0, 60 - s.length))}`)

try {
  // ---- 対象を指定しなければ一覧を出す ----
  if (target === null) {
    const rows = await blockedMaterials(db, 50)
    if (rows.length === 0) {
      console.log('事実確認で止まっている教材はありません。')
      process.exit(0)
    }
    console.log(`事実確認で止まっている教材 ${rows.length} 本:\n`)
    for (const b of rows) {
      const day = b.createdAt.toLocaleDateString('ja-JP', { timeZone: 'Asia/Tokyo' })
      console.log(`  ${b.unitId.padEnd(14)} ${day}`)
      console.log(`    ${b.reason ?? '理由の記録がありません'}`)
    }
    console.log('\n中身を読むには単元 id を渡してください:')
    console.log(`  DATABASE_URL=... npx tsx scripts/db/approve-material.ts ${rows[0]!.unitId}`)
    process.exit(0)
  }

  // ---- 単元 id なら教材を1本に絞る ----
  let materialId = target
  if (!UUID.test(target)) {
    const found = await blockedMaterialsForUnit(db, target)
    if (found.length === 0) {
      console.error(`${target} に、事実確認で止まっている教材はありません。`)
      console.error('  一覧は引数なしで出ます。単元 id が正しいかも確かめてください。')
      process.exit(1)
    }
    if (found.length > 1) {
      // ★ 黙って新しい方を選ばない。共有版と個別版が両方止まっていることがある
      console.error(`${target} に止まっている教材が ${found.length} 本あります。id で指定してください:`)
      for (const f of found) {
        const who = f.userId === null ? '共有' : `個別(${f.userId})`
        console.error(`  ${f.id}  ${who}  ${f.generatedAt.toISOString()}`)
      }
      process.exit(1)
    }
    materialId = found[0]!.id
  }

  const t = await approvalTarget(db, materialId)
  if (!t) {
    console.error(`教材 ${materialId} が見つかりません。`)
    process.exit(1)
  }

  // ---- 読むべきものを全部出す ----
  console.log(`${t.unitId}  ${t.unitLabel}`)
  console.log(`  題       : ${t.title}`)
  console.log(`  状態     : ${t.status}${t.userId === null ? '（共有教材・全員が読む）' : `（${t.userId} だけの教材）`}`)
  console.log(`  作った所 : ${t.provider} / ${t.model} / ${t.promptVersion}`)
  console.log(`  作った時 : ${t.generatedAt.toLocaleString('ja-JP', { timeZone: 'Asia/Tokyo' })}`)
  console.log(`  設問     : ${t.itemCount} 問（うち承認済み ${t.approvedItemCount}）`)
  console.log(`  本文     : ${t.sections.reduce((n, s) => n + s.charCount, 0)} 字 / ${t.sections.length} 節`)

  rule('事実確認が付けた指摘')
  console.log(t.reason ?? '（理由の記録がありません）')
  console.log('\n★ ここが判断の対象である。指摘の方が誤っていることもある。')
  console.log('  正典（canon_event）の側が誤っているなら seed/canon_event.csv を直す方が筋が良い。')

  rule(full ? '本文（全文）' : '本文（各節の冒頭 200 字。全文は --full）')
  for (const s of t.sections) {
    console.log(`\n§${s.ord} ${s.heading}  (${s.charCount}字)`)
    console.log(full ? s.bodyMd : s.bodyMd.slice(0, 200) + (s.bodyMd.length > 200 ? ' …' : ''))
  }

  if (t.editLog.length > 0) {
    rule('これまでの人手の記録')
    for (const e of t.editLog) console.log(`  ${JSON.stringify(e)}`)
  }

  rule('配信可能にすると起きること')
  console.log(`  material ${t.id}`)
  console.log('    status         blocked → ready')
  console.log('    human_edit_log 承認の理由を1件積む（消さない）')
  if (t.supersedes) {
    const day = t.supersedes.generatedAt.toLocaleDateString('ja-JP', { timeZone: 'Asia/Tokyo' })
    console.log(`  いま配信中の「${t.supersedes.title}」(${day}) を superseded にして入れ替えます`)
  }
  const toOpen = t.itemCount - t.approvedItemCount
  console.log(`  item ${toOpen} 問を approved = true / approved_by = 'author' にします`)
  console.log("    ★ 'factcheck' とは書きません。事実確認は通っていないからです")
  console.log('  blocked_reason は消しません（記録として残ります。学習者には出ません）')

  const usage = () => {
    console.log(`  DATABASE_URL=... npx tsx scripts/db/approve-material.ts ${target} \\`)
    console.log('    --apply --note "なぜこの指摘を退けて配信してよいと判断したか"')
  }
  if (apply && note.trim().length === 0) {
    console.error('\n--apply に --note が付いていません。理由の無い承認は記録になりません。')
    usage()
    process.exit(1)
  }
  if (!apply) {
    console.log('\n下見だけで終わります。配信可能にするには理由を添えてください:')
    usage()
    process.exit(0)
  }
  if (note.trim().length > MAX_NOTE_CHARS) {
    console.error(`\n--note が長すぎます（${MAX_NOTE_CHARS} 字まで）。`)
    process.exit(1)
  }

  const r = await approveMaterial(db, { materialId: t.id, note, now: new Date() })
  if (!r.approved) {
    console.error(`\n✗ ${r.reason}`)
    process.exit(1)
  }
  console.log(`\n✓ 配信可能にしました。設問 ${r.items} 問を開けました。`)
  if (r.supersededId) console.log(`  ${r.supersededId} を superseded にしました。`)
  console.log(`  理由: ${note.trim()}`)
} finally {
  await db.end({ timeout: 10 })
}
