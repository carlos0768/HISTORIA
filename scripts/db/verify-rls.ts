/**
 * RLS が意図どおり効くかを実データベースで確かめる（docs/14 M22）
 *
 *   DATABASE_URL='postgresql://...' npx tsx scripts/db/verify-rls.ts
 *
 * ★ 何も残さない。全部ひとつのトランザクションで行い、最後に必ず戻す。
 *   Supabase の本番に対して流しても、行は1件も増えない。
 *
 * ★ postgres ロールは RLS を迂回する。だから SET LOCAL ROLE authenticated で
 *   利用者と同じ立場になり、auth.uid() を request.jwt.claim.sub で与えて確かめる。
 *   これをしないと「全部見える」という無意味な結果になる。
 */
import postgres from 'postgres'
import { randomUUID } from 'node:crypto'
import type { Sql, TransactionSql } from 'postgres'

const url = process.env.DATABASE_URL
if (!url) {
  console.error('DATABASE_URL が未設定です。')
  process.exit(1)
}

// 毎回別の id を使う。固定値だと既存の行と衝突しうる
const A = randomUUID()
const B = randomUUID()

type Result = { name: string; ok: boolean; detail: string }
const results: Result[] = []
const check = (name: string, ok: boolean, detail: string) => results.push({ name, ok, detail })

/** authenticated として1つの問い合わせを行う。失敗しても他の検査を続けられるようにする */
async function asUser<T>(
  tx: TransactionSql, uid: string, run: (t: TransactionSql) => Promise<T>,
): Promise<{ ok: true; value: T } | { ok: false; error: string }> {
  try {
    return await tx.savepoint(async sp => {
      await sp.unsafe(`SET LOCAL ROLE authenticated`)
      await sp.unsafe(`SET LOCAL request.jwt.claim.sub = '${uid}'`)
      const value = await run(sp)
      await sp.unsafe(`RESET ROLE`)
      return { ok: true as const, value }
    })
  } catch (e) {
    return { ok: false as const, error: e instanceof Error ? e.message : String(e) }
  }
}

const count = async (t: TransactionSql, table: string): Promise<number> => {
  const r = await t.unsafe<{ n: string }[]>(`SELECT count(*) AS n FROM ${table}`)
  return Number(r[0]!.n)
}

const shown = new URL(url); shown.password = '***'
console.log(`接続先: ${shown.host}${shown.pathname}\n`)

const db: Sql = postgres(url, { prepare: false, max: 1, onnotice: () => {} })

