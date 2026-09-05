import Link from 'next/link'
import { notFound } from 'next/navigation'
import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { materialView } from '@/lib/loop/material'
import { Screen, Alert } from '@/components/ui'
import { NotReady } from '@/components/not-ready'
import { FakeWarning } from '@/components/fake-warning'
import { Reader } from './reader'
import { videosForKcs, MAX_PER_SECTION } from '@/lib/loop/video'

export const dynamic = 'force-dynamic'

export default async function MaterialPage({
  params, searchParams,
}: {
  params: Promise<{ id: string }>
  /** `?s=<ord>` で節を直接開く。「調べる」の結果から飛んでくるため */
  searchParams: Promise<{ s?: string }>
}) {
  const { id } = await params
  const { s } = await searchParams
  const initialOrd = Number.isInteger(Number(s)) && s !== undefined && s !== '' ? Number(s) : null
  const db = tryDb()
  const userId = await currentUserId()

  if (!db || !userId) {
    return (
      <Screen title="教材" tab="drills">
        <NotReady />
      </Screen>
    )
  }

  const m = await materialView(db, userId, id)
  if (!m) notFound()

  // 事実確認を通らなかった教材は本文を出さない（作者判断 Q4 / docs/08 §5 層5）。
  // ただし「なぜ出せないのか」は必ず出す。黙って消すと不具合と区別がつかない。
  if (m.status !== 'ready') {
    return (
      <Screen title={m.unitLabel} tab="drills">
        <Alert title={
          m.status === 'blocked' ? 'この教材は配信していません'
          : m.status === 'generating' ? 'まだ作っています'
          : m.status === 'failed' ? '生成に失敗しました'
          : '新しい版に置き換わりました'
        }>
          {m.blockedReason && (
            <>
              <p className="lv-body">事実確認で次の誤りが見つかりました。</p>
              <p className="lv-caption">{m.blockedReason}</p>
            </>
          )}
          {m.status === 'blocked' && (
            <p className="lv-caption">
              一部だけ伏せるのではなく、単元ごと配信を止めています。
              ホームの「作り直す」でもう一度作れます。
            </p>
          )}
        </Alert>
        <Link className="lv-btn lv-btn--block" href="/">ホームへ</Link>
      </Screen>
    )
  }

  // ★ 動画はサーバー側で引く。Reader はクライアント境界なので DB を触らせない。
  //   伏せたセクションには出さない（本文が無いのに「理解を助ける動画」は成立しない）。
  const videos = await Promise.all(
    m.sections.map(s => (s.hidden || s.kcIds.length === 0)
      ? Promise.resolve([])
      : videosForKcs(db, s.kcIds, MAX_PER_SECTION)),
  )
  const sections = m.sections.map((s, i) => ({
    id: s.id, ord: s.ord, heading: s.heading, bodyMd: s.bodyMd,
    charCount: s.charCount, hidden: s.hidden, hiddenReason: s.hiddenReason,
    kcLabels: s.kcLabels, geoRegionIds: s.geoRegionIds,
    read: s.read, requiredMs: s.requiredMs, estimatedMs: s.estimatedMs,
    videos: videos[i] ?? [],
  }))

  return (
    <Screen title={m.unitLabel} tab="drills">
      {/* ★ 本文より前に出す。読んでから言われても遅い */}
      <FakeWarning provider={m.provider} />
      <Reader
        title={m.title}
        totalChars={m.totalChars}
        sections={sections}
        initialOrd={initialOrd}
      />
    </Screen>
  )
}
