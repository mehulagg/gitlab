import API from 'ee/api';
import * as types from './mutation_types';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import { __ } from '~/locale';

/**
 * SUBSCRIPTION TABLE
 */
export const setNamespaceId = ({ commit }, namespaceId) => {
  commit(types.SET_NAMESPACE_ID, namespaceId);
};

export const fetchSubscription = ({ dispatch, state }) => {
  dispatch('requestSubscription');

  return API.userSubscription(state.namespaceId)
    .then(({ data }) => dispatch('receiveSubscriptionSuccess', data))
    .catch(() => dispatch('receiveSubscriptionError'));
};

export const requestSubscription = ({ commit }) => commit(types.REQUEST_SUBSCRIPTION);

export const receiveSubscriptionSuccess = ({ commit }, response) =>
  commit(types.RECEIVE_SUBSCRIPTION_SUCCESS, response);

export const receiveSubscriptionError = ({ commit }) => {
  createFlash(__('An error occurred while loading the subscription details.'));
  commit(types.RECEIVE_SUBSCRIPTION_ERROR);
};
