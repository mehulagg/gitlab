import types from '../mutation_types';

// Actions that exclusively mutate the state (essentially wrappers for `commit`)

export default {
  setActiveTab({ commit }, tab) {
    commit(types.SET_ACTIVE_TAB, tab);
  },
  setEndpoints({ commit }, endpoints) {
    commit(types.SET_ENDPOINTS, endpoints);
  },
};
