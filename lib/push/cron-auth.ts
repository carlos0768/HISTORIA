/**
 * 定時実行の呼び出し元を確かめる（app/api/cron/route.ts）
 *
 * ★ ここだけが防壁である。proxy.ts は未認証の要求を 404 にするが、
 *   Vercel Cron は session を持たないので `/api/cron` は PUBLIC_PATHS に
 *   入れざるをえない。つまり proxy はこの経路を素通しする。
 *
 * ★ **既定は閉**。秘密が未設定なら誰も通さない。
 *   「鍵が無ければ黙って素通り」は lib/db/optional.ts や proxy.ts の
 *   authorize() が採っている作法だが、あれは**見せる**方向の緩和である。
 *   ここは通知を送り、DB を書き換える経路なので、同じ緩和はできない。
 *
 * ★ 独立した module にしたのは試験のためである。route.ts の中に閉じていると
 *   Next の要求オブジェクトを組み立てないと試験できない。
 */

/** 秘密が設定されているか。未設定なら経路ごと閉じる */
export function cronSecretConfigured(): boolean {
  return Boolean(process.env.CRON_SECRET)
}

/**
 * `Authorization` ヘッダを確かめる。
 *
 * @param header 受け取った Authorization の値（無ければ null）
 * @param secret 期待する秘密（未設定なら null）
 *
 * ★ 長さの違いで早く抜けないよう timingSafeEqual で比べる。
 *   32文字程度の秘密に対する時間差攻撃は現実的な脅威ではないが、
 *   比較の作法をここで崩す理由も無い。
 */
export async function cronAuthorized(
  header: string | null,
  secret: string | undefined,
): Promise<boolean> {
  if (!secret) return false
  if (!header) return false
  const { timingSafeEqual } = await import('node:crypto')
  const a = Buffer.from(header)
  const b = Buffer.from(`Bearer ${secret}`)
  // ★ 長さが違えば timingSafeEqual は例外を投げるので、先に比べる。
  //   長さの一致は秘密の長さしか漏らさない（値は漏らさない）
  if (a.length !== b.length) return false
  return timingSafeEqual(a, b)
}
