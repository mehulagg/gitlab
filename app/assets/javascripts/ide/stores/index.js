import Vue from 'vue';
import Vuex from 'vuex';
import state from './state';
import actions from './actions';
import getters from './getters';
import mutations from './mutations';
import commitModule from './modules/commit';
import pipelines from './modules/pipelines';
import mergeRequests from './modules/merge_requests';
import branches from './modules/branches';
import fileTemplates from './modules/file_templates';
import paneModule from './modules/pane';

Vue.use(Vuex);

export const createStore = () =>
  new Vuex.Store({
    state: state(),
    actions,
    mutations,
    getters,
    modules: {
      commit: commitModule,
      pipelines,
      mergeRequests,
      branches,
      fileTemplates: fileTemplates(),
      rightPane: paneModule(),
    },
  });

export default createStore();
