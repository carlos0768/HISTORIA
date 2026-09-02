/**
 * Web Push の鍵（VAPID）を作る
 *
 *   npx tsx scripts/push/gen-vapid.ts
 *
 * ★ **ファイルに書かない。標準出力に出すだけである。**
 *   .env に書き出す実装にすると、いつか .env ごとコミットされる。
 *   出したものを作者が Vercel の環境変数へ手で貼る、という経路に固定する。
 *
 * ★ 鍵を作り直すと、**既存の購読は全部無効になる**（applicationServerKey が
 *   変わるため、端末側の購読が別の鍵で作られたものになる）。
 *   作り直したときは push_subscription を空にして、各自に再登録してもらう。
 */
import webpush from 'web-push'

const keys = webpush.generateVAPIDKeys()

console.log('Vercel の環境変数に、この3つを入れる（値はここにしか出ない）:')
console.log('')
console.log(`VAPID_PUBLIC_KEY=${keys.publicKey}`)
console.log(`VAPID_PRIVATE_KEY=${keys.privateKey}`)
console.log('VAPID_SUBJECT=mailto:あなたのメールアドレス')
console.log('')
console.log('★ この出力をリポジトリの中のファイルに保存しないこと。')
console.log('★ VAPID_SUBJECT は mailto: か https:// で始める必要がある（RFC 8292 §2.1）。')
console.log('★ あわせて CRON_SECRET も要る（app/api/cron/route.ts）。例:')
console.log(`   CRON_SECRET=${webpush.generateVAPIDKeys().publicKey.slice(0, 43)}`)
