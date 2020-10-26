import Vue from 'vue';
import Vuex from 'vuex';
import pipelineJobs from 'ee/security_dashboard/store/modules/pipeline_jobs';
import configureMediator from './mediator';
import * as actions from './actions';
import * as getters from './getters';
import mutations from './mutations';
import state from './state';

import sast from './modules/sast';

Vue.use(Vuex);

export default () =>
  new Vuex.Store({
    modules: {
      sast,
      pipelineJobs,
    },
    actions,
    getters,
    mutations,
    state: state(),
    plugins: [configureMediator],
  });
