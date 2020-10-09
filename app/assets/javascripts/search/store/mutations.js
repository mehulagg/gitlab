import * as types from './mutation_types';

export default {
  [types.REQUEST_INITIAL_GROUP](state) {
    state.fetchingInitialGroup = true;
  },
  [types.RECEIVE_INITIAL_GROUP_SUCCESS](state, data) {
    state.fetchingInitialGroup = false;
    state.initialGroup = data;
  },
  [types.RECEIVE_INITIAL_GROUP_ERROR](state) {
    state.fetchingInitialGroup = false;
    state.initialGroup = null;
  },
  [types.REQUEST_GROUPS](state) {
    state.fetchingGroups = true;
  },
  [types.RECEIVE_GROUPS_SUCCESS](state, data) {
    state.fetchingGroups = false;
    state.groups = data;
  },
  [types.RECEIVE_GROUPS_ERROR](state) {
    state.fetchingGroups = false;
    state.groups = [];
  },
};
