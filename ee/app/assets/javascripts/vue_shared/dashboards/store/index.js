import Vue from 'vue';
import Vuex from 'vuex';
import * as actions from './actions';
import mutations from './mutations';
import state from './state';

Vue.use(Vuex);

export const getStoreConfig = () => ({
  state,
  mutations,
  actions,
});

export default () => new Vuex.Store(getStoreConfig());
