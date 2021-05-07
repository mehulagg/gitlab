import {
  mapExternalApprovalRuleRequest,
  mapApprovalRuleRequest,
  mapApprovalSettingsResponse,
  mapApprovalFallbackRuleRequest,
  mapExternalApprovalResponse,
} from 'ee/approvals/mappers';
import { joinRuleResponses } from 'ee/approvals/utils';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { __ } from '~/locale';
import * as types from '../base/mutation_types';

const fetchSettings = ({ settingsPath }) => {
  return axios.get(settingsPath).then((res) => mapApprovalSettingsResponse(res.data));
};

const fetchExternalApprovalRules = ({ externalApprovalRulesPath }) => {
  return axios.get(externalApprovalRulesPath).then((res) => mapExternalApprovalResponse(res.data));
};

export const requestRules = ({ commit }) => {
  commit(types.SET_LOADING, true);
};

export const receiveRulesSuccess = ({ commit }, approvalSettings) => {
  commit(types.SET_APPROVAL_SETTINGS, approvalSettings);
  commit(types.SET_LOADING, false);
};

export const receiveRulesError = () => {
  createFlash({
    message: __('An error occurred fetching the approval rules.'),
  });
};

export const fetchRules = ({ rootState, dispatch }) => {
  dispatch('requestRules');

  const requests = [fetchSettings(rootState.settings)];

  if (gon?.features?.ffComplianceApprovalGates) {
    requests.push(fetchExternalApprovalRules(rootState.settings));
  }

  return Promise.all(requests)
    .then((responses) => dispatch('receiveRulesSuccess', joinRuleResponses(responses)))
    .catch(() => dispatch('receiveRulesError'));
};

export const postRuleSuccess = ({ dispatch }) => {
  dispatch('createModal/close');
  dispatch('fetchRules');
};

export const putExternalApprovalRule = ({ rootState, dispatch }, { id, ...newRule }) => {
  const { externalApprovalRulesPath } = rootState.settings;

  return axios
    .put(`${externalApprovalRulesPath}/${id}`, mapExternalApprovalRuleRequest(newRule))
    .then(() => dispatch('postRuleSuccess'));
};

export const deleteExternalApprovalRule = ({ rootState, dispatch }, id) => {
  const { externalApprovalRulesPath } = rootState.settings;

  return axios
    .delete(`${externalApprovalRulesPath}/${id}`)
    .then(() => dispatch('deleteRuleSuccess'))
    .catch(() => dispatch('deleteRuleError'));
};

export const postExternalApprovalRule = ({ rootState, dispatch }, rule) => {
  const { externalApprovalRulesPath } = rootState.settings;

  return axios
    .post(externalApprovalRulesPath, mapExternalApprovalRuleRequest(rule))
    .then(() => dispatch('postRuleSuccess'));
};

export const postRule = ({ rootState, dispatch }, rule) => {
  const { rulesPath } = rootState.settings;

  return axios
    .post(rulesPath, mapApprovalRuleRequest(rule))
    .then(() => dispatch('postRuleSuccess'));
};

export const putRule = ({ rootState, dispatch }, { id, ...newRule }) => {
  const { rulesPath } = rootState.settings;

  return axios
    .put(`${rulesPath}/${id}`, mapApprovalRuleRequest(newRule))
    .then(() => dispatch('postRuleSuccess'));
};

export const deleteRuleSuccess = ({ dispatch }) => {
  dispatch('deleteModal/close');
  dispatch('fetchRules');
};

export const deleteRuleError = () => {
  createFlash({
    message: __('An error occurred while deleting the approvers group'),
  });
};

export const deleteRule = ({ rootState, dispatch }, id) => {
  const { rulesPath } = rootState.settings;

  return axios
    .delete(`${rulesPath}/${id}`)
    .then(() => dispatch('deleteRuleSuccess'))
    .catch(() => dispatch('deleteRuleError'));
};

export const putFallbackRuleSuccess = ({ dispatch }) => {
  dispatch('createModal/close');
  dispatch('fetchRules');
};

export const putFallbackRule = ({ rootState, dispatch }, fallback) => {
  const { projectPath } = rootState.settings;

  return axios
    .put(projectPath, mapApprovalFallbackRuleRequest(fallback))
    .then(() => dispatch('putFallbackRuleSuccess'));
};

export const requestEditRule = ({ dispatch }, rule) => {
  dispatch('createModal/open', rule);
};

export const requestDeleteRule = ({ dispatch }, rule) => {
  dispatch('deleteModal/open', rule);
};

export const addEmptyRule = ({ commit }) => {
  commit(types.ADD_EMPTY_RULE);
};
