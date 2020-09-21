import Vue from 'vue';
import Vuex from 'vuex';
import createState from './state';
import * as actions from './actions';
import mutations from './mutations';
import * as getters from './getters';

Vue.use(Vuex);

export const createStore = initialState =>
  new Vuex.Store({
    modules: {
      installRunnerPopup: {
        namespaced: true,
        state: createState(initialState),
        actions,
        mutations,
        getters,
      },
    },
  });
