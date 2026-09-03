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
    // B の設問と、それに紐づく KC。検査3（他人の item への INSERT）と
    // 検査9（ビュー越しの漏れ）の両方で使う
    const [itB] = await tx<{ id: string }[]>`
      INSERT INTO item (id, user_id, format, stem, answer_key, guess_rate,
                        approved, approved_by, approved_at)
      VALUES (gen_random_uuid(), ${B}, 'mcq4', 'Bの設問', '"a"'::jsonb, 0.25,
              true, 'author', now())
      RETURNING id`
    const itemB = itB!.id
    const [kcRow] = await tx<{ id: string }[]>`SELECT id FROM kc LIMIT 1`
    if (kcRow) await tx`INSERT INTO item_kc (item_id, kc_id) VALUES (${itemB}, ${kcRow.id})`

    const mineReady = await mk(A, 'ready')
    await mk(B, 'ready')          // 他人の個別教材
    const sharedReady = await mk(null, 'ready')
    const blocked = await mk(A, 'blocked')

    // 通知の購読を2人分。A から B の行が見えないことを検査1で見る
    for (const [id, ep] of [[A, 'https://push.example/A'], [B, 'https://push.example/B']] as const) {
      await tx`
        INSERT INTO push_subscription (endpoint, user_id, p256dh, auth)
        VALUES (${ep}, ${id}, 'pub', 'secret')`
    }

    // ---- 1. 自分の行だけが見える ----
    for (const t of ['app_user', 'drill', 'response', 'kc_card', 'user_kc_state', 'material_read',
                     'push_subscription']) {
      const r = await asUser(tx, A, t2 => count(t2, t))
      check(`${t}: 自分の行だけ`, r.ok && r.value <= 1, r.ok ? `${r.value} 行` : r.error)
    }

    // ---- 2. ポリシーを持たない表は全行拒否（docs/12 §6.1） ----
    // ★ invite_code と past_exam を必ず含める。
    //   invite_code が読めると招待制（上限10名）が崩れ、
    //   past_exam が読めると第三者著作物の本文が外に出る（docs/10 §2）。
    for (const t of ['app_setting', 'ai_budget', 'ai_spend', 'ops_log', 'item', 'item_kc',
                     'invite_code', 'past_exam', 'past_exam_element', 'past_exam_kc',
                     'kc_proposal', 'kc_merge', 'channel_allowlist', 'evidence_claim']) {
      const r = await asUser(tx, A, t2 => count(t2, t))
      check(`${t}: 全行拒否`, r.ok && r.value === 0, r.ok ? `${r.value} 行（0 のはず）` : r.error)
    }

    // ---- 3. response に INSERT できない（唯一の真実を守る） ----
    // ★ 列名を間違えると「列が無い」で失敗し、RLS が効いていなくても
    //   «拒まれた» に見える。実在する列だけを並べ、拒否の理由まで確かめる。
    const ins = await asUser(tx, A, async t2 => {
      await t2.unsafe(`INSERT INTO response (user_id, item_id, session_kind, chosen, correct)
                       VALUES ('${A}', '${itemB}', 'quiz', '"a"'::jsonb, true)`)
      return true
    })
    check('response: INSERT を拒む', !ins.ok, ins.ok ? '入ってしまった' : '拒まれた')
    check('response: 拒否の理由が RLS である',
      !ins.ok && /row-level security|policy/i.test(ins.error),
      ins.ok ? '' : ins.error.split('\n')[0]!)

    // ---- 3b. push_subscription にも INSERT できない ----
    // ★ 開けると他人の user_id で購読を作れる＝他人宛の通知を自分の端末に呼べる。
    //   登録は Server Action（service_role）が行う。
    const pins = await asUser(tx, A, async t2 => {
      await t2.unsafe(`INSERT INTO push_subscription (endpoint, user_id, p256dh, auth)
                       VALUES ('https://push.example/X', '${A}', 'pub', 'secret')`)
      return true
    })
    check('push_subscription: INSERT を拒む', !pins.ok, pins.ok ? '入ってしまった' : '拒まれた')

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

    // ---- 6. マスタは全認証ユーザーが読める（SELECT ポリシーで開けている） ----
    // ★ 「RLS を掛けていないから読める」ではない。Supabase では RLS 無効は
    //   「anon キーで誰でも書き換えられる」を意味するので、有効にした上で開ける。
    for (const t of ['era', 'region', 'person', 'syllabus_unit', 'kc',
                     'kc_region', 'kc_syllabus_unit', 'canon_event', 'video', 'video_kc']) {
      const r = await asUser(tx, A, t2 => count(t2, t))
      check(`${t}: 読める（マスタ）`, r.ok, r.ok ? `${r.value} 行` : r.error)
    }
    // seed が入っているはずの表は 0 行だとおかしい（ポリシーが効いていない疑い）
    for (const t of ['era', 'region', 'syllabus_unit', 'kc']) {
      const r = await asUser(tx, A, t2 => count(t2, t))
      check(`${t}: 中身が見える`, r.ok && r.value > 0, r.ok ? `${r.value} 行` : r.error)
    }

    // ---- 7. マスタには書き込めない（読み取り可・書き込み不可） ----
    // Supabase は public の表に anon / authenticated へ ALL を既定で付ける。
    // RLS のポリシーを SELECT にしか書いていないことが、唯一の歯止めである。
    // ★ 例外が出ないことを「通った」と読んではいけない。
    //   UPDATE / DELETE は該当ポリシーが無いと 0 行に効くだけで、例外は出ない。
    //   INSERT だけが WITH CHECK 違反で例外になる。効いた行数まで見る。
    for (const [t, sql] of [
      ['kc',            `UPDATE kc SET label = 'x'`],
      ['kc',            `DELETE FROM kc`],
      ['syllabus_unit', `DELETE FROM syllabus_unit`],
      ['era',           `INSERT INTO era (id, label, ord) VALUES ('x', 'x', 99)`],
    ] as const) {
      const verb = sql.split(' ')[0]!
      const w = await asUser(tx, A, async t2 => (await t2.unsafe(sql)).count)
      const denied = !w.ok || w.value === 0
      check(`${t}: 書き込みを拒む（${verb}）`, denied,
        w.ok ? `${w.value} 行に効いた（0 のはず）` : '例外で拒まれた')
    }

    // ---- 8. 未ログイン（anon）には何も見せない（招待制・docs/10） ----
    for (const t of ['kc', 'syllabus_unit', 'app_user', 'material']) {
      const r = await (async () => {
        try {
          return await tx.savepoint(async sp => {
            // ★ claim を消してから anon になる。SET LOCAL はトランザクション全体に
            //   残るので、直前の asUser が入れた利用者Aの uuid が効いたままだと
            //   「anon なのに A の行が見える」という嘘の結果になる。
            await sp.unsafe(`SET LOCAL request.jwt.claim.sub = ''`)
            await sp.unsafe(`SET LOCAL ROLE anon`)
            const v = await count(sp, t)
            await sp.unsafe(`RESET ROLE`)
            return { ok: true as const, value: v }
          })
        } catch (e) {
          return { ok: false as const, error: e instanceof Error ? e.message : String(e) }
        }
      })()
      check(`${t}: anon には見せない`, r.ok && r.value === 0,
        r.ok ? `${r.value} 行（0 のはず）` : r.error)
    }

    // ---- 9. v_weakness_evidence が他人の解答を漏らさない ----
    // ★ ビューの既定は「定義者の権限で実行」。security_invoker を付け忘れると
    //   response の RLS が素通りし、anon キー1本で全員の解答履歴が読める。
    await tx`
      INSERT INTO response (user_id, item_id, session_kind, chosen, correct)
      VALUES (${B}, ${itemB}, 'quiz', '"a"'::jsonb, true)`

    const view = await asUser(tx, A, t2 => count(t2, 'v_weakness_evidence'))
    check('v_weakness_evidence: 他人の解答を漏らさない', view.ok && view.value === 0,
      view.ok ? `${view.value} 行（0 のはず）` : view.error)
    const viewB = await asUser(tx, B, t2 => count(t2, 'v_weakness_evidence'))
    // B 本人からも見えないのは item / item_kc を全行拒否にしているためで、これは正しい
    check('v_weakness_evidence: 本人にも item 越しには開かない', viewB.ok && viewB.value === 0,
      viewB.ok ? `${viewB.value} 行` : viewB.error)

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
