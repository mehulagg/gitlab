import Vue from 'vue';
import Vuex from 'vuex';
import pipelineJobs from 'ee/security_dashboard/store/modules/pipeline_jobs';
import * as actions from './actions';
import * as getters from './getters';
import configureMediator from './mediator';

import sast from './modules/sast';
import secretDetection from './modules/secret_detection';
import mutations from './mutations';
import state from './state';

Vue.use(Vuex);

export default () =>
  new Vuex.Store({
    modules: {
      sast,
      secretDetection,
      pipelineJobs,
    },
    actions,
    getters,
    mutations,
    state: state(),
    plugins: [configureMediator],
  });
