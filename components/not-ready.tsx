import Link from 'next/link'
import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { authEnabled } from '@/lib/auth/supabase'
import { Empty } from './ui'

/**
 * 「まだ出せません」の共通の空状態。
 *
 * ★ 原因を混ぜない。画面はどこも `!db || !userId` の1本で分岐しているが、
 *   この2つは**別のこと**である。以前はどちらでも
 *   「データベースに接続していません。DATABASE_URL と DEMO_USER_ID を設定すると…」
 *   と出していたため、
 *   - ログインしていないだけなのに DB の問題に見える
 *   - 認証を有効にしていると `DEMO_USER_ID` は効かないのに、設定しろと言う
 *   の2つの嘘をついていた。原因ごとに、いま効く手だけを書く。
 *
 * ★ 引数を取らない。tryDb() は環境変数を見るだけ、currentUserId() の
 *   verifySession() は React の cache() 越しなので、呼び出し元が既に
 *   呼んでいても往復は増えない。
 */
export async function NotReady() {
  const noDb = !tryDb()
  const noUser = !(await currentUserId())
  const authOn = authEnabled()

  return (
    <Empty>
      {noDb && (
        <>
          <p className="lv-body">データベースに接続していません。</p>
          <p className="lv-caption">
            <code>DATABASE_URL</code> を設定すると、ここに中身が出ます。
          </p>
        </>
      )}

      {noUser && authOn && (
        <>
          <p className="lv-body">ログインしていません。</p>
          <p className="lv-caption">招待コードから登録すると、ここに中身が出ます。</p>
          <Link className="lv-btn" href="/invite">招待コードを入れる</Link>
        </>
      )}

      {noUser && !authOn && (
        <>
          <p className="lv-body">利用者を特定できていません。</p>
          <p className="lv-caption">
            {/* ★ 認証が無効なときだけ DEMO_USER_ID が効く（lib/auth/dal.ts）。
                 有効にしていると黙って無視されるので、そこでは案内しない */}
            認証を無効にしているので、<code>DEMO_USER_ID</code> に利用者の id を入れると、
            その1人として全画面を見られます。
          </p>
        </>
      )}
    </Empty>
  )
}
