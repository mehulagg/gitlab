import Vue from 'vue';
import Vuex from 'vuex';
import * as actions from './actions';
import * as getters from './getters';
import mutations from './mutations';
import state from './state';
import durationChart from './modules/duration_chart/index';
import typeOfWork from './modules/type_of_work/index';

Vue.use(Vuex);

export default () =>
  new Vuex.Store({
    actions,
    getters,
    mutations,
    state,
    modules: { durationChart, typeOfWork },
  });
