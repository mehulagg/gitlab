import Vue from 'vue';
import Vuex from 'vuex';
import createState from './state';
import * as actions from './actions';
import mutations from './mutations';

Vue.use(Vuex);

export default (initialState) =>
  new Vuex.Store({
    state: createState(initialState),
    actions,
    mutations,
  });
