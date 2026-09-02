/**
 * 承認欄を埋める（kc / canon_event / person / item / channel_allowlist / video の各 csv）
 *
 *   npx tsx scripts/db/approve-kc.ts --all                    … kc.csv の未記入を全て ○ に
 *   npx tsx scripts/db/approve-kc.ts --all --except a.b,c.d   … 挙げた id だけ空欄のまま残す
 *   npx tsx scripts/db/approve-kc.ts --ids a.b,c.d            … 挙げた id だけ ○ にする
 *   npx tsx scripts/db/approve-kc.ts --reject a.b             … 挙げた id を × にする
 *   npx tsx scripts/db/approve-kc.ts --file canon_event --all … 正典イベントを承認する
 *   npx tsx scripts/db/approve-kc.ts --file person --all      … 正典人物を承認する
 *   npx tsx scripts/db/approve-kc.ts --file item --all        … 共有設問を承認する
 *
 * ★ 承認は作者の判断である（docs/02 §5）。この道具は「作者が下した判断を
 *   CSV へ書き写す」だけで、承認そのものを代行しない。
 *   だから --all にも明示の指定が要る。既定では何もしない。
 *
 * ★ 列の順序と引用は csv モジュールを通さず、元の行をそのまま使って
 *   1文字目だけ差し替える。書き戻しで表記が揺れると差分が読めなくなるためである。
 *
 * ★ どの CSV も先頭2列が `approve,id` なので、同じ関数で扱える。
 *   別々の道具を作ると、片方だけ直したときに挙動が食い違う。
 */
import { readFileSync, writeFileSync } from 'node:fs'
import { join } from 'node:path'
import { SEED_DIR } from './seed'

/** 承認欄を持つ CSV。先頭2列が approve,id であること */
export const APPROVABLE = ['kc', 'canon_event', 'person', 'item', 'channel_allowlist', 'video'] as const
export type Approvable = typeof APPROVABLE[number]
export const csvPath = (name: Approvable): string => join(SEED_DIR, `${name}.csv`)

export const KC_CSV = csvPath('kc')

export type ApproveOpts = {
  all?: boolean
  ids?: Set<string>
  except?: Set<string>
  reject?: Set<string>
}
export type ApproveResult = {
  lines: string[]
  approved: number
  rejected: number
  kept: number
  missing: string[]
}

/**
 * 承認欄を書き換えた行の並びを返す。ファイルには触らない（試験できるようにするため）。
 *
 * ★ 列の順序と引用は csv モジュールを通さず、元の行の1文字目だけを差し替える。
 *   書き戻しで表記が揺れると、380行の差分が読めなくなるためである。
 * ★ 既に ○ か × が入っている行には触らない。作者が一度下した判断を上書きしない。
 */
export function applyApprovals(lines: string[], opts: ApproveOpts): ApproveResult {
  const ids = opts.ids ?? new Set<string>()
  const except = opts.except ?? new Set<string>()
  const reject = opts.reject ?? new Set<string>()
  let approved = 0, rejected = 0, kept = 0
  const known = new Set<string>()

  const out = lines.map((line, i) => {
    if (i === 0 || line.trim() === '') return line
    const comma = line.indexOf(',')
    if (comma < 0) return line
    const id = line.split(',')[1] ?? ''
    known.add(id)
    const rest = line.slice(comma)
    const current = line.slice(0, comma)

    if (reject.has(id)) { rejected++; return '×' + rest }
    if (current === '○' || current === '×') { kept++; return line }
    if (ids.has(id) || (opts.all && !except.has(id))) { approved++; return '○' + rest }
    return line
  })

  // 指定した id が実在しないのは、たいてい打ち間違いである。黙って無視しない
  const missing = [...ids, ...except, ...reject].filter(x => !known.has(x))
  return { lines: out, approved, rejected, kept, missing }
}

if (process.argv[1]?.endsWith('approve-kc.ts')) {
  const argv = process.argv.slice(2)
  const flag = (name: string): string | undefined => {
    const i = argv.indexOf(name)
    return i >= 0 ? (argv[i + 1] ?? '') : undefined
  }
  const list = (v: string | undefined): Set<string> =>
    new Set((v ?? '').split(',').map(s => s.trim()).filter(Boolean))

  const target = (flag('--file') ?? 'kc') as Approvable
  if (!APPROVABLE.includes(target)) {
    console.error(`--file は ${APPROVABLE.join(' / ')} のいずれかです（指定: "${target}"）`)
    process.exit(1)
  }
  const path = csvPath(target)

  const opts: ApproveOpts = {
    all: argv.includes('--all'),
    ids: list(flag('--ids')),
    except: list(flag('--except')),
    reject: list(flag('--reject')),
  }
  if (!opts.all && opts.ids!.size === 0 && opts.reject!.size === 0) {
    console.error('何もしていません。--all か --ids か --reject を指定してください。')
    console.error('  npx tsx scripts/db/approve-kc.ts --all')
    console.error('  npx tsx scripts/db/approve-kc.ts --all --except kc.a.b,kc.c.d')
    console.error('  npx tsx scripts/db/approve-kc.ts --ids kc.a.b')
    console.error('  npx tsx scripts/db/approve-kc.ts --reject kc.a.b')
    console.error('  npx tsx scripts/db/approve-kc.ts --file canon_event --all')
    process.exit(1)
  }

  const r = applyApprovals(readFileSync(path, 'utf8').split('\n'), opts)
  if (r.missing.length) {
    console.error(`次の id が seed/${target}.csv にありません:\n  ${r.missing.join('\n  ')}`)
    process.exit(1)
  }
  writeFileSync(path, r.lines.join('\n'))
  console.log(`seed/${target}.csv:`)
  console.log(`承認 ${r.approved} 件 / 却下 ${r.rejected} 件 / 既に判断済み ${r.kept} 件`)
  console.log('')
  console.log('次にやること:')
  console.log('  node seed/validate.mjs --strict     # 空欄が残っていないか')
  console.log('  npx tsx scripts/db/dump-sql.ts      # seed/sql/02_seed.sql を作り直す')
}
