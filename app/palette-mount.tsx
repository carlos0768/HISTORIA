import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { commandsFor } from '@/lib/loop/commands'
import { CommandPalette } from '@/components/palette'

/**
 * ⌘K を**アプリ全体に1つだけ**載せる（docs/06-desktop.md 03）
 *
 * ★ なぜ画面ごとではなく layout に置くのか。
 *   最初は `<Screen commands={...}>` として画面ごとに渡していたが、
 *   実際に渡したのは /library・/timeline・/map の3つだけで、
 *   **人が出発する画面（ホーム・特訓・記録・出題）に載っていなかった**。
 *   サイドバーは 1440px 以上でしか出ないので、モバイルでは
 *   「机の上」3画面が互いからしか開けない孤島になっていた。
 *
 *   パレットはどの画面にも同じものが出る「アプリの部品」であって、
 *   画面の一部ではない。置き場所を layout にすれば、
 *   **渡し忘れという失敗の形そのものが無くなる。**
 *
 * ★ 未認証には出さない。`tab` を渡さない画面に導線を付けないのと同じ理由で、
 *   未登録の人にアプリの構造（単元名の一覧）を見せない。
 *
 * ★ layout は client 側の遷移では描き直されないので、
 *   単元の問い合わせは**初回の読み込みで1回**しか走らない。
 */
export async function PaletteMount() {
  const db = tryDb()
  const userId = await currentUserId()
  if (!db || !userId) return null

  const commands = await commandsFor(db)
  if (commands.length === 0) return null
  return <CommandPalette commands={commands} />
}
