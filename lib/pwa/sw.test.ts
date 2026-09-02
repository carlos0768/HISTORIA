import { describe, it, expect, beforeEach } from 'vitest'
import { readFileSync } from 'node:fs'
import { fileURLToPath } from 'node:url'

/**
 * Service Worker の試験（docs/12 §10）
 *
 * ★ 本文を正規表現で見ない。`public/sw.js` を**実際に読み込んで動かし**、
 *   取得の要求を1本ずつ通して「何が保存され、何が保存されないか」を見る。
 *   ここで守りたいのは「出題系が端末に残らない」ことで、
 *   それは文字列検査では確かめられない（列を1つ足せば黙って破れる）。
 *
 * sw.js は Next のビルドを通らない素の JS なので、import できない。
 * `new Function` で包み、self / caches / fetch を差し替えて動かす。
 */

const SW_SRC = readFileSync(
  fileURLToPath(new URL('../../public/sw.js', import.meta.url)), 'utf8',
)

const ORIGIN = 'http://localhost:3000'

type Req = { method: string; url: string; mode?: string }
type Res = { ok: boolean; status: number; body: string; clone: () => Res }

const res = (body: string, status = 200): Res => {
  const r: Res = { ok: status >= 200 && status < 300, status, body, clone: () => r }
  return r
}

const req = (path: string, o: Partial<Req> = {}): Req =>
  ({ method: 'GET', url: `${ORIGIN}${path}`, mode: 'navigate', ...o })

/** 名前つきキャッシュの最小実装。Map で足りる */
function makeCaches() {
  const store = new Map<string, Map<string, Res>>()
  const open = async (name: string) => {
    if (!store.has(name)) store.set(name, new Map())
    const m = store.get(name)!
    return {
      match: async (r: Req | string) => m.get(typeof r === 'string' ? `${ORIGIN}${r}` : r.url),
      put: async (r: Req | string, v: Res) =>
        void m.set(typeof r === 'string' ? `${ORIGIN}${r}` : r.url, v),
      add: async (u: string) => { m.set(`${ORIGIN}${u}`, res(`precached ${u}`)) },
      keys: async () => [...m.keys()],
      delete: async (k: string) => m.delete(k),
    }
  }
  return {
    store,
    api: {
      open,
      keys: async () => [...store.keys()],
      delete: async (name: string) => store.delete(name),
      match: async (r: Req | string, opts?: { cacheName?: string }) => {
        const key = typeof r === 'string' ? `${ORIGIN}${r}` : r.url
        if (opts?.cacheName) return store.get(opts.cacheName)?.get(key)
        for (const m of store.values()) if (m.has(key)) return m.get(key)
        return undefined
      },
    },
  }
}

type Harness = {
  caches: ReturnType<typeof makeCaches>
  fetches: string[]
  /** 通信できない状態にする */
  offline: () => void
  /** 次の応答を差し替える */
  reply: (fn: (r: Req) => Res) => void
  handle: (r: Req) => Promise<Res | undefined>
  message: (data: unknown) => Promise<void>
  install: () => Promise<void>
  /** 通知（docs/11 §7）。payload は push サービスから来る生の中身 */
  push: (payload: unknown) => Promise<void>
  notificationClick: (data: unknown) => Promise<void>
  shown: { title: string; options: Record<string, unknown> }[]
  /** 通知を押した結果ひらいた／焦点を当てた先 */
  navigated: string[]
  opened: string[]
  /** 既に開いている窓を用意する */
  openWindows: (urls: string[]) => void
}

