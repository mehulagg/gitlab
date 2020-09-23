import Vue from 'vue';
import Vuex from 'vuex';
import filters from 'ee/analytics/shared/store/modules/filters';
import * as actions from './actions';

Vue.use(Vuex);

export default () =>
  new Vuex.Store({
    actions,
    modules: { filters },
  });
