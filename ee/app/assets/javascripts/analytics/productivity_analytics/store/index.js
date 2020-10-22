import Vue from 'vue';
import Vuex from 'vuex';
import state from './state';
import * as getters from './getters';
import * as actions from './actions';
import mutations from './mutations';
import filters from './modules/filters/index';
import charts from './modules/charts/index';
import table from './modules/table/index';

Vue.use(Vuex);

export const getStoreConfig = () => ({
  state: state(),
  getters,
  actions,
  mutations,
  modules: {
    filters,
    charts,
    table,
  },
});

export default new Vuex.Store(getStoreConfig());
