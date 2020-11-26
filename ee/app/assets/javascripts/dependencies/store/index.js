import Vue from 'vue';
import Vuex from 'vuex';
import listModule from './modules/list';
import * as actions from './actions';
import * as getters from './getters';
import mutations from './mutations';
import state from './state';
import { DEPENDENCY_LIST_TYPES } from './constants';

Vue.use(Vuex);

export default () =>
  new Vuex.Store({
    modules: {
      [DEPENDENCY_LIST_TYPES.all.namespace]: listModule(),
    },
    actions,
    getters,
    mutations,
    state,
  });
