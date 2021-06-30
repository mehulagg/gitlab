import { GROUPS_LOCAL_STORAGE_KEY, PROJECTS_LOCAL_STORAGE_KEY } from './constants';
import * as types from './mutation_types';

export default {
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
  [types.REQUEST_FREQUENT_GROUPS](state) {
    state.fetchingFrequentGroups = true;
  },
  [types.RECEIVE_FREQUENT_GROUPS_SUCCESS](state, data) {
    state.fetchingFrequentGroups = false;
    state.frequentItems[GROUPS_LOCAL_STORAGE_KEY] = data;
  },
  [types.RECEIVE_FREQUENT_GROUPS_ERROR](state) {
    state.fetchingFrequentGroups = false;
    state.frequentItems[GROUPS_LOCAL_STORAGE_KEY] = [];
  },
  [types.REQUEST_PROJECTS](state) {
    state.fetchingProjects = true;
  },
  [types.RECEIVE_PROJECTS_SUCCESS](state, data) {
    state.fetchingProjects = false;
    state.projects = data;
  },
  [types.RECEIVE_PROJECTS_ERROR](state) {
    state.fetchingProjects = false;
    state.projects = [];
  },
  [types.REQUEST_FREQUENT_PROJECTS](state) {
    state.fetchingFrequentProjects = true;
  },
  [types.RECEIVE_FREQUENT_PROJECTS_SUCCESS](state, data) {
    state.fetchingFrequentProjects = false;
    state.frequentItems[PROJECTS_LOCAL_STORAGE_KEY] = data;
  },
  [types.RECEIVE_FREQUENT_PROJECTS_ERROR](state) {
    state.fetchingFrequentProjects = false;
    state.frequentItems[PROJECTS_LOCAL_STORAGE_KEY] = [];
  },
  [types.SET_QUERY](state, { key, value }) {
    state.query[key] = value;
  },
};
