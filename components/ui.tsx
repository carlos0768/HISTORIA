/**
 * Litverse の部品
 *
 * クラス名は docs/design/litverse.css と historia-overrides.css のものをそのまま使う。
 * ここで新しい意匠を定義しない（二重定義を作らない）。
 *
 * ★ .lv-card は枠だけで余白を持たない。中身は .lv-card__pad で包む。
 * ★ .lv-device はモックの「端末の絵」なので実機では使わない。.lv-root を使う。
 */
import type { ReactNode } from 'react'
import Link from 'next/link'
import type { MasteryStatus } from '@/lib/domain/weakness'

/**
 * フッタの3タブ（docs/11-ux.md §9）。
 *
 * ★ ここに載せる行き先は**必ず実在させる**。行き止まりのタブを出すと、
 *   利用者は「壊れている」と判断してアプリごと使うのをやめる。
 */
export const TABS = [
  { key: 'home', href: '/', label: 'ホーム', icon: '⌂' },
  { key: 'drills', href: '/drills', label: '特訓', icon: '◆' },
  { key: 'records', href: '/records', label: '記録', icon: '▤' },
] as const

/**
 * 画面がシェルのどこに属するか。
 *
 * ★ 'settings' はタブではない（docs/11 §9 は3タブと定めている）。
 *   デスクトップのサイドバーで別の見出しに置くための印である。
 *   TABS に足すと、モバイルのフッタが4つになって仕様から外れる。
 */
export type TabKey = typeof TABS[number]['key'] | 'settings'

/**
 * 1画面。
 *
 * ★ `tab` を渡した画面だけに導線が付く。認証まわり（招待コード・ログイン・生年月日）は
 *   ログイン前なので渡さない。渡すと未登録の人にアプリの構造が見える。
 *
 * ★ `aside` は 1440px 以上でだけ現れる資料面（設計系の三分割の右 320px）。
 *   モバイルでは**そもそも並べない**ので、中身の描画費用もかからない。
 */
export function Screen({
  title, children, tab, aside,
}: {
  title: string
  children: ReactNode
  tab?: TabKey
  aside?: ReactNode
}) {
  if (!tab) {
    return (
      <div className="lv-root hs-screen">
        <header className="lv-navbar"><span className="lv-navbar__title">{title}</span></header>
        <div className="hs-pad">{children}</div>
      </div>
    )
  }
  return (
    <div className="lv-root hs-screen hs-shell">
      <nav className="hs-shell__side" aria-label="メニュー">
        <span className="hs-side__label">学習</span>
        {TABS.map(t => (
          <Link key={t.key} href={t.href}
                className={`hs-side__item${t.key === tab ? ' hs-side__item--active' : ''}`}
                aria-current={t.key === tab ? 'page' : undefined}>
            {t.label}
          </Link>
        ))}
        {/* ★ 設定はタブに入れない。docs/11 §9 が3タブと定めている。
             デスクトップは横に余裕があるので、別の見出しで下に置く。
             モバイルからは記録タブの末尾から入る。 */}
        <span className="hs-side__label">アカウント</span>
        <Link href="/settings"
              className={`hs-side__item${tab === 'settings' ? ' hs-side__item--active' : ''}`}
              aria-current={tab === 'settings' ? 'page' : undefined}>
          設定
        </Link>
      </nav>

      <div className="hs-shell__main">
        <header className="lv-navbar"><span className="lv-navbar__title">{title}</span></header>
        <div className="hs-pad">{children}</div>
        <nav className="lv-tabbar" aria-label="メニュー">
          {TABS.map(t => (
            <Link key={t.key} href={t.href}
                  className={`lv-tabbar__item${t.key === tab ? ' lv-tabbar__item--active' : ''}`}
                  aria-current={t.key === tab ? 'page' : undefined}>
              <span className="lv-tabbar__icon" aria-hidden="true">{t.icon}</span>
              {t.label}
            </Link>
          ))}
        </nav>
      </div>

      {aside && <aside className="hs-shell__aside">{aside}</aside>}
    </div>
  )
}

export function Card({ children }: { children: ReactNode }) {
  return (
    <div className="lv-card">
      <div className="lv-card__pad hs-stack">{children}</div>
    </div>
  )
}

const STATUS_LABEL: Record<MasteryStatus, string> = {
  unknown: 'まだ測っていない',
  weak: '弱い',
  shaky: 'あと少し',
  mastered: '身についた',
}

export function StatusChip({ status }: { status: MasteryStatus }) {
  return <span className={`hs-status hs-status--${status}`}>{STATUS_LABEL[status]}</span>
}

/** 習得度のバー。weak は朱（濃）で塗る */
export function MasteryBar({ value }: { value: number }) {
  const pct = Math.round(value * 100)
  return (
    <div className="hs-mastery">
      <div className="hs-mastery__track">
        <div
          className={`hs-mastery__fill${value < 0.6 ? ' hs-mastery__fill--weak' : ''}`}
          style={{ width: `${pct}%` }}
        />
      </div>
      <span className="hs-mastery__num">{pct}%</span>
    </div>
  )
}

/**
 * 「読む」と「身につく」を別のバーで並べる（docs/05 §6）。
 * 進捗率だけを見せると「たくさん読んだのに1%も進まない」と感じて離脱するため、
 * 2本並べて別物であることを可視化する。
 */
export function TwoBars({
  masteredCount, totalKc, materialsRead, materialsTotal,
}: { masteredCount: number; totalKc: number; materialsRead: number; materialsTotal: number }) {
  const m = totalKc === 0 ? 0 : masteredCount / totalKc
  const r = materialsTotal === 0 ? 0 : materialsRead / materialsTotal
  return (
    <div className="hs-stack">
      <div className="hs-stack">
        <span className="lv-label">身についた</span>
        <MasteryBar value={m} />
        <span className="lv-caption">{masteredCount} / {totalKc} KC</span>
      </div>
      <div className="hs-stack">
        <span className="lv-label">読んだ</span>
        <MasteryBar value={r} />
        <span className="lv-caption">教材 {materialsRead} / {materialsTotal}</span>
      </div>
    </div>
  )
}

export function Alert({ title, children }: { title: string; children?: ReactNode }) {
  return (
    <div className="hs-alert">
      <p className="hs-alert__title">{title}</p>
      {children}
    </div>
  )
}

export function Empty({ children }: { children: ReactNode }) {
  return <div className="hs-empty">{children}</div>
}
