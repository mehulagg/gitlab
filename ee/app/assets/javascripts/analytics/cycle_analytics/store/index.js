import Vue from 'vue';
import Vuex from 'vuex';
import filters from '~/vue_shared/components/filtered_search_bar/store/modules/filters';
import * as actions from './actions';
import * as getters from './getters';
import mutations from './mutations';
import state from './state';
import customStages from './modules/custom_stages/index';
import durationChart from './modules/duration_chart/index';
import typeOfWork from './modules/type_of_work/index';

Vue.use(Vuex);

export default () =>
  new Vuex.Store({
    actions,
    getters,
    mutations,
    state,
    modules: { customStages, durationChart, typeOfWork, filters },
  });
