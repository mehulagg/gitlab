import * as types from './mutation_types';

export default {
  [types.SET_PIPELINE_JOBS_PATH](state, payload) {
    state.pipelineJobsPath = payload;
  },
  [types.SET_PROJECT_ID](state, payload) {
    state.projectId = payload;
  },
  [types.SET_PIPELINE_ID](state, payload) {
    state.pipelineId = payload;
  },
  [types.REQUEST_PIPELINE_JOBS](state) {
    state.isLoading = true;
  },
  [types.RECEIVE_PIPELINE_JOBS_SUCCESS](state, payload) {
    state.isLoading = false;
    state.pipelineJobs = payload;
  },
  [types.RECEIVE_PIPELINE_JOBS_ERROR](state) {
    state.isLoading = false;
  },
};
