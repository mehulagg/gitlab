import flash from '~/flash';
import { __ } from '~/locale';

import axios from '~/lib/utils/axios_utils';

import epicUtils from '../utils/epic_utils';
import { statusType, statusEvent } from '../constants';

import * as types from './mutation_types';

export const setEpicMeta = ({ commit }, meta) => commit(types.SET_EPIC_META, meta);

export const setEpicData = ({ commit }, data) => commit(types.SET_EPIC_DATA, data);

export const requestEpicStatusChange = ({ commit }) => commit(types.REQUEST_EPIC_STATUS_CHANGE);

export const requestEpicStatusChangeSuccess = ({ commit }, data) =>
  commit(types.REQUEST_EPIC_STATUS_CHANGE_SUCCESS, data);

export const requestEpicStatusChangeFailure = ({ commit }) => {
  commit(types.REQUEST_EPIC_STATUS_CHANGE_FAILURE);
  flash(__('Unable to update this epic at this time.'));
};

export const triggerIssuableEvent = (_, { isEpicOpen }) => {
  // Ensure that status change is reflected across the page.
  // As `Close`/`Reopen` button is also present under
  // comment form (part of Notes app) We've wrapped
  // call to `$(document).trigger` within `triggerDocumentEvent`
  // for ease of testing
  epicUtils.triggerDocumentEvent('issuable_vue_app:change', isEpicOpen);
  epicUtils.triggerDocumentEvent('issuable:change', isEpicOpen);
};

export const toggleEpicStatus = ({ state, dispatch }, isEpicOpen) => {
  dispatch('requestEpicStatusChange');

  const statusEventType = isEpicOpen ? statusEvent.close : statusEvent.reopen;
  const queryParam = `epic[state_event]=${statusEventType}`;

  axios
    .put(`${state.endpoint}.json?${encodeURI(queryParam)}`)
    .then(({ data }) => {
      dispatch('requestEpicStatusChangeSuccess', data);
      dispatch('triggerIssuableEvent', { isEpicOpen: data.state === statusType.close });
    })
    .catch(() => {
      dispatch('requestEpicStatusChangeFailure');
      dispatch('triggerIssuableEvent', { isEpicOpen: !isEpicOpen });
    });
};

// prevent babel-plugin-rewire from generating an invalid default during karma tests
export default () => {};
