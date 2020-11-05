import Vue from 'vue';
import Vuex from 'vuex';
import subscription from './modules/subscription/index';
import seats from './modules/seats/index';

Vue.use(Vuex);

export default () =>
  new Vuex.Store({
    modules: {
      subscription,
      seats,
    },
  });
