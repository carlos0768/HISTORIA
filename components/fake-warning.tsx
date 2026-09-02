import { Alert } from './ui'

/**
 * 「これは AI の鍵が無いまま作った偽の中身です」と言う。
 *
 * ★ なぜ要るか。`lib/ai/client.ts` の resolveProvider は、鍵が無いと
 *   **黙ってフェイクのプロバイダに落ちる**。閉ループを鍵なしで通すための仕組みで、
 *   開発には要るのだが、そのまま本番に出ると
 *   「それらしい日本語の教材が出てきて、中身は全部でたらめ」になる。
 *   受験勉強でこれは最悪の失敗の仕方をする — **嘘を覚えて、気づかない**。
 *
 * ★ 記録から判定する。実行時の設定ではなく material.provider を見るので、
 *   後から鍵を入れても、**そのとき作った教材は偽物のまま**だと分かる。
 */
export const isFake = (provider: string | null | undefined): boolean =>
  !!provider && provider.startsWith('fake:')

export function FakeWarning({ provider }: { provider: string | null | undefined }) {
  if (!isFake(provider)) return null
  return (
    <Alert title="この中身は本物ではありません">
      <p className="lv-body">
        AI の鍵が設定されていない状態で作られたため、本文も設問も
        <strong>動作確認用のでたらめ</strong>です。覚えないでください。
      </p>
      <p className="lv-caption">
        <code>GEMINI_API_KEY</code> と <code>ANTHROPIC_API_KEY</code> を設定してから
        作り直すと、本物になります。
      </p>
    </Alert>
  )
}

/**
 * これから作るものが偽物になる、という予告。
 *
 * ★ 作る前に言う。作ってから言うと、読んでしまってからでは遅い。
 */
export function FakeNotice() {
  return (
    <Alert title="いま教材を作ると、中身はでたらめになります">
      <p className="lv-body">
        AI の鍵（<code>GEMINI_API_KEY</code> / <code>ANTHROPIC_API_KEY</code>）が
        設定されていません。動作確認はできますが、学習には使えません。
      </p>
    </Alert>
  )
}
