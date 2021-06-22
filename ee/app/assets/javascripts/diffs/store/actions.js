import Visibility from 'visibilityjs';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import httpStatusCodes from '~/lib/utils/http_status';
import Poll from '~/lib/utils/poll';
import { __ } from '~/locale';

import * as types from './mutation_types';

export * from '~/diffs/store/actions';

let codequalityPoll;

export const setCodequalityEndpoint = ({ commit }, endpoint) => {
  commit(types.SET_CODEQUALITY_ENDPOINT, endpoint);
};

export const clearCodequalityPoll = () => {
  codequalityPoll = null;
};

export const stopCodequalityPolling = () => {
  if (codequalityPoll) codequalityPoll.stop();
};

export const restartCodequalityPolling = () => {
  if (codequalityPoll) codequalityPoll.restart();
};

export const fetchCodequality = ({ commit, state, dispatch }) => {
  codequalityPoll = new Poll({
    resource: {
      getCodequalityDiffReports: (endpoint) => axios.get(endpoint),
    },
    data: state.endpointCodequality,
    method: 'getCodequalityDiffReports',
    successCallback: ({ status, data }) => {
      if (status === httpStatusCodes.OK) {
        commit(types.SET_CODEQUALITY_DATA, data);

        dispatch('stopCodequalityPolling');
      }
    },
    errorCallback: ({ response }) => {
      if (response.status === httpStatusCodes.BAD_REQUEST) {
        // we want to ignore this error status and keep polling here because
        // this is the status we get when waiting for new reports
        // such as when the MR is rebased or new commits are pushed
        // see https://gitlab.com/gitlab-org/gitlab/-/issues/334116
      } else {
        createFlash({
          message: __('An unexpected error occurred while loading the code quality diff.'),
        });
      }
    },
  });

  if (!Visibility.hidden()) {
    codequalityPoll.makeRequest();
  }

  Visibility.change(() => {
    if (!Visibility.hidden()) {
      dispatch('restartCodequalityPolling');
    } else {
      dispatch('stopCodequalityPolling');
    }
  });
};
