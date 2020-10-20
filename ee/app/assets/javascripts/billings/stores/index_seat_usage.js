import Vue from 'vue';
import Vuex from 'vuex';
import seats from './modules/seats/index';

Vue.use(Vuex);

export default () =>
  new Vuex.Store({
    modules: {
      seats,
    },
  });
