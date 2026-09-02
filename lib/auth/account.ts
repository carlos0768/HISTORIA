import type { Sql } from 'postgres'

/**
 * アカウントと学習データの物理削除（docs/10-legal-risk.md §5.4）
 *
 * ★ 論理削除にしない。docs/10 §5.4 は「物理削除できる設計」と定めている。
 *   16歳未満からの利用停止請求に法定期間内で応える必要があるため。
 *
 * ★ 消した件数を返す。「消しました」とだけ出すと、本当に消えたのか確かめようがない。
 *   件数は**消す前**に数える。消した後では 0 しか返らない。
 *
 * ★ Server Action からロジックを分けてある。'use server' のファイルは
 *   next/cache と next/navigation を引き込むので、実 DB の試験から呼べない。
 */
export type DeletedCounts = {
  response: number
  drill: number
  checkTest: number
  material: number
  kcCard: number
  userKcState: number
  materialRead: number
}

export async function deleteUserData(db: Sql, userId: string): Promise<DeletedCounts> {
  const [n] = await db<{
    response: string; drill: string; check_test: string; material: string
    kc_card: string; user_kc_state: string; material_read: string
  }[]>`
    SELECT (SELECT count(*) FROM response       WHERE user_id = ${userId}) AS response,
           (SELECT count(*) FROM drill          WHERE user_id = ${userId}) AS drill,
           (SELECT count(*) FROM check_test     WHERE user_id = ${userId}) AS check_test,
           (SELECT count(*) FROM material       WHERE user_id = ${userId}) AS material,
           (SELECT count(*) FROM kc_card        WHERE user_id = ${userId}) AS kc_card,
           (SELECT count(*) FROM user_kc_state  WHERE user_id = ${userId}) AS user_kc_state,
           (SELECT count(*) FROM material_read  WHERE user_id = ${userId}) AS material_read`

  // app_user への外部キーは全て ON DELETE CASCADE なので、1行消せば波及する
  await db`DELETE FROM app_user WHERE id = ${userId}`

  return {
    response: Number(n!.response), drill: Number(n!.drill),
    checkTest: Number(n!.check_test), material: Number(n!.material),
    kcCard: Number(n!.kc_card), userKcState: Number(n!.user_kc_state),
    materialRead: Number(n!.material_read),
  }
}

export const describeDeleted = (n: DeletedCounts): string => [
  `解答 ${n.response}件`, `特訓 ${n.drill}件`, `確認テスト ${n.checkTest}件`,
  `教材 ${n.material}件`, `復習カード ${n.kcCard}件`,
  `弱点の推定 ${n.userKcState}件`, `読了 ${n.materialRead}件`,
].join(' / ')

/** 打ち間違いで消えないようにする合言葉。押し間違いで戻せないものを消させない */
export const DELETE_CONFIRMATION = '削除します'
