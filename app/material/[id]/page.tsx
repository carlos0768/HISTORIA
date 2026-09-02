import Link from 'next/link'
import { notFound } from 'next/navigation'
import { tryDb, demoUserId } from '@/lib/db/optional'
import { materialView } from '@/lib/loop/material'
import { Screen, Empty, Alert } from '@/components/ui'
import { Reader } from './reader'

export const dynamic = 'force-dynamic'

export default async function MaterialPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params
  const db = tryDb()
  const userId = demoUserId()

  if (!db || !userId) {
    return (
      <Screen title="教材">
        <Empty><p className="lv-body">データベースに接続していません。</p></Empty>
      </Screen>
    )
  }

  const m = await materialView(db, userId, id)
  if (!m) notFound()

  // 事実確認を通らなかった教材は本文を出さない（作者判断 Q4 / docs/08 §5 層5）。
  // ただし「なぜ出せないのか」は必ず出す。黙って消すと不具合と区別がつかない。
  if (m.status !== 'ready') {
    return (
      <Screen title={m.unitLabel}>
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

  return (
    <Screen title={m.unitLabel}>
      <Reader
        title={m.title}
        totalChars={m.totalChars}
        sections={m.sections.map(s => ({
          id: s.id, ord: s.ord, heading: s.heading, bodyMd: s.bodyMd,
          charCount: s.charCount, hidden: s.hidden, hiddenReason: s.hiddenReason,
          kcLabels: s.kcLabels, geoRegionIds: s.geoRegionIds,
          read: s.read, requiredMs: s.requiredMs, estimatedMs: s.estimatedMs,
        }))}
      />
    </Screen>
  )
}
