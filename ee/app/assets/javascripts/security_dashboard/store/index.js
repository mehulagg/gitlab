import Vue from 'vue';
import Vuex from 'vuex';
import { DASHBOARD_TYPES } from './constants';

import mediator from './plugins/mediator';

import filters from './modules/filters/index';
import vulnerabilities from './modules/vulnerabilities/index';
import vulnerableProjects from './modules/vulnerable_projects/index';
import unscannedProjects from './modules/unscanned_projects/index';
import pipelineJobs from './modules/pipeline_jobs/index';

Vue.use(Vuex);

export const getStoreConfig = (dashboardType = DASHBOARD_TYPES.PROJECT) => ({
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
});

export default ({ dashboardType = DASHBOARD_TYPES.PROJECT, plugins = [] } = {}) =>
  new Vuex.Store({
    ...getStoreConfig(dashboardType),
    plugins: [mediator, ...plugins],
  });
