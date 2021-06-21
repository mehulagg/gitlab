import FilteredSearchManager from 'ee_else_ce/filtered_search/filtered_search_manager';
// eslint-disable-next-line import/no-deprecated
import { urlParamsToObject } from '~/lib/utils/url_utility';
import { __ } from '~/locale';
import ProductivityAnalyticsFilteredSearchTokenKeys from './productivity_analytics_filtered_search_token_keys';
import store from './store';

export default class FilteredSearchProductivityAnalytics extends FilteredSearchManager {
  constructor({ isGroup = true }) {
    super({
      page: 'productivity_analytics',
      isGroupDecendent: true,
      stateFiltersSelector: '.issues-state-filters',
      isGroup,
      useDefaultState: false,
      filteredSearchTokenKeys: ProductivityAnalyticsFilteredSearchTokenKeys,
      placeholder: __('Filter results...'),
    });

    this.isHandledAsync = true;
  }

  /**
   * Updates filters in productivity analytics store
   */
  updateObject = (path) => {
    // eslint-disable-next-line import/no-deprecated
    const filters = urlParamsToObject(path);
    store.dispatch('filters/setFilters', filters);
  };
}
