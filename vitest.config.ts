import { defineConfig } from 'vitest/config'
import { fileURLToPath } from 'node:url'

export default defineConfig({
  resolve: { alias: { '@': fileURLToPath(new URL('.', import.meta.url)) } },
  test: {
    environment: 'node',
    // proxy.ts は Next の作法で置き場所が決まっているため、試験も根に置く
    include: ['lib/**/*.test.ts', 'scripts/**/*.test.ts', 'proxy.test.ts'],

    /**
     * 実 DB を使うテストは既定の 5 秒では足りない。
     *
     * 2026-09-02 に CI が2件の timeout で落ちた。同じテストは手元では
     * 427ms / 521ms で終わっており、**CI のランナーが約10倍遅い**ことが原因だった
     * （seed は行を1件ずつ INSERT するので往復が数百回になる）。
     * 手元の最遅が約0.5秒、CI ではその10倍で5秒。既定値と同じ幅しか無かった。
     *
     * 30秒は CI の実測最悪値のさらに6倍で、取り違えようのない停止だけを捕まえる。
     * テストを飛ばしたり緩めたりはしていない。検証内容は変えていない。
     */
    testTimeout: 30_000,
    hookTimeout: 120_000,
  },
})
