import Vue from 'vue';
import Vuex from 'vuex';

import * as actions from './actions';
import * as getters from './getters';
import mutations from './mutations';
import createState from './state';

Vue.use(Vuex);

export default (initialState = {}) =>
  new Vuex.Store({
    state: createState(initialState),
    actions,
    getters,
    mutations,
  });
