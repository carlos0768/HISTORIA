import Link from 'next/link'
import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { Screen, Card, DataTable, type Column } from '@/components/ui'
import { NotReady } from '@/components/not-ready'
import { MATERIAL_STATUSES, materialLibrary, type LibraryRow } from '@/lib/loop/library'

export const dynamic = 'force-dynamic'

/**
 * 教材の一覧（docs/06-desktop.md 画面A）
 *
 * ★ モバイルには無い画面である。教材はふつう「特訓 → 単元 → 本文」とたどるが、
 *   机の前では「これまでに作った全部」を一度に見て、読み返す先を選びたい。
 *   広い画面でしか成立しない見せ方なので、ここに置く。
 *
 * ★ 状態を隠さない。生成中も配信不可も同じ表に出す。
 *   「無い」ように見せると、待てばいいのか壊れているのかが分からない。
 *
 * ★ 絞り込みは **URL でやる**（`?q=` と `?status=`）。
 *   クライアント側で絞ると全件を端末へ送ることになるし、
 *   JavaScript が動かない状態では何もできなくなる。
 *   URL なら結果をそのまま人に渡せるし、戻るボタンも効く。
 */
const STATUS_LABEL: Record<string, string> = {
  ready: '読める', generating: '生成中', blocked: '配信不可',
  superseded: '古い版', failed: '失敗',
}

export default async function Library({
  searchParams,
}: {
  searchParams: Promise<{ q?: string; status?: string }>
}) {
  const db = tryDb()
  const userId = await currentUserId()
  const { q = '', status = '' } = await searchParams

  if (!db || !userId) {
    return <Screen title="教材の一覧" tab="library"><NotReady /></Screen>
  }

  const rows = await materialLibrary(db, userId, { query: q, status })

  const columns: Column<LibraryRow>[] = [
    {
      key: 'title', label: '教材', width: 'minmax(200px, 2fr)',
      render: r => r.status === 'ready'
        ? <Link href={`/material/${r.id}`}>{r.title}</Link>
        : <span>{r.title}</span>,
    },
    { key: 'chapter', label: '章', width: 'minmax(120px, 1.2fr)', render: r => r.chapterLabel ?? '—' },
    { key: 'unit', label: '節', width: 'minmax(120px, 1.2fr)', render: r => r.unitLabel },
    { key: 'status', label: '状態', width: '110px', render: r => STATUS_LABEL[r.status] ?? r.status },
    {
      key: 'read', label: '読了', width: '90px', numeric: true,
      render: r => `${r.readSections}/${r.sections}`,
    },
    {
      key: 'chars', label: '字数', width: '90px', numeric: true,
      render: r => r.chars.toLocaleString('ja-JP'),
    },
    {
      key: 'at', label: '作成', width: '110px', numeric: true,
      render: r => r.generatedAt.toLocaleDateString('ja-JP', { timeZone: 'Asia/Tokyo' }),
    },
  ]

  return (
    <Screen title="教材の一覧" tab="library">
      <Card>
        <span className="lv-label">さがす</span>
        {/* ★ GET のフォームにする。結果の URL がそのまま共有できる */}
        <form className="hs-report__row" method="get">
          <input className="lv-input" type="search" name="q" defaultValue={q}
                 placeholder="教材名・章・節" aria-label="教材をさがす" />
          <select className="lv-input" name="status" defaultValue={status} aria-label="状態で絞る">
            <option value="">すべての状態</option>
            {MATERIAL_STATUSES.map(s => (
              <option key={s} value={s}>{STATUS_LABEL[s] ?? s}</option>
            ))}
          </select>
          <button type="submit" className="lv-btn">絞る</button>
        </form>
        <p className="lv-caption">
          {rows.length} 件
          {(q || status) && <> — <Link href="/library">絞り込みを外す</Link></>}
        </p>
      </Card>

      <DataTable columns={columns} rows={rows} rowKey={r => r.id}
                 caption="教材の一覧"
                 empty={q || status
                   ? '条件に合う教材がありません。'
                   : 'まだ教材がありません。範囲と締切を決めると作られます。'} />
    </Screen>
  )
}
