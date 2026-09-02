/**
 * ESLint の設定
 *
 * package.json に "lint": "eslint ." があるのに設定ファイルが無く、
 * npm run lint がずっと失敗していた。next の推奨だけを有効にする。
 * eslint-config-next 16 はフラット設定をそのまま輸出するので FlatCompat は要らない。
 */
import next from 'eslint-config-next'
import nextCoreWebVitals from 'eslint-config-next/core-web-vitals'
import nextTypescript from 'eslint-config-next/typescript'

const config = [
  { ignores: ['.next/**', 'node_modules/**', 'docs/design/**'] },
  ...(Array.isArray(next) ? next : [next]),
  ...(Array.isArray(nextCoreWebVitals) ? nextCoreWebVitals : [nextCoreWebVitals]),
  ...(Array.isArray(nextTypescript) ? nextTypescript : [nextTypescript]),
  {
    rules: {
      // 使わない引数は _ を頭に付けて残す（インターフェイスの形を保つため）
      '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
    },
  },
]

export default config
