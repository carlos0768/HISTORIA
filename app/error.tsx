'use client'

import { useEffect } from 'react'
import { ErrorScreen } from '@/components/error-screen'

/**
 * 画面の中で起きた例外を受け止める（Next 16 の作法: error.tsx）
 *
 * ★ prop は `retry` である。`reset` ではない。
 *   node_modules/next/dist/docs/01-app/03-api-reference/03-file-conventions/error.md
 *   の版歴に `v16.3.0 retry prop became stable` と在り、本文も retry を勧めている
 *   （reset は「内容を取り直さずに境界だけ描き直したい特別な理由がある場合」）。
 *
 * ★ この境界は**同じ segment の layout を包まない**（同 md）。
 *   root layout（app/layout.tsx の PaletteMount）で落ちた場合は
 *   app/global-error.tsx が受ける。
 *
 * ★ 中身は components/error-screen.tsx に在る。app/** は試験できないので、
 *   ここは受け渡しだけにしてある。
 */
export default function AppError({
  error, retry,
}: {
  error: Error & { digest?: string }
  retry: () => void
}) {
  useEffect(() => {
    // 手元では原因が、本番では digest だけが出る（本番の message は総称）
    console.error(error)
  }, [error])

  return <ErrorScreen digest={error.digest} retry={retry} />
}
