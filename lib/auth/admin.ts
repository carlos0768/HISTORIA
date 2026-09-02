/**
 * 管理者かどうか（docs/12-nonfunctional.md §7.1）
 *
 * ★ スキーマを増やさない。`app_user` に `is_admin` を足すと、
 *   その列を書ける経路を1つ作ることになり、守る対象が増える。
 *   管理者はこのアプリでは**ひとり（作者）**だけなので、環境変数で足りる。
 *
 * ★ **未設定なら誰も管理者ではない**。既定を開にしない。
 *   `ADMIN_USER_ID` を入れ忘れた本番で誰かが /admin を開けてしまうと、
 *   支出も未処理の報告も全部見えることになる。
 *
 * ★ 不一致のときは 404 にする（呼び出し側の責務）。リダイレクトではない。
 *   docs/10 G2 と同じで、経路の存在自体を見せない。
 */
export function adminUserId(): string | null {
  const id = process.env.ADMIN_USER_ID?.trim()
  return id ? id : null
}

/**
 * この利用者は管理者か。
 *
 * ★ userId が null（未ログイン）なら必ず false。
 *   `adminUserId()` も null のとき `null === null` で通ってしまう書き方をしない。
 */
export function isAdmin(userId: string | null): boolean {
  const admin = adminUserId()
  if (!admin || !userId) return false
  return userId === admin
}
