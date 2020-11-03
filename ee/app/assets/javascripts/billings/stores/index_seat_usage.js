import Vuex from 'vuex';
import seats from './modules/seats/index';

export default () =>
  new Vuex.Store({
    modules: {
      seats,
    },
  });
