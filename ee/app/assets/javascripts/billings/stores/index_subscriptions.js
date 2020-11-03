import Vuex from 'vuex';
import subscription from './modules/subscriptions/index';
import seats from './modules/seats/index';

export default () =>
  new Vuex.Store({
    modules: {
      subscription,
      seats,
    },
  });
