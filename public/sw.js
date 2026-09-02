/**
 * HISTORIA の Service Worker
 *
 * 仕様: docs/12-nonfunctional.md §10
 *
 * ★ ライブラリを足さない。next-pwa は Next 16 に追随していないうえ、
 *   ここでやることは「何をキャッシュしないか」の判断が全てで、
 *   その判断は生成器では書けない。
 *
 * ★ このファイルは Next のビルドを通らない。素の JS で書き、TypeScript にしない。
 *
 * ────────────────────────────────────────────────
 * 何をオフラインで動かすか（ここが設計の中心）
 *
 *   教材を読む        … できる。電車で読むのが本来の使い方
 *   記録・弱点を見る  … できる（最後に見た状態）
 *   問題を解く        … **させない**
 *
 * 出題をオフラインで動かすには answer_key を端末に置くことになる。
 * docs/12 §6.1 は「正答は解答前にクライアントへ渡さない」「採点は Server Action が
 * item.answer_key と照合して correct を決める」と定めており、
 * これは item に SELECT ポリシーを作らない設計（schema.sql §13）と一体である。
 * 端末に正答を置いた時点で、DevTools を開ける高校生1人で弱点DBの入力が無意味になる。
 *
 * 「解答をキューに貯めて復帰時に採点する」ことは技術的には可能で、設計も壊さない。
 * だが**即時フィードバックの無い出題は retrieval practice として成立しない**
 * （docs/04 は解答直後の正誤提示を前提に p_know を更新する）。
 * よってオフラインでは出題そのものを出さず、/offline へ流す。
 * ────────────────────────────────────────────────
 */

const VERSION = 'v1'
const SHELL = `historia-shell-${VERSION}`   // /offline とアイコン
const PAGES = `historia-pages-${VERSION}`   // 個人の内容を含む頁。ログアウトで消す
const STATIC = `historia-static-${VERSION}` // _next/static。内容ハッシュ付きで不変

const OFFLINE_URL = '/offline'
const STATIC_MAX = 80

/**
 * 出題系。**絶対にキャッシュしない**（上の理由）。
 * /checktest/result も含む。あそこは解答済みの正答と解説を描画している。
 *
 * ★ 過去問を含む頁を作るときは、ここに足す。docs/10 G4 は
 *   「コピー・ダウンロード導線を置かない」としており、
 *   端末に本文の複製が残るのはその趣旨に反する。
 */
const NEVER_CACHE = ['/study', '/checktest']

/**
 * オフラインで開ける頁。**列挙する**。既定はキャッシュしないである。
 * 「他は全部入れる」にすると、新しい画面を足したときに黙って混ざる。
 */
const CACHEABLE = ['/material', '/records']

const startsWithAny = (path, list) =>
  list.some(p => path === p || path.startsWith(`${p}/`))

/** 入れすぎを止める。内容ハッシュ付きの資産は配信のたびに名前が変わって溜まる */
async function trim(cacheName, max) {
  const cache = await caches.open(cacheName)
  const keys = await cache.keys()
  for (let i = 0; i < keys.length - max; i++) await cache.delete(keys[i])
}

self.addEventListener('install', event => {
  event.waitUntil((async () => {
    const cache = await caches.open(SHELL)
    // ★ 個別に失敗を握る。cache.addAll は1つ落ちると全部落ち、
    //   install が失敗して SW が有効にならない。
    //   /offline は proxy を通るので、認証の状態しだいで 404 になりうる。
    await Promise.allSettled(
      [OFFLINE_URL, '/icon-192.png', '/icon-512.png'].map(u => cache.add(u)),
    )
    await self.skipWaiting()
  })())
})

self.addEventListener('activate', event => {
  event.waitUntil((async () => {
    const keep = [SHELL, PAGES, STATIC]
    const names = await caches.keys()
    await Promise.all(names.filter(n => !keep.includes(n)).map(n => caches.delete(n)))
    await self.clients.claim()
  })())
})

/**
 * 個人の内容を消す。
 *
 * ★ 共用端末に他人の教材と記録を残さない。
 *   引き金は「ログアウト」だけではない。session が切れた場合も同じ危険がある。
 *   保護された経路は未認証だと **404 になる**（docs/10 G2）ので、
 *   404 を消去の合図として使う。これでログアウト・session 切れ・
 *   別人が開いた、のどれでも消える。
 *   設定画面ができたら、そこからは postMessage({type:'purge'}) で明示的に呼べる。
 */
const purge = () => caches.delete(PAGES)

self.addEventListener('message', event => {
  if (event.data && event.data.type === 'purge') event.waitUntil(purge())
})

self.addEventListener('fetch', event => {
  const req = event.request

  // ★ GET 以外に触らない。Server Action は POST で来る。
  //   採点も読了も全部ここを通るので、握ると閉ループが壊れる。
  if (req.method !== 'GET') return

  const url = new URL(req.url)
  if (url.origin !== self.location.origin) return   // 字体などの外部資産は素通し

  // 内容ハッシュ付きで不変。キャッシュ優先でよい（個人の内容を含まない）
  if (url.pathname.startsWith('/_next/static/')) {
    event.respondWith(cacheFirst(req))
    return
  }

  if (req.mode === 'navigate') {
    event.respondWith(navigate(req, url))
  }
  // それ以外（RSC の取得・画像・fetch）は素通し。
  // 握らないほうが素直に失敗して、Next 自身がハードナビゲーションに落ちる。
})

async function cacheFirst(req) {
  const cache = await caches.open(STATIC)
  const hit = await cache.match(req)
  if (hit) return hit
  const res = await fetch(req)
  if (res.ok) {
    await cache.put(req, res.clone())
    trim(STATIC, STATIC_MAX)   // 待たない。応答を遅らせる理由がない
  }
  return res
}

/**
 * 画面の取得。**ネットワーク優先**である。
 *
 * ★ 計画は stale-while-revalidate と書いていたが、そちらを採らなかった。
 *   SWR は「まず保存済みを出す」ので、共用端末で**前の利用者の頁が一瞬出る**。
 *   ネットワーク優先なら、繋がっているときは必ず今の内容が出て、
 *   繋がっていないときだけ保存済みに落ちる。
 *   オフラインで読めるという目的は、どちらでも同じく達成できる。
 */
async function navigate(req, url) {
  const never = startsWithAny(url.pathname, NEVER_CACHE)

  try {
    const res = await fetch(req)

    // 未認証は 404（docs/10 G2）。個人の内容を消す合図として使う
    if (res.status === 404) await purge()

    if (!never && res.ok && startsWithAny(url.pathname, CACHEABLE)) {
      const cache = await caches.open(PAGES)
      await cache.put(req, res.clone())
    }
    return res
  } catch {
    // ここに来たのは通信できなかったときだけ（4xx・5xx は上で返っている）
    if (!never) {
      const hit = await caches.match(req, { cacheName: PAGES })
      if (hit) return hit
    }
    const offline = await caches.match(OFFLINE_URL, { cacheName: SHELL })
    // /offline すら無い（インストール直後に圏外）ときは、素直に失敗させる
    return offline ?? Response.error()
  }
}
