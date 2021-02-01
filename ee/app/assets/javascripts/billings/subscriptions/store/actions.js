import ApiEe from 'ee/api';
import Api from '~/api';
import createFlash from '~/flash';
import { s__ } from '~/locale';
import * as types from './mutation_types';

export const setNamespaceId = ({ commit }, namespaceId) => {
  commit(types.SET_NAMESPACE_ID, namespaceId);
};

/**
 * Subscription Table
 */
export const fetchSubscription = ({ dispatch, state }) => {
  dispatch('requestSubscription');

  return ApiEe.userSubscription(state.namespaceId)
    .then(({ data }) => dispatch('receiveSubscriptionSuccess', data))
    .catch(() => dispatch('receiveSubscriptionError'));
};

export const requestSubscription = ({ commit }) => commit(types.REQUEST_SUBSCRIPTION);

export const receiveSubscriptionSuccess = ({ commit }, response) =>
  commit(types.RECEIVE_SUBSCRIPTION_SUCCESS, response);

export const receiveSubscriptionError = ({ commit }) => {
  createFlash({
    message: s__('SubscriptionTable|An error occurred while loading the subscription details.'),
  });
  commit(types.RECEIVE_SUBSCRIPTION_ERROR);
};

/**
 * Billable Members
 */
export const fetchHasBillableGroupMembers = ({ dispatch, state }) => {
  dispatch('requestHasBillableGroupMembers');

  return Api.fetchBillableGroupMembersList(state.namespaceId, { per_page: 1, page: 1 })
    .then((data) => dispatch('receiveHasBillableGroupMembersSuccess', data))
    .catch(() => dispatch('receiveHasBillableGroupMembersError'));
};

export const requestHasBillableGroupMembers = ({ commit }) =>
  commit(types.REQUEST_HAS_BILLABLE_MEMBERS);

export const receiveHasBillableGroupMembersSuccess = ({ commit }, response) =>
  commit(types.RECEIVE_HAS_BILLABLE_MEMBERS_SUCCESS, response);

export const receiveHasBillableGroupMembersError = ({ commit }) => {
  createFlash({
    message: s__('SubscriptionTable|An error occurred while loading billable members list'),
  });
  commit(types.RECEIVE_HAS_BILLABLE_MEMBERS_ERROR);
};
