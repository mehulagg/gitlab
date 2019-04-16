import Vue from 'vue';
import Vuex from 'vuex';
import actions from './actions';
import getters from './getters';
import mutations from './mutations';
import createState from './state';

Vue.use(Vuex);

export default new Vuex.Store({
  state: createState(),
  actions,
  getters,
  mutations,
});
