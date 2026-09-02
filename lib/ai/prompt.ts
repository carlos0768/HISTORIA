/**
 * プロンプトの読み込みと差し込み
 *
 * 仕様: docs/07-content-pipeline.md §5
 *
 * ★ プロンプト本文をコードに書かない。prompts/*.md で版管理し、
 *   material.prompt_version に版名を記録する。そうしないと
 *   A/Bテスト（§6.2）でプロンプトだけを差し替えられず、
 *   過去に生成した教材がどの文面から出たのか追えなくなる。
 */
import { readFileSync } from 'node:fs'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import type { AnonymizedContext, RenderedPrompt } from './types'
import { assertAnonymized, assertNoIdentifiers } from './redact'

const ROOT = join(dirname(fileURLToPath(import.meta.url)), '..', '..')
export const PROMPTS_DIR = join(ROOT, 'prompts')

export const MATERIAL_PROMPT_VERSION = 'material_v2'

export type PromptTemplate = { system: string; user: string }

const cache = new Map<string, PromptTemplate>()

/** `## SYSTEM` と `## USER` で分割する。HTML コメントの前書きは捨てる */
export function parsePromptFile(text: string): PromptTemplate {
  const body = text.replace(/^<!--[\s\S]*?-->\s*/, '')
  const sys = body.indexOf('## SYSTEM')
  const usr = body.indexOf('## USER')
  if (sys < 0 || usr < 0 || usr < sys) {
    throw new Error('プロンプトファイルに ## SYSTEM と ## USER が必要です')
  }
  return {
    system: body.slice(sys + '## SYSTEM'.length, usr).trim(),
    user: body.slice(usr + '## USER'.length).trim(),
  }
}

export function loadPrompt(version = MATERIAL_PROMPT_VERSION): PromptTemplate {
  const hit = cache.get(version)
  if (hit) return hit
  const t = parsePromptFile(readFileSync(join(PROMPTS_DIR, `${version}.md`), 'utf8'))
  cache.set(version, t)
  return t
}

/** 差し込みに使う、単元まわりの公開情報。個人に紐づく値を入れない */
export type UnitFacts = {
  unitLabel: string
  subject: string
  parentLabels: string[]
  eraLabel: string
  yearFrom: number | null
  yearTo: number | null
  regionLabels: string[]
}

export type CandidateKc = {
  id: string
  kind: string
  label: string
  examWeight: number
}

const SUBJECT_LABEL: Record<string, string> = {
  world_history: '世界史探究',
  general_history: '歴史総合',
}

/**
 * `{{#each candidate_kcs}} ... {{/each}}` を展開する。
 * テンプレート言語は入れない。この1つの繰り返しだけが必要なので、
 * 依存を増やすより素直に書く。
 */
function expandEach(template: string, kcs: CandidateKc[]): string {
  const re = /\{\{#each candidate_kcs\}\}([\s\S]*?)\{\{\/each\}\}/
  const m = template.match(re)
  if (!m) return template
  const inner = m[1]!
  const rows = kcs
    .map(kc =>
      inner
        .replaceAll('{{id}}', kc.id)
        .replaceAll('{{kind}}', kc.kind)
        .replaceAll('{{label}}', kc.label)
        .replaceAll('{{exam_weight}}', String(kc.examWeight)),
    )
    .join('')
    .replace(/^\n/, '')
    .replace(/\n+$/, '')
  return template.replace(re, rows)
}

/**
 * 教材生成プロンプトを組み立てる。
 *
 * ★ 引数に AnonymizedContext しか受けない。個人識別情報を持つ値を
 *   渡せないようにするため（docs/08 §4.2）。組み立てた本文に対しても
 *   UUID が混ざっていないかを実行時に確認する。
 */
export function renderMaterialPrompt(
  ctx: AnonymizedContext,
  facts: UnitFacts,
  version = MATERIAL_PROMPT_VERSION,
): RenderedPrompt {
  assertAnonymized(ctx)

  const t = loadPrompt(version)
  const kcs: CandidateKc[] = ctx.weakKcs.map(k => ({
    id: k.kcId,
    kind: k.kind,
    label: k.label,
    // 帯（low/mid/high）はプロンプト本文では出題重みとして扱う。
    // 生の習得度は送らない（docs/08 §4.1）
    examWeight: k.band === 'low' ? 1.5 : k.band === 'mid' ? 1.0 : 0.5,
  }))

  let user = expandEach(t.user, kcs)
  const subs: Record<string, string> = {
    '{{syllabus_unit.label}}': facts.unitLabel,
    '{{syllabus_unit.subject}}': SUBJECT_LABEL[facts.subject] ?? facts.subject,
    '{{parent_unit_labels}}': facts.parentLabels.join(' > ') || '（なし）',
    '{{era.label}}': facts.eraLabel,
    '{{year_from}}': facts.yearFrom === null ? '不明' : String(facts.yearFrom),
    '{{year_to}}': facts.yearTo === null ? '不明' : String(facts.yearTo),
    '{{region_labels}}': facts.regionLabels.join('・') || '（なし）',
  }
  for (const [k, v] of Object.entries(subs)) user = user.replaceAll(k, v)

  const left = user.match(/\{\{[^}]*\}\}/g)
  if (left) {
    throw new Error(`差し込まれていない変数が残っています: ${[...new Set(left)].join(', ')}`)
  }

  assertNoIdentifiers(user)
  assertNoIdentifiers(t.system)

  return { system: t.system, user, promptVersion: version }
}
