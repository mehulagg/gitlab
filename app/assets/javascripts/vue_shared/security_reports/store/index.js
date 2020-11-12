import Vuex from 'vuex';
import * as getters from './getters';
import state from './state';

import sast from './modules/sast';
import secretDetection from './modules/secret_detection';

export default () =>
  new Vuex.Store({
    modules: {
      sast,
      secretDetection,
    },
    getters,
    state,
  });
