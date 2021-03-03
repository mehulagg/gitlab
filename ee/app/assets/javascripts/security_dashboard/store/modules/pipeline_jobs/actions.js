import * as Sentry from '@sentry/browser';
import Api from '~/api';
import axios from '~/lib/utils/axios_utils';
import * as types from './mutation_types';

export const setPipelineJobsPath = ({ commit }, path) => commit(types.SET_PIPELINE_JOBS_PATH, path);

export const setProjectId = ({ commit }, id) => commit(types.SET_PROJECT_ID, id);

export const setPipelineId = ({ commit }, id) => commit(types.SET_PIPELINE_ID, id);

export const fetchPipelineJobs = ({ commit, state }) => {
  if (!state.pipelineJobsPath && !(state.projectId && state.pipelineId)) {
    return commit(types.RECEIVE_PIPELINE_JOBS_ERROR);
  }
  commit(types.REQUEST_PIPELINE_JOBS);

  let requestPromise;

  // Support existing usages that rely on server provided path,
  // otherwise generate client side
  if (state.pipelineJobsPath) {
    requestPromise = axios({
      method: 'GET',
      url: state.pipelineJobsPath,
    });
  } else {
    requestPromise = Api.pipelineJobs(state.projectId, state.pipelineId);
  }

  return requestPromise
    .then((response) => {
      const { data } = response;
      commit(types.RECEIVE_PIPELINE_JOBS_SUCCESS, data);
    })
    .catch((error) => {
      Sentry.captureException(error);
      commit(types.RECEIVE_PIPELINE_JOBS_ERROR);
    });
};
