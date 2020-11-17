import { SET_FILTER, TOGGLE_HIDE_DISMISSED } from '../modules/filters/mutation_types';

const refreshTypes = [`filters/${SET_FILTER}`, `filters/${TOGGLE_HIDE_DISMISSED}`];

export default store => {
  const refreshVulnerabilities = payload => {
    store.dispatch('vulnerabilities/fetchVulnerabilities', payload);
    store.dispatch('vulnerabilities/fetchVulnerabilitiesHistory', payload);
  };

  store.subscribe(({ type }) => {
    if (refreshTypes.includes(type)) {
      refreshVulnerabilities(store.state.filters.filters);
    }
  });
};
