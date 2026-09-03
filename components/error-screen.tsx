'use client'

import { Screen, Empty } from './ui'

/**
 * 例外を受け止める画面（app/error.tsx の中身）
 *
 * ★ なぜ要るのか。2026-09-03 に作者が本番で招待コードを打つと、Next の
 *   素の 500（"Application error: a server-side exception has occurred"）が
 *   出た。`app/error.tsx` が1つも無かったので、**どの画面のどの例外でも
 *   英語の同じ画面**になっていた。
 *
 * ★ 遷移リンクを置かない。未認証の人を `/` へ送ると proxy.ts が 404 を返し
 *   （docs/10 G2）、ログイン済みの人を `/invite` へ送るのも変である。
 *   ここは「誰が見ているか分からない」場所なので、その場でやり直す手だけを出す。
 *
 * ★ digest を出す。本番では Server 側の error.message は総称に
 *   置き換わるため（Next 16 の作法書 error.md「error.message」の項）、
 *   digest が Vercel の関数ログと突き合わせる**唯一の手段**である。
 *   これを出さないと、作者は利用者から「壊れた」以上の情報を受け取れない。
 *
 * ★ 中身をここに置く理由。`app/**` は vitest の include に無く
 *   （vitest.config.ts）試験できない。`components/**` なら jsdom で
 *   本物の DOM に載せて確かめられる。app/error.tsx は薄い殻にする。
 */
export function ErrorScreen({ digest, retry }: { digest?: string; retry: () => void }) {
  return (
    <Screen title="HISTORIA">
      <Empty>
        <p className="lv-body">うまくいきませんでした。</p>
        <p className="lv-caption">
          もう一度ためすと直ることがあります。
        </p>
        <button type="button" className="lv-btn lv-btn--primary" onClick={() => retry()}>
          もう一度ためす
        </button>
        {digest && (
          <>
            <span className="lv-label">識別番号</span>
            <p className="lv-caption">
              {/* ★ 何度やっても同じときに、作者がログを引くための番号 */}
              <code>{digest}</code>
            </p>
          </>
        )}
      </Empty>
    </Screen>
  )
}
