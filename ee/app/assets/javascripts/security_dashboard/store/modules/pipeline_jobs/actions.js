import * as Sentry from '@sentry/browser';
import axios from '~/lib/utils/axios_utils';
import * as types from './mutation_types';

export const setPipelineJobsPath = ({ commit }, path) => commit(types.SET_PIPELINE_JOBS_PATH, path);

export const setProjectId = ({ commit }, id) => commit(types.SET_PROJECT_ID, id);

export const fetchPipelineJobs = ({ commit, state }) => {
  if (!state.pipelineJobsPath) {
    return commit(types.RECEIVE_PIPELINE_JOBS_ERROR);
  }
  commit(types.REQUEST_PIPELINE_JOBS);

  return axios({
    method: 'GET',
    url: state.pipelineJobsPath,
  })
    .then(response => {
      const { data } = response;
      commit(types.RECEIVE_PIPELINE_JOBS_SUCCESS, data);
    })
    .catch(error => {
      Sentry.captureException(error);
      commit(types.RECEIVE_PIPELINE_JOBS_ERROR);
    });
};
