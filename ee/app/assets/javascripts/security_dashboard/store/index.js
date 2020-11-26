import Vue from 'vue';
import Vuex from 'vuex';
import { DASHBOARD_TYPES } from './constants';

import filters from './modules/filters/index';
import pipelineJobs from './modules/pipeline_jobs/index';
import unscannedProjects from './modules/unscanned_projects/index';
import vulnerabilities from './modules/vulnerabilities/index';
import vulnerableProjects from './modules/vulnerable_projects/index';
import mediator from './plugins/mediator';

Vue.use(Vuex);

export default ({ dashboardType = DASHBOARD_TYPES.PROJECT, plugins = [] } = {}) =>
  new Vuex.Store({
    state: () => ({
      dashboardType,
    }),
    modules: {
      vulnerableProjects,
      filters,
      vulnerabilities,
      unscannedProjects,
      pipelineJobs,
    },
    plugins: [mediator, ...plugins],
  });
