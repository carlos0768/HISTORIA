import { Screen, type TabKey } from './ui'

/** 動的ページの先読み境界。遷移直後に枠と固定ナビを返して無反応に見せない。 */
export function RouteLoading({ title, tab }: { title: string; tab?: TabKey }) {
  return (
    <Screen title={title} tab={tab}>
      <div className="hs-route-loading" role="status" aria-live="polite">
        <span className="lv-label">読み込んでいます…</span>
        <span className="hs-route-loading__line" />
        <span className="hs-route-loading__line hs-route-loading__line--short" />
      </div>
    </Screen>
  )
}
