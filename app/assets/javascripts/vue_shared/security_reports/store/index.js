import Vuex from 'vuex';
import * as actions from './actions';
import * as getters from './getters';
import mutations from './mutations';
import state from './state';

import sast from './modules/sast';
import secretDetection from './modules/secret_detection';

export default () =>
  new Vuex.Store({
    modules: {
      sast,
      secretDetection,
    },
    actions,
    getters,
    mutations,
    state,
  });
