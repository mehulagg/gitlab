import Vue from 'vue';
import Vuex from 'vuex';
import createState from './state';
import actions from './actions';
import getters from './getters';
import mutations from './mutations';

Vue.use(Vuex);

export const createStore = () =>
  new Vuex.Store({
    state: createState(),
    actions,
    getters,
    mutations,
  });
export default createStore();
