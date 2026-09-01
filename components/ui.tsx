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
import type { MasteryStatus } from '@/lib/domain/weakness'

export function Screen({ title, children }: { title: string; children: ReactNode }) {
  return (
    <div className="lv-root hs-screen">
      <header className="lv-navbar">
        <span className="lv-navbar__title">{title}</span>
      </header>
      <div className="hs-pad">{children}</div>
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
