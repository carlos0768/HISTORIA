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

/**
 * ────────────────────────────────────────────────
 * 通知（docs/11-ux.md §7・docs/12-nonfunctional.md §10）
 *
 * ★ 本文は配信元（FCM など）を経由する。中身は暗号化されているが、
 *   誰がいつ受け取ったかは配信元に見える。だから送信側は学習内容を書かない
 *   （lib/push/send.ts）。ここでは受け取ったものをそのまま出すだけにする。
 *
 * ★ 中身が壊れていても通知を出す。payload の JSON.parse に失敗したとき
 *   何も出さないと、利用者には「通知を許可したのに来ない」としか見えない。
 *   既定の文面に落として、来ていることだけは分かるようにする。
 * ────────────────────────────────────────────────
 */

const NOTIFY_TAG = 'historia-remind'
const DEFAULT_NOTIFICATION = {
  title: 'HISTORIA',
  body: '今日の学習がまだ残っています',
  url: '/study',
}

/**
 * 開いてよい行き先か。
 *
 * ★ `url.startsWith('/')` では足りない。`//example.com/phish` も '/' 始まりで、
 *   openWindow はこれを `https://example.com/phish` として解決する
 *   （プロトコル相対 URL）。通知1通で任意の場所へ連れて行けることになる。
 *   実際に試験で通ってしまい、ここで気づいた。
 *   **解決してから生成元を比べる**のが唯一の確実な形である。
 */
function sameOriginPath(url) {
  if (typeof url !== 'string' || !url.startsWith('/')) return null
  try {
    const u = new URL(url, self.location.origin)
    if (u.origin !== self.location.origin) return null
    return u.pathname + u.search
  } catch {
    return null
  }
}

function readPayload(event) {
  try {
    const data = event.data && event.data.json()
    if (!data || typeof data !== 'object') return DEFAULT_NOTIFICATION
    return {
      title: typeof data.title === 'string' ? data.title : DEFAULT_NOTIFICATION.title,
      body: typeof data.body === 'string' ? data.body : DEFAULT_NOTIFICATION.body,
      url: sameOriginPath(data.url) ?? DEFAULT_NOTIFICATION.url,
    }
  } catch {
    return DEFAULT_NOTIFICATION
  }
}

self.addEventListener('push', event => {
  const n = readPayload(event)
  event.waitUntil(self.registration.showNotification(n.title, {
    body: n.body,
    icon: '/icon-192.png',
    badge: '/icon-192.png',
    // ★ tag を固定する。届かなかった夜のぶんが溜まって、
    //   翌朝に3通並ぶのを防ぐ。最新の1通だけが残る
    tag: NOTIFY_TAG,
    // ★ renotify を立てない。同じ tag で置き換えるたびに鳴らすと、
    //   ただうるさいだけで、内容は変わっていない
    data: { url: n.url },
  }))
})

/**
 * 通知を押したとき。
 *
 * ★ すでに開いている窓があればそれを使う。毎回 openWindow すると
 *   同じ画面が何枚も開き、どれが今のものか分からなくなる。
 * ★ 開く先は必ず自分の生成元の中に閉じる（url は '/' 始まりだけ通している）。
 */
self.addEventListener('notificationclick', event => {
  event.notification.close()
  // ★ ここでも解決し直す。push handler が入れた値しか来ないはずだが、
  //   「はずだ」に頼らない。通知は他所（配信元）を通って届いたものである
  const target = sameOriginPath(event.notification.data && event.notification.data.url)
    ?? DEFAULT_NOTIFICATION.url
  event.waitUntil((async () => {
    const all = await self.clients.matchAll({ type: 'window', includeUncontrolled: true })
    for (const c of all) {
      if (new URL(c.url).origin === self.location.origin) {
        await c.focus()
        if ('navigate' in c) await c.navigate(target)
        return
      }
    }
    await self.clients.openWindow(target)
  })())
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
