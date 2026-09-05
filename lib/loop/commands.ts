/**
 * ⌘K でさがせるもの（docs/design/litverse-desktop-system.dc.html 03）
 *
 * ★ 何をさがせるかを1か所で決める。画面ごとにばらばらに作ると、
 *   「あの単元はさがせるのに、この単元はさがせない」が起きる。
 *
 * ★ 検索は**クライアント側で**する（components/palette.tsx の filterCommands）。
 *   打つたびにサーバーへ往復すると、打鍵に追いつかない。
 *   単元は約200件・画面は10件ほどなので、全部渡しても軽い。
 *
 * ★ 教材の本文は入れない。本文は毎回生成で人によって違い、
 *   全員ぶんを渡すことになる（他人の教材が見えてしまう）。
 *   さがせるのは**構造**（単元・画面・年表の出来事）だけである。
 */
import type { Sql } from 'postgres'

export type Command = {
  id: string
  label: string
  kind: string
  href: string
  keywords?: string
}

/** どの画面からでも行ける先。ここは DB を見ない */
export const SCREEN_COMMANDS: readonly Command[] = [
  { id: 's.home', label: 'ホーム', kind: '移動', href: '/' },
  { id: 's.study', label: '今日の出題', kind: '移動', href: '/study', keywords: 'とく 問題' },
  { id: 's.drills', label: '集中特訓の一覧', kind: '移動', href: '/drills' },
  { id: 's.new', label: '範囲と締切を決める', kind: '移動', href: '/drills/new', keywords: 'あたらしい' },
  { id: 's.records', label: '記録', kind: '移動', href: '/records', keywords: '弱点 連続' },
  { id: 's.library', label: '教材の一覧', kind: '移動', href: '/library' },
  { id: 's.timeline', label: '年表と地図', kind: '移動', href: '/timeline' },
  { id: 's.map', label: '地図', kind: '移動', href: '/map' },
  { id: 's.research', label: '調べる', kind: '移動', href: '/research', keywords: '検索 リサーチ 出来事 年表' },
  { id: 's.diagnostic', label: '診断テスト', kind: '移動', href: '/diagnostic' },
  { id: 's.settings', label: '設定', kind: '移動', href: '/settings' },
]

/** 上限。これを超えると初回の転送が重くなるうえ、絞り込みの意味も薄れる */
export const MAX_COMMANDS = 600

/**
 * さがせるものを組み立てる。
 *
 * ★ 出来事（canon_event）は 1,180 件ある。全部渡すと重いので、
 *   年表の画面へ渡す入口だけを置き、個々の出来事は年表側で絞る。
 *   ここに入れるのは**単元**（約200件）までにする。
 */
export async function commandsFor(db: Sql): Promise<Command[]> {
  const units = await db<{ id: string; label: string; parent_label: string | null }[]>`
    SELECT u.id, u.label, p.label AS parent_label
      FROM syllabus_unit u
      LEFT JOIN syllabus_unit p ON p.id = u.parent_id
     -- level は 1=部 2=章 3=節（docs/schema.sql）。さがす対象は節にする
     WHERE u.level = 3
     ORDER BY u.subject, u.ord
     LIMIT ${MAX_COMMANDS}`

  return [
    ...SCREEN_COMMANDS,
    ...units.map(u => ({
      id: `u.${u.id}`,
      label: u.label,
      kind: '単元',
      // ★ 単元そのものの画面は無い。範囲選択へ送って、そこで選んでもらう
      href: `/drills/new?unit=${encodeURIComponent(u.id)}`,
      keywords: `${u.parent_label ?? ''} ${u.id}`,
    })),
  ]
}