function load(): Harness {
  const listeners = new Map<string, (e: unknown) => void>()
  const cachesStub = makeCaches()
  const fetches: string[] = []
  let responder: (r: Req) => Res = () => res('ok')
  let down = false

  const shown: { title: string; options: Record<string, unknown> }[] = []
  const navigated: string[] = []
  const opened: string[] = []
  let windows: { url: string; focused: boolean }[] = []

  const self = {
    location: { origin: ORIGIN },
    addEventListener: (t: string, fn: (e: unknown) => void) => void listeners.set(t, fn),
    skipWaiting: async () => {},
    registration: {
      showNotification: async (title: string, options: Record<string, unknown>) =>
        void shown.push({ title, options }),
    },
    clients: {
      claim: async () => {},
      matchAll: async () => windows.map(w => ({
        url: w.url,
        focus: async () => { w.focused = true },
        navigate: async (u: string) => { navigated.push(u) },
      })),
      openWindow: async (u: string) => { opened.push(u) },
    },
  }
  const fetchStub = async (r: Req) => {
    fetches.push(r.url)
    if (down) throw new TypeError('Failed to fetch')
    return responder(r)
  }

  new Function('self', 'caches', 'fetch', SW_SRC)(self, cachesStub.api, fetchStub)

  const fire = async (type: string, event: Record<string, unknown>) => {
    const waits: Promise<unknown>[] = []
    await listeners.get(type)!({ ...event, waitUntil: (p: Promise<unknown>) => waits.push(p) })
    await Promise.all(waits)
  }

  return {
    caches: cachesStub,
    fetches,
    offline: () => { down = true },
    reply: fn => { responder = fn },
    install: async () => {
      await fire('install', {})
      await fire('activate', {})
    },
    message: async data => { await fire('message', { data }) },
    shown, navigated, opened,
    openWindows: urls => { windows = urls.map(url => ({ url, focused: false })) },
    push: async payload => {
      // ★ 本物の PushEvent と同じ形にする。data.json() は中身が JSON でなければ投げる
      const data = payload === undefined ? null : {
        json: () => {
          if (typeof payload === 'string') return JSON.parse(payload)
          return payload
        },
      }
      await fire('push', { data })
    },
    notificationClick: async data => {
      let closed = false
      await fire('notificationclick', {
        notification: { data, close: () => { closed = true } },
      })
      expect(closed).toBe(true)
    },
    handle: async request => {
      let captured: Promise<Res> | undefined
      await listeners.get('fetch')!({
        request,
        respondWith: (p: Promise<Res>) => { captured = p },
        waitUntil: () => {},
      })
      return captured ? await captured : undefined
    },
  }
}

const pages = (h: Harness) => [...(h.caches.store.get('historia-pages-v1')?.keys() ?? [])]

