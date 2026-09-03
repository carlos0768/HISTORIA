import type { Metadata, Viewport } from 'next'
import './globals.css'
import { SwRegister } from './sw-register'
import { PaletteMount } from './palette-mount'

export const metadata: Metadata = {
  title: 'HISTORIA',
  description: '受験世界史の弱点を測って、そこだけを出し直す',
  // 10-legal-risk.md §3.2 G3: 非公開・招待制
  robots: { index: false, follow: false },
  // ★ iOS は manifest を見ない。ホーム画面に足したときの見た目は
  //   この2つで決まる（docs/12 §10）
  appleWebApp: { capable: true, title: 'HISTORIA', statusBarStyle: 'default' },
}

export const viewport: Viewport = {
  width: 'device-width',
  initialScale: 1,
  themeColor: '#FCF6E8', // 紙
}

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="ja">
      <body>
        {children}
        <SwRegister />
        {/* ★ ⌘K は画面ごとではなくここに1つだけ置く。
             画面ごとに渡す形にしていたときは、人が出発する画面
             （ホーム・特訓・記録・出題）に渡し忘れていて、
             「机の上」3画面がモバイルから到達できなかった。
             layout に置けば渡し忘れという失敗の形が無くなる。 */}
        <PaletteMount />
      </body>
    </html>
  )
}
