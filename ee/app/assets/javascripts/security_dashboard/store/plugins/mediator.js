import * as filtersMutationTypes from '../modules/filters/mutation_types';
import * as vulnerabilitiesMutationTypes from '../modules/vulnerabilities/mutation_types';

export default store => {
  const refreshVulnerabilities = payload => {
    store.dispatch('vulnerabilities/fetchVulnerabilities', payload);
    store.dispatch('vulnerabilities/fetchVulnerabilitiesHistory', payload);
  };

  store.subscribe(({ type, payload = {} }) => {
    switch (type) {
      // SET_ALL_FILTERS mutations are triggered by navigation events, in such case we
      // want to preserve the page number that was set in the sync_with_router plugin
      case `filters/${filtersMutationTypes.SET_ALL_FILTERS}`:
        refreshVulnerabilities({
          ...store.getters['filters/activeFilters'],
          page: store.state.vulnerabilities.pageInfo.page,
        });
        break;
      // These mutations happen when users interact with the UI,
      // in that case we want to reset the page number
      case `vulnerabilities/${vulnerabilitiesMutationTypes.RECEIVE_DISMISS_SELECTED_VULNERABILITIES_SUCCESS}`:
      case `filters/${filtersMutationTypes.SET_FILTER}`:
      case `filters/${filtersMutationTypes.SET_TOGGLE_VALUE}`: {
        if (!payload.lazy) {
          refreshVulnerabilities(store.getters['filters/activeFilters']);
        }
        break;
      }
      default:
    }
  });
};
