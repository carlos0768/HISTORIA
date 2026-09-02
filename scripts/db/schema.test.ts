import { describe, it, expect } from 'vitest'
import postgres from 'postgres'
import { readSchema, ensureAuthShim, SUPABASE_ROLES_SHIM } from './schema'
import { TEST_DB_URL } from '@/lib/db/test-helper'

describe('スキーマの読み込み', () => {
  it('pgvector があればそのまま読む', () => {
    const s = readSchema({ pgvector: true })
    expect(s).toContain('CREATE EXTENSION IF NOT EXISTS vector;')
    expect(s).toContain('vector(768)')
    expect(s).toContain('USING hnsw')
  })
  it('pgvector が無ければ型と索引だけ置換する（制約と RLS は触らない）', () => {
    const s = readSchema({ pgvector: false })
    expect(s).toContain('CREATE DOMAIN vector AS real[];')
    expect(s).not.toContain('vector(768)')
    expect(s).not.toContain('USING hnsw')
    // 置換で消えてはいけないもの
    expect(s).toContain('ENABLE ROW LEVEL SECURITY')
    expect(s).toContain('auth.uid()')
    expect(s).toContain('ef >= 1.3::real')
  })
})

const dbSuite = TEST_DB_URL ? describe : describe.skip

dbSuite('auth シム', () => {
  it('auth.uid() が無ければ作り、あれば触らない（本物を上書きしない）', async () => {
    const admin = postgres(TEST_DB_URL!, { prepare: false, max: 1, onnotice: () => {} })
    await admin.unsafe('DROP DATABASE IF EXISTS historia_shim_test')
    await admin.unsafe('CREATE DATABASE historia_shim_test')
    await admin.end({ timeout: 5 })

    const url = new URL(TEST_DB_URL!)
    url.pathname = '/historia_shim_test'
    const db = postgres(url.toString(), { prepare: false, max: 1, onnotice: () => {} })
    try {
      expect(await ensureAuthShim(db)).toBe(true)  // 無かったので作った
      expect(await ensureAuthShim(db)).toBe(false) // もうあるので作らない
    } finally {
      await db.end({ timeout: 5 })
      const a = postgres(TEST_DB_URL!, { prepare: false, max: 1, onnotice: () => {} })
      await a.unsafe('DROP DATABASE IF EXISTS historia_shim_test')
      await a.end({ timeout: 5 })
    }
  }, 60_000)
})

dbSuite('ロールの競合', () => {
  // 試験用DBを並行して作ると CREATE ROLE がぶつかる。ここで見るのは
  // 「他のセッションが**いままさに**同じロールを作っている」場合で、
  // このとき飛ぶのは duplicate_object ではなく unique_violation である。
  //
  // 段取り（決定的に再現する）:
  //   A: BEGIN; CREATE ROLE r;  ← COMMIT せずに握ったまま
  //   B: 同じ CREATE ROLE       ← 目録走査では「無い」ので INSERT に進み一意索引で待つ
  //   A: COMMIT                 ← B が unique_violation で起きる
  //
  // 本番の shim そのもの（SUPABASE_ROLES_SHIM）から例外処理の行を取り出して試す。
  // handler から unique_violation を消すと、この試験は落ちる。
  it('他のセッションが同時に作っていても shim の例外処理が握りつぶす', async () => {
    const role = 'historia_race_probe'
    // shim の1行を、本物のロール名を壊さないよう試験用の名前に置き換えて使う
    const line = SUPABASE_ROLES_SHIM.split('\n').find(l => l.includes('CREATE ROLE anon'))
    expect(line, 'shim から CREATE ROLE anon の行が見つからない').toBeTruthy()
    const doBlock = `DO $$\nBEGIN\n${line!.trim().replace(/\banon\b/, role)}\nEND $$;`

    const opts = { prepare: false, max: 1, onnotice: () => {} } as const
    const a = postgres(TEST_DB_URL!, opts)
    const b = postgres(TEST_DB_URL!, opts)
    try {
      await a.unsafe(`DROP ROLE IF EXISTS ${role}`)

      let release!: () => void
      const held = new Promise<void>(r => { release = r })
      const aDone = a.begin(async tx => {
        await tx.unsafe(`CREATE ROLE ${role} NOLOGIN`)
        await held           // COMMIT せずに握る
      })

      // B は待たされるはずなので、結果を変数で受ける（ここでは await しない）
      let outcome: 'pending' | 'ok' | Error = 'pending'
      const bDone = b.unsafe(doBlock).then(() => { outcome = 'ok' }, (e: Error) => { outcome = e })

      await new Promise(r => setTimeout(r, 500))
      // ★ ここが逆対照。B が既に終わっていたら競合していないので、
      //   この試験は「握りつぶせた」ではなく「ぶつからなかった」を見ていることになる。
      expect(outcome, 'B が待たされていない＝競合を再現できていない').toBe('pending')

      release()
      await aDone
      await bDone

      expect(outcome).toBe('ok')
      const [row] = await a<{ n: string }[]>`SELECT count(*) AS n FROM pg_roles WHERE rolname = ${role}`
      expect(Number(row?.n)).toBe(1)   // 握りつぶした後、ロールは確かに存在する
    } finally {
      await b.end({ timeout: 5 })
      await a.unsafe(`DROP ROLE IF EXISTS ${role}`).catch(() => {})
      await a.end({ timeout: 5 })
    }
  }, 60_000)
})
