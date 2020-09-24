import Vue from 'vue';
import Vuex from 'vuex';
import createState from './state';
import * as actions from './actions';
import * as getters from './getters';
import mutations from './mutations';

Vue.use(Vuex);

export const licenseManagementModule = () => ({
  namespaced: true,
  state: createState(),
  actions,
  getters,
  mutations,
});

export default () =>
  new Vuex.Store({
    modules: {
      licenseManagement: licenseManagementModule(),
    },
  });
