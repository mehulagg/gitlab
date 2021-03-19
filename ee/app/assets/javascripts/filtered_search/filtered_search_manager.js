import FilteredSearchManager from '~/filtered_search/filtered_search_manager';
import { epicTokenKey } from './issuable_filtered_search_token_keys';

export default class extends FilteredSearchManager {
  getSearchTokens() {
    const { tokens, ...rest } = super.getSearchTokens();

    const hasEqualsToEpicIdToken = tokens.some(
      (token) =>
        token?.key === epicTokenKey.key &&
        token?.operator === '=' &&
        !Number.isNaN(Number(token?.value)),
    );

    if (hasEqualsToEpicIdToken) {
      tokens.push({
        key: 'include_subepics',
        operator: '=',
        value: '✓',
        symbol: '',
      });
    }

    return { tokens, ...rest };
  }
}
