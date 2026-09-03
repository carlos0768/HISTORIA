/**
 * 動画の配信と視聴の記録
 *
 * 仕様: docs/09b-video.md
 *
 * ★ **実行時に YouTube の API を呼ばない**（V1）。video テーブルから返すだけである。
 *   だから鍵が無くても配信は完全に動く。鍵が要るのは取り込み
 *   （scripts/db/ingest-video.ts）と週次の生存確認だけ。
 *
 * ★ 出すのは status = 'approved' のものだけ（V4）。承認は作者が行う。
 *
 * ★ 1画面の中では動画IDで重複を排除し、最も relevance の高い KC の start_sec を使う（§8）。
 *   同じ動画が複数の KC から推薦されるのは正常である（1本が複数の論点を扱う）。
 */
import type { Sql } from 'postgres'

/** 教材セクションの末尾に出す本数（docs/09b §7） */
export const MAX_PER_SECTION = 2
/** 確認テストの結果に出す本数（docs/09b §7） */
export const MAX_PER_RESULT = 3
/** 視聴を「見た」と数える割合（docs/09b §6.1） */
export const WATCHED_RATIO = 0.6
/** 視聴後の retrieval の問数（docs/09b V6） */
export const RETRIEVAL_ITEMS = 2

export type VideoCard = {
  id: string
  title: string
  channelTitle: string
  durationSec: number
  /** 頭出しの位置。video_kc.start_sec */
  startSec: number
  /** どの KC のために出しているか。ラベルを添えて「目的が明示された」導線にする（§7） */
  forKcLabel: string
}

/**
 * KC の集合に紐づく動画を、関連の強い順に返す。
 *
 * ★ ラベルなしのサムネイル羅列にしない（§7）。どの KC のために出しているかを持ち帰る。
 */
export async function videosForKcs(
  db: Sql, kcIds: readonly string[], limit: number,
): Promise<VideoCard[]> {
  if (kcIds.length === 0 || limit <= 0) return []
  // ★ DISTINCT ON は並べ替えの先頭が重複排除の列と一致していなければならないので、
  //   まず v.id で1本に絞り、**外側で関連の強い順に並べ直す**。
  //   これを内側だけで書くと、返る順が v.id 順（＝実質ランダム）になる。実際に一度そうなった。
  const rows = await db<{
    id: string; title: string; channel_title: string
    duration_sec: number; start_sec: number; kc_label: string
  }[]>`
    SELECT t.id, t.title, t.channel_title, t.duration_sec, t.start_sec, t.kc_label
      FROM (
        SELECT DISTINCT ON (v.id)
               v.id, v.title, c.channel_title, v.duration_sec,
               vk.start_sec, vk.relevance, k.label AS kc_label
          FROM video_kc vk
          JOIN video v ON v.id = vk.video_id
          JOIN channel_allowlist c ON c.channel_id = v.channel_id
          JOIN kc k ON k.id = vk.kc_id
         WHERE vk.kc_id IN ${db(kcIds as string[])}
           AND v.status = 'approved'
         ORDER BY v.id, vk.relevance DESC, vk.start_sec
      ) t
     ORDER BY t.relevance DESC, t.id
     LIMIT ${limit}`
  return rows.map(r => ({
    id: r.id, title: r.title, channelTitle: r.channel_title,
    durationSec: r.duration_sec, startSec: r.start_sec, forKcLabel: r.kc_label,
  }))
}

/**
 * 視聴を記録する。
 *
 * ★ 弱い学習項にとどめる（§6.1）。`watched_sec >= 0.6 * duration_sec` のとき
 *   p_know を少しだけ上げるが、**n_eff は増やさない**。
 *   動画は受動的消費なので、これを「できるようになった」証拠に数えない。
 * ★ user_kc_state の行が無い KC は作らない。**視聴だけで状態を作ると、
 *   一度も解いていない KC が「学習済み」の顔をして記録に並ぶ。**
 */
export async function recordView(
  db: Sql,
  a: { userId: string; videoId: string; watchedSec: number; now: Date },
): Promise<{ counted: boolean; kcIds: string[] }> {
  return db.begin(async tx => {
    const [v] = await tx<{ duration_sec: number }[]>`
      SELECT duration_sec FROM video WHERE id = ${a.videoId} AND status = 'approved'`
    if (!v) throw new Error('動画が見つかりません')

    const watched = Math.max(0, Math.min(Math.round(a.watchedSec), v.duration_sec))
    await tx`
      INSERT INTO video_view (user_id, video_id, watched_sec, duration_sec, viewed_at)
      VALUES (${a.userId}, ${a.videoId}, ${watched}, ${v.duration_sec}, ${a.now})`

    if (watched < WATCHED_RATIO * v.duration_sec) return { counted: false, kcIds: [] }

    // ★ 既に状態がある KC だけを少し押し上げる。n_eff と kc_card は触らない
    const bumped = await tx<{ kc_id: string }[]>`
      UPDATE user_kc_state s
         SET p_know = s.p_know + (1 - s.p_know) * 0.05, updated_at = ${a.now}
        FROM video_kc vk
       WHERE vk.video_id = ${a.videoId} AND s.kc_id = vk.kc_id AND s.user_id = ${a.userId}
       RETURNING s.kc_id`
    return { counted: true, kcIds: bumped.map(r => r.kc_id) }
  })
}

export type RetrievalItem = { id: string; stem: string; choices: { key: string; text: string }[] }

/**
 * 視聴後に挟む四択（V6）。
 *
 * ★ 該当 KC の approved な item が足りなければ**出さない**（§6.2）。
 *   数合わせに関係ない設問を混ぜると、retrieval の意味が消える。
 * ★ 正答も解説もここでは選ばない。採点は submitAnswer が行う（docs/12 §6.1）。
 */
export async function retrievalAfterVideo(
  db: Sql, userId: string, videoId: string, limit = RETRIEVAL_ITEMS,
): Promise<RetrievalItem[]> {
  const rows = await db<{ id: string; stem: string; choices: { key: string; text: string }[] }[]>`
    SELECT DISTINCT ON (ik.kc_id) i.id, i.stem,
           (SELECT jsonb_agg(jsonb_build_object('key', c->>'key', 'text', c->>'text')
                             ORDER BY c->>'key')
              FROM jsonb_array_elements(i.choices) c) AS choices
      FROM video_kc vk
      JOIN item_kc ik ON ik.kc_id = vk.kc_id
      JOIN item i ON i.id = ik.item_id
     WHERE vk.video_id = ${videoId}
       AND i.approved AND NOT i.hidden
       AND (i.user_id = ${userId} OR i.user_id IS NULL)
       AND i.choices IS NOT NULL
     ORDER BY ik.kc_id, i.observed_total ASC, i.created_at DESC`
  const usable = rows.filter(r => r.choices && r.choices.length > 0).slice(0, limit)
  return usable.length < limit ? [] : usable
}
