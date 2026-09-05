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
 * モバイルフッタのタブ。
 *
 * ★ ここに載せる行き先は**必ず実在させる**。行き止まりのタブを出すと、
 *   利用者は「壊れている」と判断してアプリごと使うのをやめる。
 */
export const TABS = [
  { key: 'home', href: '/', label: 'ホーム', icon: '⌂' },
  { key: 'drills', href: '/drills', label: '特訓', icon: '◆' },
  { key: 'textbook', href: '/textbook', label: '教科書', icon: '▤' },
  { key: 'research', href: '/research', label: '検索', icon: '⌕' },
] as const

/**
 * 画面がシェルのどこに属するか。
 *
 * ★ 'settings' はタブではない。
 *   デスクトップのサイドバーで別の見出しに置くための印である。
 */
export type TabKey = typeof TABS[number]['key'] | 'settings' | typeof DESK[number]['key']

/**
 * デスクトップにだけ出す画面（docs/06-desktop.md）。
 *
 * ここはサイドバー（1024px 以上で現れる）専用の一覧。
 * 検索はモバイルフッタにも置くため TABS 側で管理する。
 */
export const DESK = [
  { key: 'library', href: '/library', label: '教材の一覧' },
  { key: 'timeline', href: '/timeline', label: '年表と地図' },
  { key: 'map', href: '/map', label: '歴史地球儀' },
] as const

/**
 * 1画面。
 *
 * ★ `tab` を渡した画面だけに導線が付く。認証まわり（招待コード・ログイン・生年月日）は
 *   ログイン前なので渡さない。渡すと未登録の人にアプリの構造が見える。
 *
 * ★ `aside` はデスクトップで現れる資料面（設計系の三分割の右 320px）。
 *   モバイルでは**そもそも並べない**ので、中身の描画費用もかからない。
 */
export function Screen({
  title, children, tab, aside, trailing, layout = 'reading',
}: {
  title: string
  children: ReactNode
  tab?: TabKey
  aside?: ReactNode
  /** 見出しの右端に置くもの（連続日数など）。docs/11-ux.md §7 */
  trailing?: ReactNode
  /** 読書幅を外して道具面を広く使う画面。現在は歴史地球儀だけ。 */
  layout?: 'reading' | 'workspace'
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
    <div className={`lv-root hs-screen hs-shell${layout === 'workspace' ? ' hs-shell--workspace' : ''}`}>
      <nav className="hs-shell__side" aria-label="メニュー">
        <span className="hs-side__label">学習</span>
        {TABS.map(t => (
          <Link key={t.key} href={t.href}
                className={`hs-side__item${t.key === tab ? ' hs-side__item--active' : ''}`}
                aria-current={t.key === tab ? 'page' : undefined}>
            {t.label}
          </Link>
        ))}
        {/* ★ 広い画面でだけ出す。モバイルでは下のフッタを使う */}
        <span className="hs-side__label">机の上</span>
        {DESK.map(d => (
          <Link key={d.key} href={d.href}
                className={`hs-side__item${d.key === tab ? ' hs-side__item--active' : ''}`}
                aria-current={d.key === tab ? 'page' : undefined}>
            {d.label}
          </Link>
        ))}

        {/* ★ 設定は主要タブに入れない。デスクトップは横に余裕があるので、
             別の見出しで下に置く。モバイルでも直接 URL から開ける。 */}
        <span className="hs-side__label">アカウント</span>
        <Link href="/settings"
              className={`hs-side__item${tab === 'settings' ? ' hs-side__item--active' : ''}`}
              aria-current={tab === 'settings' ? 'page' : undefined}>
          設定
        </Link>
      </nav>

      <div className="hs-shell__main">
        <header className="lv-navbar">
          <span className="lv-navbar__title">{title}</span>
          {trailing && <span className="hs-navbar__trailing">{trailing}</span>}
        </header>
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

      {/* ★ ⌘K はここに置かない。app/palette-mount.tsx が layout に1つだけ載せる。
           画面ごとに渡す形にしていたときは渡し忘れが起き、
           「机の上」3画面がモバイルから到達できなかった（app/palette-mount.tsx の注記） */}
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

/**
 * 資料テーブル（docs/06-desktop.md 03「資料テーブル」）
 *
 * ★ リポジトリに `<table>` は1つも無かった。モバイル優先で作ってきたので、
 *   縦に積む形しか要らなかった。デスクトップでは横に並べたほうが読める。
 *
 * ★ 行の高さは 36px、数字は `tabular-nums`（設計系の寸法）。
 *   年号が桁ごとに揺れると、並んだときに読み比べられない。
 *
 * ★ 横溢れは**自前の `overflow-x: auto`** で受ける。画面ごと横スクロールさせない。
 *   1440px 未満でもこの部品は使えるようにしてある（モバイルで開いても壊れない）。
 */
export type Column<T> = {
  key: string
  label: string
  /** 数字の列。等幅にして右に寄せる */
  numeric?: boolean
  /** 列幅（CSS grid の値）。省略すると 1fr */
  width?: string
  render: (row: T) => ReactNode
}

export function DataTable<T>({
  columns, rows, rowKey, empty = 'ありません。', caption,
}: {
  columns: readonly Column<T>[]
  rows: readonly T[]
  rowKey: (row: T) => string
  empty?: string
  /** 表が何であるかを読み上げに伝える。目には見えない */
  caption?: string
}) {
  if (rows.length === 0) return <p className="lv-caption">{empty}</p>
  const template = columns.map(c => c.width ?? '1fr').join(' ')
  return (
    <div className="hs-table__scroll">
      <table className="hs-table" style={{ ['--hs-table-cols' as string]: template }}>
        {caption && <caption className="hs-table__caption">{caption}</caption>}
        <thead>
          <tr className="hs-table__row">
            {columns.map(c => (
              <th key={c.key} scope="col"
                  className={`hs-table__cell hs-table__cell--head${c.numeric ? ' hs-table__cell--num' : ''}`}>
                {c.label}
              </th>
            ))}
          </tr>
        </thead>
        <tbody>
          {rows.map(r => (
            <tr className="hs-table__row" key={rowKey(r)}>
              {columns.map(c => (
                <td key={c.key}
                    className={`hs-table__cell${c.numeric ? ' hs-table__cell--num' : ''}`}>
                  {c.render(r)}
                </td>
              ))}
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
