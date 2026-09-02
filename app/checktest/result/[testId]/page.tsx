import Link from 'next/link'
import { tryDb } from '@/lib/db/optional'
import { currentUserId } from '@/lib/auth/dal'
import { RETEST_COOLDOWN_DAYS, type Verdict } from '@/lib/domain/assessment'
import { Screen, Card, Empty, MasteryBar } from '@/components/ui'
import { NotReady } from '@/components/not-ready'
import { ReportButton } from '@/components/report-button'
import { reportItem } from '@/app/study/actions'
import { videosForKcs, MAX_PER_RESULT } from '@/lib/loop/video'
import { VideoEmbed } from '@/components/video-embed'

export const dynamic = 'force-dynamic'

const jstDate = (d: Date) =>
  new Intl.DateTimeFormat('ja-JP', { month: 'numeric', day: 'numeric', timeZone: 'Asia/Tokyo' }).format(d)

const VERDICT_LABEL: Record<Verdict, string> = {
  pass: '合格', almost: 'もう少し', retry: '要復習',
}

type Wrong = {
  item_id: string
  stem: string
  choices: Array<{ key: string; text: string }> | null
  answer_key: unknown
  explanation: string | null
  chosen: unknown
  kc_label: string
  kc_id: string
  material_id: string | null
}

const choiceText = (choices: Wrong['choices'], key: unknown): string => {
  const k = typeof key === 'string' ? key : String(key)
  const c = choices?.find(x => x.key === k)
  return c ? `${k}（${c.text}）` : k
}

/**
 * 確認テストの結果（docs/06-assessment.md §6.2 ／ docs/11 §5）
 *
 * ★ 結果を見せて終わりにしない。「次にやること」を必ず出す。
 * ★ 間違えた問題ごとに「**あなたが選んだもの**」を明示する。
 *   正解だけを出すと、なぜ自分の答えが誤りだったかが分からない。
 */
