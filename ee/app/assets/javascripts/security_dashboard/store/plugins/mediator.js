import { SET_FILTER, SET_HIDE_DISMISSED } from '../modules/filters/mutation_types';

const refreshTypes = [`filters/${SET_FILTER}`, `filters/${SET_HIDE_DISMISSED}`];

export default (store) => {
  store.subscribe(({ type }) => {
    if (refreshTypes.includes(type)) {
      store.dispatch('vulnerabilities/fetchVulnerabilities', store.state.filters.filters);
    }
  });
};
