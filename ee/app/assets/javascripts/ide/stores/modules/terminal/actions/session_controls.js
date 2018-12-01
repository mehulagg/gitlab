import axios from '~/lib/utils/axios_utils';
import httpStatus from '~/lib/utils/http_status';
import flash from '~/flash';
import * as types from '../mutation_types';
import * as messages from '../messages';
import { STATUS_STARTING, STATUS_STOPPING, STATUS_STOPPED } from '../../../../constants';

// --------------------
// startSession actions

export const requestStartSession = ({ commit }) => {
  commit(types.SET_SESSION_STATUS, STATUS_STARTING);
};

export const receiveStartSessionSuccess = ({ commit, dispatch }, data) => {
  commit(types.START_SESSION, {
    id: data.id,
    status: data.status,
    showPath: data.show_path,
    cancelPath: data.cancel_path,
    retryPath: data.retry_path,
    terminalPath: data.terminal_path,
  });

  dispatch('startPollingSessionStatus');
};

export const receiveStartSessionError = ({ dispatch }) => {
  flash(messages.UNEXPECTED_ERROR_STARTING);
  dispatch('killSession');
};

export const startSession = ({ state, dispatch, rootGetters, rootState }) => {
  if (state.session && state.session.status === STATUS_STARTING) {
    return;
  }

  const { currentProject } = rootGetters;
  const { currentBranchId } = rootState;

  dispatch('requestStartSession');

  axios
    .post(`/${currentProject.path_with_namespace}/ide_terminals`, {
      branch: currentBranchId,
      format: 'json',
    })
    .then(({ data }) => {
      dispatch('receiveStartSessionSuccess', data);
    })
    .catch(error => {
      dispatch('receiveStartSessionError', error);
    });
};

// -------------------
// stopSession actions

export const requestStopSession = ({ commit }) => {
  commit(types.SET_SESSION_STATUS, STATUS_STOPPING);
};

export const receiveStopSessionSuccess = ({ dispatch }) => {
  dispatch('killSession');
};

export const receiveStopSessionError = ({ dispatch }) => {
  flash(messages.UNEXPECTED_ERROR_STOPPING);
  dispatch('killSession');
};

export const stopSession = ({ state, dispatch }) => {
  const { cancelPath } = state.session;

  dispatch('requestStopSession');

  axios
    .post(cancelPath)
    .then(() => {
      dispatch('receiveStopSessionSuccess');
    })
    .catch(err => {
      dispatch('receiveStopSessionError', err);
    });
};

export const killSession = ({ commit, dispatch }) => {
  dispatch('stopPollingSessionStatus');
  commit(types.SET_SESSION_STATUS, STATUS_STOPPED);
};

// ----------------------
// restartSession actions

export const restartSession = ({ state, dispatch, rootState }) => {
  const { status, retryPath } = state.session;
  const { currentBranchId } = rootState;

  if (!retryPath || status !== STATUS_STOPPED) {
    return;
  }

  dispatch('requestStartSession');

  axios
    .post(retryPath, { branch: currentBranchId, format: 'json' })
    .then(({ data }) => {
      dispatch('receiveStartSessionSuccess', data);
    })
    .catch(error => {
      const responseStatus = error.response && error.response.status;
      // We may have removed the build, in this case
      // we'll just create a new pipeline
      if (responseStatus === httpStatus.NOT_FOUND) {
        dispatch('startSession');
      } else {
        dispatch('receiveStartSessionError', error);
      }
    });
};
