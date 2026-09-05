/**
 * 手で書いた教材を、生成プロバイダの顔をして流し込む
 *
 * ★ **`generateMaterial` を書き換えない**ための道具である。
 *   教材が通る経路（層2の正典照合 → 層3の別系統モデルによる二次照合 →
 *   blocked/ready の判定 → 設問の投入 → generation_job と ai_spend への記録）は
 *   パイプラインの中で最も壊してはいけない部分で、49件の試験が守っている。
 *   そこへ「もう1つの入口」を作れば、規則が二重になり片方だけ緩い抜け道ができる。
 *   `lib/ai/fake.ts` と同じく **Provider の契約を満たすだけ**にして、
 *   generateMaterial からは API 生成と見分けがつかないようにする。
 *
 * ★ **検証は肩代わりしない。** `verify` も `embed` も本物へ委譲する。
 *   docs/08 §5 の5層は「生成と検証を別系統に分ける」ことで成り立っており、
 *   書いた側が確かめたらそれは自己検証で、層3が消える。
 *   実際、鍵が無ければ検証側が `fake:` に落ち、generate.ts の安全弁
 *   （本物で作って偽物で検証した教材を配信しない）がここを止める。
 *   **手書き教材でも、Gemini の鍵が無ければ配信されない。** これは正しい。
 *
 * ★ 名前に書いた人を残す。`material.provider` に入るのはこの名前で、
 *   docs/10 §8 が求める「どのモデルに、どのプロンプトで、いつ」の「誰が」に当たる。
 */
import { readFileSync } from 'node:fs'
import { join } from 'node:path'
import type { Provider, GenerateResult, VerifyResult, Usage } from './types'
import { parseMaterialOutput } from './schema'

/** `seed/material/<unitId>.json` に置く */
export const AUTHORED_DIR = join(process.cwd(), 'seed', 'material')

export class AuthoredMaterialError extends Error {}

export type AuthoredOptions = {
  /** どの単元の教材を読むか。1プロバイダ1単元 */
  unitId: string
  dir?: string
  /** material.model に記録する。書いたモデルの名前 */
  model?: string
}

/**
 * @returns 手書きの教材を返す生成プロバイダ
 *
 * ★ プロンプトは読まない。**それでよい。** このプロバイダにとってプロンプトは
 *   「何を書くべきだったか」の記録でしかなく、書いたものは既にファイルにある。
 *   ただし generateMaterial は文字数が範囲外だと作り直しを試みるので、
 *   同じ内容を返し続けて所定の回数で諦める（＝文字数違反はここで落ちる）。
 */
export function createAuthoredProvider(opts: AuthoredOptions): Provider {
  const dir = opts.dir ?? AUTHORED_DIR
  const model = opts.model ?? 'claude-code'
  const path = join(dir, `${opts.unitId}.json`)

  return {
    name: 'authored',

    async generate<T>(): Promise<GenerateResult<T>> {
      let raw: unknown
      try {
        raw = JSON.parse(readFileSync(path, 'utf8'))
      } catch (e) {
        throw new AuthoredMaterialError(
          `${path} を読めません: ${e instanceof Error ? e.message : String(e)}`,
        )
      }
      // ★ 実プロバイダと同じ検査を通す。件数の切り詰めも同じ関数で行う
      const parsed = parseMaterialOutput(raw)
      if (!parsed.success) {
        throw new AuthoredMaterialError(`${path} がスキーマに反しています: ${parsed.error.message}`)
      }
      return {
        value: parsed.data as unknown as T,
        // ★ 0 を返す。API を呼んでいないので入出力トークンは存在しない。
        //   ここに嘘の数を入れると ai_spend の元帳が実費と食い違う
        usage: { inputTokens: 0, outputTokens: 0 } satisfies Usage,
        model,
      }
    },

    /**
     * ★ 呼ばれない。`Client.verify` は**検証側**のプロバイダ（`ver`）を呼ぶ作りで、
     *   生成側の verify は経路上どこからも参照されない（`lib/ai/client.ts`）。
     *   委譲を書くより、呼ばれたら落ちるほうがよい。**もし呼ばれたなら、
     *   それは生成側が検証を担ったということ**で、層3が消えている合図である。
     */
    async verify(): Promise<VerifyResult> {
      throw new AuthoredMaterialError(
        '手書き教材のプロバイダに検証を求めています。生成と検証を分けられていません（docs/08 §5）。',
      )
    },

    /** ★ 同じく呼ばれない。埋め込みは Gemini 側へ回る（client.ts の emb） */
    async embed(): Promise<{ vectors: number[][]; usage: Usage; model: string }> {
      throw new AuthoredMaterialError('手書き教材のプロバイダは埋め込みを作れません。')
    },
  }
}