describe('Service Worker', () => {
  let sw: Harness
  beforeEach(async () => {
    sw = load()
    await sw.install()
  })

  describe('出題系を端末に残さない（docs/12 §6.1）', () => {
    /**
     * ★ この試験が本題である。/study と /checktest を保存すると、
     *   解答済みの正答と解説が端末のディスクに残る。
     *   docs/12 §6.1 の「正答を解答前にクライアントへ渡さない」は、
     *   端末に置いた時点で意味を失う。
     */
    it('/study は保存しない', async () => {
      await sw.handle(req('/study'))
      expect(pages(sw)).toEqual([])
    })

    it('/checktest は保存しない', async () => {
      await sw.handle(req('/checktest/abc'))
      expect(pages(sw)).toEqual([])
    })

    it('/checktest/result は保存しない（正答と解説を描画している）', async () => {
      await sw.handle(req('/checktest/result/abc'))
      expect(pages(sw)).toEqual([])
    })

    /** ★ 通信できなくても、保存済みの出題を出さない。/offline に落とす */
    it('オフラインの /study は保存済みを出さず /offline に落とす', async () => {
      // 先に無理やり保存させても
      const c = await sw.caches.api.open('historia-pages-v1')
      await c.put(req('/study'), res('出題の残骸'))
      sw.offline()
      const r = await sw.handle(req('/study'))
      expect(r!.body).toBe('precached /offline')
    })
  })

  describe('オフラインで読めるもの', () => {
    it('/material は保存し、通信できないときに出す', async () => {
      sw.reply(() => res('教材の本文'))
      await sw.handle(req('/material/abc'))
      expect(pages(sw)).toEqual([`${ORIGIN}/material/abc`])

      sw.offline()
      const r = await sw.handle(req('/material/abc'))
      expect(r!.body).toBe('教材の本文')
    })

    it('/records は保存する', async () => {
      await sw.handle(req('/records'))
      expect(pages(sw)).toEqual([`${ORIGIN}/records`])
    })

    /**
     * ★ 既定は「保存しない」である。列挙した経路だけを保存する。
     *   逆（既定で保存し、危ないものを除く）にすると、
     *   画面を1つ足したときに黙って混ざる。
     */
    it('列挙していない経路は保存しない', async () => {
      await sw.handle(req('/'))
      await sw.handle(req('/drills'))
      await sw.handle(req('/profile'))
      expect(pages(sw)).toEqual([])
    })

    it('保存していない経路はオフラインで /offline に落ちる', async () => {
      sw.offline()
      const r = await sw.handle(req('/drills'))
      expect(r!.body).toBe('precached /offline')
    })
  })

  describe('共用端末に他人の内容を残さない', () => {
    /**
     * ★ 未認証は 404（docs/10 G2）。ログアウトでも session 切れでも
     *   別人が開いても、保護された経路は 404 になるので、それを合図に消す。
     */
    it('404 が返ったら保存済みの頁を消す', async () => {
      await sw.handle(req('/material/abc'))
      expect(pages(sw)).toHaveLength(1)

      sw.reply(() => res('', 404))
      await sw.handle(req('/'))
      expect(pages(sw)).toEqual([])
    })

    it('postMessage({type:"purge"}) で消える', async () => {
      await sw.handle(req('/material/abc'))
      await sw.message({ type: 'purge' })
      expect(pages(sw)).toEqual([])
    })

    it('知らない message では消さない', async () => {
      await sw.handle(req('/material/abc'))
      await sw.message({ type: 'なにか' })
      expect(pages(sw)).toHaveLength(1)
    })
  })

  describe('握ってはいけない要求', () => {
    /**
     * ★ Server Action は POST で来る。採点も読了もここを通るので、
     *   握ると閉ループが壊れる。
     */
    it('POST には触らない', async () => {
      expect(await sw.handle(req('/study', { method: 'POST' }))).toBeUndefined()
      expect(sw.fetches).toEqual([])
    })

    it('別オリジン（字体など）には触らない', async () => {
      expect(await sw.handle({
        method: 'GET', url: 'https://fonts.gstatic.com/x.woff2', mode: 'no-cors',
      })).toBeUndefined()
    })

    /** ★ RSC の取得は握らない。失敗させれば Next 自身がハードナビゲーションに落ちる */
    it('画面遷移でない GET には触らない', async () => {
      expect(await sw.handle(req('/material/abc?_rsc=1', { mode: 'same-origin' })))
        .toBeUndefined()
    })
  })

  describe('_next/static', () => {
    it('2回目は通信しない（内容ハッシュ付きで不変）', async () => {
      const asset = req('/_next/static/chunks/x.js', { mode: 'no-cors' })
      await sw.handle(asset)
      const before = sw.fetches.length
      const r = await sw.handle(asset)
      expect(sw.fetches).toHaveLength(before)
      expect(r!.ok).toBe(true)
    })

    it('個人の内容の消去では消えない（アプリの部品なので消す理由がない）', async () => {
      await sw.handle(req('/_next/static/chunks/x.js', { mode: 'no-cors' }))
      await sw.message({ type: 'purge' })
      expect([...(sw.caches.store.get('historia-static-v1')?.keys() ?? [])]).toHaveLength(1)
    })
  })

  describe('版の入れ替え', () => {
    it('古い版のキャッシュを消す', async () => {
      const fresh = load()
      fresh.caches.store.set('historia-pages-v0', new Map())
      fresh.caches.store.set('historia-shell-v0', new Map())
      await fresh.install()
      expect([...fresh.caches.store.keys()].filter(n => n.endsWith('-v0'))).toEqual([])
    })
  })

  /**
   * 通知（docs/11-ux.md §7・docs/12-nonfunctional.md §10）
   *
   * ★ ここも本文の読み取りではなく、実際に push の handler を起こして
   *   showNotification に何が渡ったかを見る。
   */
  describe('リマインドの通知', () => {
    it('届いた内容をそのまま通知にする', async () => {
      await sw.push({ title: 'HISTORIA', body: '今日の復習が 12 件あります。', url: '/study' })
      expect(sw.shown).toHaveLength(1)
      expect(sw.shown[0]!.title).toBe('HISTORIA')
      expect(sw.shown[0]!.options.body).toBe('今日の復習が 12 件あります。')
      expect(sw.shown[0]!.options.data).toEqual({ url: '/study' })
    })

    /**
     * ★ 溜めない。届かなかった夜のぶんが翌朝まとめて3通並ぶと、
     *   通知そのものが読まれなくなる。同じ tag で置き換える
     */
    it('通知は積み上がらない（tag を固定する）', async () => {
      await sw.push({ title: 'HISTORIA', body: '1通目', url: '/study' })
      await sw.push({ title: 'HISTORIA', body: '2通目', url: '/study' })
      expect(sw.shown.map(n => n.options.tag)).toEqual(['historia-remind', 'historia-remind'])
      // 置き換えのたびに鳴らさない
      expect(sw.shown[1]!.options.renotify).toBeUndefined()
    })

    it('中身が壊れていても通知は出す（来ていることは分かるようにする）', async () => {
      await sw.push('これは JSON ではない')
      expect(sw.shown).toHaveLength(1)
      expect(sw.shown[0]!.options.body).toBe('今日の学習がまだ残っています')
    })

    it('payload が無くても通知は出す', async () => {
      await sw.push(undefined)
      expect(sw.shown).toHaveLength(1)
      expect(sw.shown[0]!.title).toBe('HISTORIA')
    })

    /**
     * ★ 開く先を自分の生成元に閉じる。payload は push サービスを経由して届く。
     *   VAPID で送信者は検証されるが、url をそのまま信じる設計にはしない。
     *   `https://…` を通してしまうと、通知1つで任意の場所へ連れて行ける。
     */
    it('外部の URL は通さない（/ 始まりだけ）', async () => {
      await sw.push({ title: 'x', body: 'y', url: 'https://example.com/phish' })
      expect(sw.shown[0]!.options.data).toEqual({ url: '/study' })
    })

    it('プロトコル相対の URL も通さない', async () => {
      await sw.push({ title: 'x', body: 'y', url: '//example.com/phish' })
      // ★ '//…' は '/' 始まりなので素朴な検査は通ってしまう。
      //   通ってしまう場合はここが落ちる
      expect(sw.shown[0]!.options.data).toEqual({ url: '/study' })
    })
  })

  describe('通知を押したとき', () => {
    it('開いている窓があればそれを使う（同じ画面を何枚も開かない）', async () => {
      sw.openWindows([`${ORIGIN}/records`])
      await sw.notificationClick({ url: '/study' })
      expect(sw.navigated).toEqual(['/study'])
      expect(sw.opened).toEqual([])
    })

    it('窓が無ければ新しく開く', async () => {
      sw.openWindows([])
      await sw.notificationClick({ url: '/study' })
      expect(sw.opened).toEqual(['/study'])
    })

    it('他の生成元の窓は使わない', async () => {
      sw.openWindows(['https://example.com/'])
      await sw.notificationClick({ url: '/study' })
      expect(sw.navigated).toEqual([])
      expect(sw.opened).toEqual(['/study'])
    })

    it('data が無くても /study へ行く', async () => {
      sw.openWindows([])
      await sw.notificationClick(undefined)
      expect(sw.opened).toEqual(['/study'])
    })

    // ★ push handler が通した値しか来ないはずだが、「はずだ」に頼らない
    it('data に外部の URL が入っていても外へ出ない', async () => {
      sw.openWindows([])
      await sw.notificationClick({ url: '//example.com/phish' })
      expect(sw.opened).toEqual(['/study'])
    })
  })
})