export default async function Result({ params }: { params: Promise<{ testId: string }> }) {
  const { testId } = await params
  const db = tryDb()
  const userId = await currentUserId()

  if (!db || !userId) {
    return (
      <Screen title="確認テストの結果" tab="drills">
        <NotReady />
      </Screen>
    )
  }

  const [t] = await db<{
    drill_id: string; drill_title: string; raw_score: number | null; total: number
    verdict: Verdict | null; progress_after: number | null
    item_ids: string[]; started_at: Date; finished_at: Date | null
  }[]>`
    SELECT ct.drill_id, d.title AS drill_title, ct.raw_score, ct.total,
           ct.verdict, ct.progress_after, ct.item_ids, ct.started_at, ct.finished_at
      FROM check_test ct JOIN drill d ON d.id = ct.drill_id
     WHERE ct.id = ${testId} AND ct.user_id = ${userId}`

  if (!t || !t.finished_at || !t.verdict) {
    return (
      <Screen title="確認テストの結果" tab="drills">
        <Empty>
          <p className="lv-body">この確認テストはまだ終わっていません。</p>
          <Link className="lv-btn" href="/drills">特訓の一覧へ</Link>
        </Empty>
      </Screen>
    )
  }

  const wrong = await db<Wrong[]>`
    SELECT r.item_id, i.stem, i.choices, i.answer_key, i.explanation, r.chosen,
           kc.label AS kc_label, kc.id AS kc_id,
           (SELECT m.id FROM material m
              JOIN kc_syllabus_unit ksu ON ksu.unit_id = m.unit_id AND ksu.kc_id = kc.id
             WHERE (m.user_id = ${userId} OR m.user_id IS NULL) AND m.status = 'ready'
             ORDER BY m.generated_at DESC LIMIT 1) AS material_id
      FROM response r
      JOIN item i ON i.id = r.item_id
      JOIN item_kc ik ON ik.item_id = i.id
      JOIN kc ON kc.id = ik.kc_id
     WHERE r.user_id = ${userId} AND r.session_kind = 'checktest' AND NOT r.correct
       AND r.item_id = ANY(${t.item_ids})
       -- ★ 期間で挟む。設問は14日後には再出題されうるので、item_id だけで拾うと
       --   前回の確認テストで間違えたものが今回の一覧に紛れ込む
       AND r.answered_at >= ${t.started_at} AND r.answered_at <= ${t.finished_at}
     ORDER BY kc.label`

  // ★ 落とした KC のうち mastery が最も低い3件の動画を出す（docs/09b §7）。
  //   全部の誤答に付けると動画が主役になる。弱いところだけに絞る。
  //   ★ 全問正解なら問い合わせ自体をしない。空配列を IN に渡せないからといって
  //     `['']` のような番兵を入れない（読んだ人が意味を取り違える）。
  const missedKcs = [...new Set(wrong.map(w => w.kc_id))]
  const weakestKcs = missedKcs.length === 0 ? [] : (await db<{ kc_id: string }[]>`
    SELECT s.kc_id FROM user_kc_state s
     WHERE s.user_id = ${userId} AND s.kc_id IN ${db(missedKcs)}
     ORDER BY s.p_know ASC
     LIMIT 3`).map(r => r.kc_id)
  const resultVideos = await videosForKcs(db, weakestKcs, MAX_PER_RESULT)

  const retestAt = new Date(t.finished_at.getTime() + RETEST_COOLDOWN_DAYS * 86_400_000)
  const score = t.raw_score ?? 0
  const progress = t.progress_after ?? 0

  return (
    <Screen title="確認テストの結果" tab="drills">
      <p className="lv-caption">{t.drill_title}</p>

      <Card>
        <div className="hs-titlerow">
          <span className="lv-title">{score} / {t.total} 問正解</span>
          <span className="lv-label">判定: {VERDICT_LABEL[t.verdict]}</span>
        </div>
        <span className="lv-label">この範囲の進捗</span>
        <MasteryBar value={progress} />
        {/* ★ 素点と判定が食い違うことがある。四択は25%で当たるので、
             なぜ違うのかを黙っていると「採点がおかしい」と受け取られる */}
        <p className="lv-caption">
          判定は素点ではなく、出題した項目が身についたかどうかで出しています。
          四択はまぐれ当たりがあるため、正答率と判定はずれることがあります。
        </p>
      </Card>

      {wrong.length > 0 && (
        <>
          <span className="lv-label">間違えた問題（{wrong.length}問）</span>
          {wrong.map(w => (
            <Card key={w.item_id}>
              <p className="lv-caption">{w.kc_label}</p>
              <p className="lv-body">{w.stem}</p>
              <div className="lv-meta__row">
                <span className="lv-meta__key">あなたの解答</span>
                <span>{choiceText(w.choices, w.chosen)}</span>
              </div>
              <div className="lv-meta__row">
                <span className="lv-meta__key">正解</span>
                <span>{choiceText(w.choices, w.answer_key)}</span>
              </div>
              {w.explanation && <p className="lv-body">{w.explanation}</p>}
              {w.material_id && (
                <Link className="lv-btn" href={`/material/${w.material_id}`}>
                  この項目の教材を読み直す
                </Link>
              )}
              {/* ★ 誤答の解説はいちばん疑いが向く場所である。ここに導線が無いと
                   「解説が間違っている」という気づきを受け取れない（docs/08 §5 層4） */}
              <ReportButton targetKind="item" targetId={w.item_id} action={reportItem} />
            </Card>
          ))}
        </>
      )}

      {/* ★ 動画は「間違えたところを解説している動画」として出す（docs/09b §7）。
           0件なら見出しごと出さない */}
      {resultVideos.length > 0 && (
        <>
          <span className="lv-label">間違えたところの解説動画</span>
          {resultVideos.map(v => (
            <VideoEmbed
              key={v.id}
              videoId={v.id}
              title={v.title}
              channelTitle={v.channelTitle}
              startSec={v.startSec}
              label={`「${v.forKcLabel}」を解説している動画`}
            />
          ))}
        </>
      )}

      {/* ★ 「次にやること」は必ず出す（docs/11 §5）。結果を見せて終わりにしない */}
      <Card>
        <span className="lv-label">次にやること</span>
        {wrong.length > 0 ? (
          <p className="lv-body">
            この {wrong.length} 項目は、明日の学習の先頭に入りました。
            間違えた項目は翌日に出し直されます。
          </p>
        ) : (
          <p className="lv-body">全問正解でした。この範囲は次の復習まで間隔が空きます。</p>
        )}
        <p className="lv-caption">
          再テストは {jstDate(retestAt)} から受けられます
          （連続で受けると「さっきの問題を覚えているか」の測定になってしまうため）。
        </p>
        <Link className="lv-btn lv-btn--primary lv-btn--block" href="/study">今日の学習に進む</Link>
        <Link className="lv-btn lv-btn--block" href="/drills">特訓の一覧へ</Link>
      </Card>
    </Screen>
  )
}
