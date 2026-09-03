'use client'

/**
 * root layout ごと落ちたときの最後の受け皿（Next 16 の作法: global-error.tsx）
 *
 * ★ なぜ error.tsx だけでは足りないのか。error.tsx は**同じ segment の
 *   layout を包まない**（作法書 error.md）。app/layout.tsx は
 *   PaletteMount（DB を触る）を描くので、DB が届かないと
 *   **layout そのものが落ちて全ページが 500 になる**。そこは error.tsx の
 *   外側なので、ここでしか受けられない。
 *
 * ★ **globals.css が届かない。** 作法書が「global-error と組み込みの 500 は
 *   自前の document を描くので、あなたの global styles を含まない」と
 *   明記している。したがって .lv-* のクラスは使えず、様式は直書きする。
 *   色は docs/design/litverse.css のトークンと同じ値を写している
 *   （紙 #FCF6E8 / 墨 #171512 / 鼠 #8A7F6C / 朱 #F4703C）。
 *   **ここでトークンを再定義しない**（二重定義を作らない）ためにも、
 *   出すのは1画面ぶんの最小限に留める。
 *
 * ★ metadata は使えない（境界は Client Component）。題は React の <title> で出す。
 *
 * ★ <html> と <body> を自前で持つ。これが無いと build か実行時に落ちる。
 */
export default function GlobalError({
  error, retry,
}: {
  error: Error & { digest?: string }
  retry: () => void
}) {
  return (
    <html lang="ja">
      <body style={{ margin: 0, background: '#EFE4CC' }}>
        <title>HISTORIA</title>
        <main
          style={{
            maxWidth: 480, minHeight: '100dvh', margin: '0 auto', padding: '28px 20px',
            background: '#FCF6E8', color: '#171512',
            font: '15px/1.7 "Hiragino Mincho ProN", "Yu Mincho", serif',
            display: 'flex', flexDirection: 'column', gap: 16,
          }}
        >
          <h1 style={{ margin: 0, fontSize: 17, letterSpacing: '0.04em' }}>HISTORIA</h1>
          <p style={{ margin: 0 }}>アプリを開けませんでした。</p>
          <p style={{ margin: 0, fontSize: 13, color: '#8A7F6C' }}>
            もう一度ためすと直ることがあります。
          </p>
          <button
            type="button"
            onClick={() => retry()}
            style={{
              minHeight: 44, padding: '0 20px', cursor: 'pointer',
              border: '1.5px solid #171512', borderRadius: 2,
              background: '#F4703C', color: '#171512', font: 'inherit', fontWeight: 600,
            }}
          >
            もう一度ためす
          </button>
          {error.digest && (
            <p style={{ margin: 0, fontSize: 13, color: '#8A7F6C' }}>
              識別番号 <code style={{ fontFamily: 'ui-monospace, monospace' }}>{error.digest}</code>
            </p>
          )}
        </main>
      </body>
    </html>
  )
}