try {
  const [role] = await db<{ ok: boolean }[]>`
    SELECT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'authenticated') AS ok`
  if (!role?.ok) {
    console.error('authenticated ロールがありません。')
    console.error('Supabase なら必ず存在します。手元で試すなら先に作ってください:')
    console.error("  CREATE ROLE authenticated NOLOGIN;")
    console.error("  GRANT USAGE ON SCHEMA public, auth TO authenticated;")
    console.error("  GRANT SELECT, INSERT ON ALL TABLES IN SCHEMA public TO authenticated;")
    console.error("  GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA auth TO authenticated;")
    process.exit(1)
  }

  await db.begin(async tx => {
    // ---- 検査用のデータ。トランザクションの中だけに存在する ----
    for (const [id, name] of [[A, '利用者A'], [B, '利用者B']] as const) {
      await tx`
        INSERT INTO app_user (id, display_name, birth_date, guardian_consent_required,
                              consent_version, consent_at)
        VALUES (${id}, ${name}, '2008-01-01', false, 'v1', now())`
    }
    const [unit] = await tx<{ id: string }[]>`SELECT id FROM syllabus_unit WHERE level = 3 LIMIT 1`
    if (!unit) throw new Error('syllabus_unit がありません。先に seed を入れてください')

    const mk = async (owner: string | null, status: string) => {
      const [m] = await tx<{ id: string }[]>`
        INSERT INTO material (id, user_id, unit_id, title, provider, model, prompt_version, status)
        VALUES (gen_random_uuid(), ${owner}, ${unit.id}, ${`${status}/${owner ?? '共有'}`},
                'gemini', 'x', 'v1', ${status})
        RETURNING id`
      await tx`
        INSERT INTO material_section (id, material_id, ord, heading, body_md, char_count)
        VALUES (gen_random_uuid(), ${m!.id}, 1, '見出し', '本文', 2)`
      return m!.id
    }
    const mineReady = await mk(A, 'ready')
    await mk(B, 'ready')          // 他人の個別教材
    const sharedReady = await mk(null, 'ready')
    const blocked = await mk(A, 'blocked')

    // ---- 1. 自分の行だけが見える ----
    for (const t of ['app_user', 'drill', 'response', 'kc_card', 'user_kc_state', 'material_read']) {
      const r = await asUser(tx, A, t2 => count(t2, t))
      check(`${t}: 自分の行だけ`, r.ok && r.value <= 1, r.ok ? `${r.value} 行` : r.error)
    }

    // ---- 2. ポリシーを持たない表は全行拒否（docs/12 §6.1） ----
    for (const t of ['app_setting', 'ai_budget', 'ai_spend', 'item']) {
      const r = await asUser(tx, A, t2 => count(t2, t))
      check(`${t}: 全行拒否`, r.ok && r.value === 0, r.ok ? `${r.value} 行（0 のはず）` : r.error)
    }

    // ---- 3. response に INSERT できない（唯一の真実を守る） ----
    const ins = await asUser(tx, A, async t2 => {
      await t2.unsafe(`INSERT INTO response (user_id, item_id, session_kind, chosen, correct, p_know_before, p_know_after)
                       VALUES ('${A}', gen_random_uuid(), 'quiz', '"a"'::jsonb, true, 0.5, 0.6)`)
      return true
    })
    check('response: INSERT を拒む', !ins.ok, ins.ok ? '入ってしまった' : '拒まれた')

    // ---- 4. 教材の可視範囲 ----
    const mats = await asUser(tx, A, async t2 => {
      const r = await t2.unsafe<{ id: string; user_id: string | null; status: string }[]>(
        `SELECT id, user_id, status FROM material`)
      return r
    })
    if (!mats.ok) {
      check('material: 可視範囲', false, mats.error)
    } else {
      const ids = new Set(mats.value.map(m => m.id))
      check('material: 自分の教材が見える', ids.has(mineReady), `${mats.value.length} 件`)
      check('material: 共有教材が見える', ids.has(sharedReady), '')
      check('material: 他人の個別教材は見えない',
        !mats.value.some(m => m.user_id === B), '')
    }

    // ---- 5. 本文（material_section）は「読める教材の ready 版」に限る ----
    const secs = await asUser(tx, A, async t2 => {
      const r = await t2.unsafe<{ material_id: string }[]>(`SELECT material_id FROM material_section`)
      return r
    })
    if (!secs.ok) {
      check('material_section: 可視範囲', false, secs.error)
    } else {
      const mids = new Set(secs.value.map(s => s.material_id))
      check('material_section: 自分の ready の本文が見える', mids.has(mineReady), `${secs.value.length} 件`)
      check('material_section: 共有の本文が見える', mids.has(sharedReady), '')
      check('material_section: blocked の本文は見えない', !mids.has(blocked),
        '作者判断 Q4・docs/08 §5 層5')
      check('material_section: 他人の本文は見えない', mids.size <= 2, `${mids.size} 本の教材`)
    }

    // ---- 6. マスタは誰でも読める（RLS を掛けていない） ----
    for (const t of ['era', 'region', 'syllabus_unit', 'kc']) {
      const r = await asUser(tx, A, t2 => count(t2, t))
      check(`${t}: 読める（マスタ）`, r.ok && r.value > 0, r.ok ? `${r.value} 行` : r.error)
    }

    // ★ 何も残さない
    throw new Error('__ROLLBACK__')
  }).catch(e => {
    if (!(e instanceof Error) || e.message !== '__ROLLBACK__') throw e
  })
} finally {
  await db.end({ timeout: 5 })
}

const pad = Math.max(...results.map(r => r.name.length))
let failed = 0
for (const r of results) {
  if (!r.ok) failed++
  console.log(`  ${r.ok ? '○' : '×'} ${r.name.padEnd(pad)}  ${r.detail}`)
}
console.log(`\n${results.length - failed} / ${results.length} 件が意図どおり`)
if (failed > 0) {
  console.log('\n× が出た項目は RLS が意図どおり効いていません。docs/14 M22 に記録してください。')
  process.exitCode = 1
} else {
  console.log('データベースには何も残していません（全てロールバック）。')
}
