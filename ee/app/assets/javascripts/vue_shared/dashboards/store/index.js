import Vue from 'vue';
import Vuex from 'vuex';
import state from './state';
import mutations from './mutations';
import * as actions from './actions';

Vue.use(Vuex);

export const getStoreConfig = () => ({
  state,
  mutations,
  actions,
});

export default () => new Vuex.Store(getStoreConfig());
