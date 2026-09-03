/**
 * DB が駄目だったときに、画面に何を出すかを決める
 *
 * ★ なぜ要るのか。`sql()` は `DATABASE_URL` が無ければ投げ（client.ts）、
 *   在っても届かなければ問い合わせが投げる。Server Action がそれを
 *   受けずに投げると Next の素の 500 になり、**利用者にも作者にも
 *   何も分からない**。2026-09-03 に作者が本番で招待コードを打って
 *   実際にそれを踏んだ。原因は4つありうるのに、画面はどれも同じだった。
 *
 * ★ **生の error.message を画面に返してはならない。**
 *   postgres.js の `Errors.connection()`（node_modules/postgres/src/errors.js）は
 *   message に `host + ':' + port` を、`address` にホスト名を入れる。
 *   そのまま返すと `db.<ref>.supabase.co` が**未認証の訪問者のブラウザに出る**。
 *   本番プロジェクトの ref は秘密ではないが、招待制のアプリで
 *   入口の画面から漏らす理由が無い。返すのは下の固定文だけにし、
 *   生の error は console.error で関数ログにだけ残す。
 */

/**
 * `DATABASE_URL` が無い。
 *
 * ★ 文面での判定をやめて名前付きにする。以前は
 *   `new Error('DATABASE_URL が設定されていません')` だったので、
 *   分類するには message を比べるほかなく、文を直した瞬間に黙って壊れた。
 */
export class DbNotConfiguredError extends Error {
  constructor() {
    super('DATABASE_URL が設定されていません')
    this.name = 'DbNotConfiguredError'
  }
}

export type DbFailure = 'unset' | 'unreachable' | 'auth' | 'schema' | 'unknown'

/**
 * 届かなかったことを表す code。
 *
 * 前半は postgres.js 自身が付けるもの（src/connection.js:156,257,416,444 /
 * src/index.js:331,387）。後半は socket が投げる Node の errno で、
 * `socket.on('error', error)`（connection.js:282）からそのまま上がってくる。
 */
const UNREACHABLE = new Set([
  'CONNECTION_CLOSED', 'CONNECTION_ENDED', 'CONNECTION_DESTROYED', 'CONNECT_TIMEOUT',
  'ENOTFOUND', 'ECONNREFUSED', 'ECONNRESET', 'ETIMEDOUT',
  'ENETUNREACH', 'EHOSTUNREACH', 'EAI_AGAIN', 'EPIPE',
  // ★ 53300 は「届かない」ではなく「満杯」だが、利用者に出す文と
  //   打つべき手（少し待つ）が完全に同じなので同じ束に入れる。
  //   プーラーの同時接続を使い切ったときに出る（docs/12 §4）。
  '53300',
])

/** 資格情報を拒否された。28P01=invalid_password / 28000=invalid_authorization_specification */
const AUTH = new Set(['28P01', '28000'])

/** 表や DB がまだ無い。42P01=undefined_table / 3D000=invalid_catalog_name */
const SCHEMA = new Set(['42P01', '3D000'])

/** error から code だけを安全に取り出す */
function codeOf(e: unknown): string | null {
  if (typeof e !== 'object' || e === null) return null
  const c = (e as { code?: unknown }).code
  return typeof c === 'string' ? c : null
}

/**
 * 何が起きたのかを5つに分ける。純粋関数。
 *
 * ★ 分からないものは `unknown` にする。`code` が無いものを
 *   まとめて「未設定」にすると、`TypeError` のような**こちらの書き間違いが
 *   設定の問題に化ける**。それは最も直しにくい嘘である。
 */
export function classifyDbError(e: unknown): DbFailure {
  if (e instanceof DbNotConfiguredError) return 'unset'
  // instanceof が効かない経路（モジュールが二重に読まれる等）の保険
  if (typeof e === 'object' && e !== null
      && (e as { name?: unknown }).name === 'DbNotConfiguredError') return 'unset'

  const code = codeOf(e)
  if (!code) return 'unknown'
  if (UNREACHABLE.has(code)) return 'unreachable'
  if (AUTH.has(code)) return 'auth'
  if (SCHEMA.has(code)) return 'schema'
  return 'unknown'
}

/**
 * 画面に出す文。**固定文しか返さない。**
 *
 * ★ 「少し待って」を全部に付けない。資格情報が違うときは何時間待っても
 *   直らないので、待てと言うのは嘘である。原因ごとに打てる手だけを書く
 *   （components/not-ready.tsx と同じ作法）。
 */
export function dbErrorMessage(e: unknown): string {
  switch (classifyDbError(e)) {
    case 'unset':
      return 'データベースが設定されていません（DATABASE_URL）。作者に連絡してください。'
    case 'unreachable':
      return 'データベースに接続できませんでした。少し待ってから、もう一度お試しください。'
    case 'auth':
      return 'データベースに拒否されました（資格情報）。作者に連絡してください。'
    case 'schema':
      return 'データベースの準備がまだ終わっていません。作者に連絡してください。'
    case 'unknown':
      return 'うまくいきませんでした。もう一度お試しください。'
  }
}

/**
 * 呼び出し側が1行で使うための入口。ログに残して、出す文を返す。
 *
 * @param where どこで起きたか。関数ログを読むときの手がかりにするだけで、
 *              画面には出さない。
 */
export function dbFailure(where: string, e: unknown): string {
  // ★ ここだけが生の error を見る場所である。Vercel の関数ログには
  //   host も code も stack も残るので、digest から辿れる。
  console.error(`[db:${where}] ${classifyDbError(e)}`, e)
  return dbErrorMessage(e)
}
