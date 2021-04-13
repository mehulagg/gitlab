import Api from 'ee/api';
import createFlash from '~/flash';
import httpStatusCodes from '~/lib/utils/http_status';
import { __, sprintf } from '~/locale';
import { removeFlash, isStageNameExistsError } from '../../../utils';
import * as types from './mutation_types';

export const setStageEvents = ({ commit }, data) => commit(types.SET_STAGE_EVENTS, data);
export const setStageFormErrors = ({ commit }, errors) =>
  commit(types.SET_STAGE_FORM_ERRORS, errors);

export const hideForm = ({ commit }) => {
  commit(types.HIDE_FORM);
  removeFlash();
};

export const showCreateForm = ({ commit }) => {
  commit(types.SET_LOADING);
  commit(types.SET_FORM_INITIAL_DATA);
  commit(types.SHOW_CREATE_FORM);
  removeFlash();
};

export const showEditForm = ({ commit, dispatch }, selectedStage = {}) => {
  commit(types.SET_LOADING);
  commit(types.SET_FORM_INITIAL_DATA, selectedStage);
  dispatch('setSelectedStage', selectedStage, { root: true });
  dispatch('clearSavingCustomStage');
  commit(types.SHOW_EDIT_FORM);
  removeFlash();
};

export const clearFormErrors = ({ commit }) => {
  commit(types.CLEAR_FORM_ERRORS);
  removeFlash();
};

export const setSavingCustomStage = ({ commit }) => commit(types.SET_SAVING_CUSTOM_STAGE);
export const clearSavingCustomStage = ({ commit }) => commit(types.CLEAR_SAVING_CUSTOM_STAGE);

export const receiveCreateStageSuccess = ({ commit, dispatch }, { data: { title } }) => {
  commit(types.RECEIVE_CREATE_STAGE_SUCCESS);
  createFlash({
    message: sprintf(__(`Your custom stage '%{title}' was created`), { title }),
    type: 'notice',
  });

  return Promise.resolve()
    .then(() => dispatch('fetchGroupStagesAndEvents', null, { root: true }))
    .then(() => dispatch('clearSavingCustomStage'))
    .catch(() => {
      createFlash({
        message: __('There was a problem refreshing the data, please try again'),
      });
    });
};

export const receiveCreateStageError = (
  { commit, dispatch },
  { status = httpStatusCodes.BAD_REQUEST, errors = {}, data = {} } = {},
) => {
  commit(types.RECEIVE_CREATE_STAGE_ERROR);
  const { name = null } = data;
  const flashMessage =
    name && isStageNameExistsError({ status, errors })
      ? sprintf(__(`'%{name}' stage already exists`), { name })
      : __('There was a problem saving your custom stage, please try again');

  createFlash({
    message: flashMessage,
  });
  return dispatch('setStageFormErrors', errors);
};

export const createStage = ({ dispatch, rootGetters }, data) => {
  const { currentGroupPath, currentValueStreamId } = rootGetters;

  dispatch('clearFormErrors');
  dispatch('setSavingCustomStage');

  return Api.cycleAnalyticsCreateStage({
    groupId: currentGroupPath,
    valueStreamId: currentValueStreamId,
    data,
  })
    .then((response) => {
      const { status, data: responseData } = response;
      return dispatch('receiveCreateStageSuccess', { status, data: responseData });
    })
    .catch(({ response } = {}) => {
      const { data: { message, errors } = null, status = httpStatusCodes.BAD_REQUEST } = response;
      dispatch('receiveCreateStageError', { data, message, errors, status });
    });
};
