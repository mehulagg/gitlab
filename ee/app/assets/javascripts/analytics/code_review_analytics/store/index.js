import Vue from 'vue';
import Vuex from 'vuex';
import filters from 'ee/analytics/shared/store/modules/filters';
import * as actions from './actions';
import mergeRequests from './modules/merge_requests/index';

Vue.use(Vuex);

const createStore = () =>
  new Vuex.Store({
    actions,
    modules: {
      filters,
      mergeRequests,
    },
  });

export default createStore();
