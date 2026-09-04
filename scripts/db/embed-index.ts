/**
 * 教材の中の「調べる」の埋め込み索引を作る（docs/11-ux.md §4.1）
 *
 *   npx tsx scripts/db/embed-index.ts            # 充足率を見るだけ（何もしない）
 *   npx tsx scripts/db/embed-index.ts --apply    # 空の行を埋める
 *
 * kc.embedding と canon_event.embedding のうち NULL の行だけを埋める。
 * 何度流しても同じ（埋まっている行には触れない）。
 *
 * ★ 鍵が無ければ拒む。フェイクの埋め込みは決定的だが意味を持たない乱数で、
 *   それを本番の列に入れると「意味の近さ」がでたらめになる。空のままなら
 *   語の一致だけで動き、画面もそう言う。でたらめが入ると誰も気づけない。
 * ★ 支出遮断器を通る（lib/ai/client.ts の embed）。約1,600件・各20字程度で、
 *   見積りは1円に満たないが、迂回路は作らない。
 */
import postgres from 'postgres'
import { createClient } from '@/lib/ai/client'
import { embedMissing, embedCoverage } from '@/lib/loop/research'

const url = process.env.DATABASE_URL
if (!url) {
  console.error('DATABASE_URL が未設定です。')
  process.exit(1)
}
const apply = process.argv.includes('--apply')

const shown = new URL(url)
shown.password = '***'
console.log(`接続先: ${shown.host}${shown.pathname}`)

const db = postgres(url, { prepare: false, max: 1, onnotice: () => {} })

try {
  const before = await embedCoverage(db)
  const say = (name: string, c: { total: number; embedded: number }) =>
    console.log(`${name}: ${c.embedded} / ${c.total} 件に埋め込みあり（空 ${c.total - c.embedded}）`)
  say('kc         ', before.kc)
  say('canon_event', before.canonEvent)

  if (process.env.PGVECTOR === 'off') {
    console.error('\nPGVECTOR=off です。この DB には vector 型が無いので索引は作れません。')
    process.exit(1)
  }

  const client = createClient()
  if (client.genProviderName.startsWith('fake')) {
    console.error(`\nGEMINI_API_KEY が無いため埋め込みを作れません（いまは ${client.genProviderName}）。`)
    console.error('フェイクの埋め込みは意味を持たない乱数なので、本番の列には入れません。')
    process.exit(1)
  }

  const missing = before.kc.total - before.kc.embedded + before.canonEvent.total - before.canonEvent.embedded
  if (missing === 0) {
    console.log('\n空の行はありません。何もしません。')
    process.exit(0)
  }
  if (!apply) {
    console.log(`\n${missing} 件を ${client.config.embedModel} で埋めます。実行するには --apply を付けてください。`)
    process.exit(0)
  }

  console.log(`\n${client.config.embedModel} で埋めています…`)
  const r = await embedMissing(db, client, {
    now: new Date(),
    onProgress: (done, table) => console.log(`  ${table}: ${done} 件`),
  })
  console.log(`\nkc ${r.kc} 件 / canon_event ${r.canonEvent} 件を埋めました（${r.model}）。`)
  const after = await embedCoverage(db)
  say('kc         ', after.kc)
  say('canon_event', after.canonEvent)
} finally {
  await db.end({ timeout: 5 })
}
