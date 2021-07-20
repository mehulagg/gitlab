import Api from 'ee/api';
import * as GroupsApi from 'ee/api/groups_api';
import createFlash, { FLASH_TYPES } from '~/flash';
import { s__ } from '~/locale';
import * as types from './mutation_types';

export const fetchBillableMembersList = ({ dispatch, state }, { page, search } = {}) => {
  dispatch('requestBillableMembersList');

  return Api.fetchBillableGroupMembersList(state.namespaceId, { page, search })
    .then((data) => dispatch('receiveBillableMembersListSuccess', data))
    .catch(() => dispatch('receiveBillableMembersListError'));
};

export const requestBillableMembersList = ({ commit }) => commit(types.REQUEST_BILLABLE_MEMBERS);

export const receiveBillableMembersListSuccess = ({ commit }, response) =>
  commit(types.RECEIVE_BILLABLE_MEMBERS_SUCCESS, response);

export const receiveBillableMembersListError = ({ commit }) => {
  createFlash({
    message: s__('Billing|An error occurred while loading billable members list'),
  });
  commit(types.RECEIVE_BILLABLE_MEMBERS_ERROR);
};

export const resetBillableMembers = ({ commit }) => {
  commit(types.RESET_BILLABLE_MEMBERS);
};

export const setBillableMemberToRemove = ({ commit }, member) => {
  commit(types.SET_BILLABLE_MEMBER_TO_REMOVE, member);
};

export const removeBillableMember = ({ dispatch, state }) => {
  return GroupsApi.removeBillableMemberFromGroup(state.namespaceId, state.billableMemberToRemove.id)
    .then(() => dispatch('removeBillableMemberSuccess'))
    .catch(() => dispatch('removeBillableMemberError'));
};

export const removeBillableMemberSuccess = ({ dispatch, commit }) => {
  dispatch('fetchBillableMembersList');

  createFlash({
    message: s__('Billing|User was successfully removed'),
    type: FLASH_TYPES.SUCCESS,
  });

  commit(types.REMOVE_BILLABLE_MEMBER_SUCCESS);
};

export const removeBillableMemberError = ({ commit }) => {
  createFlash({
    message: s__('Billing|An error occurred while removing a billable member'),
  });
  commit(types.REMOVE_BILLABLE_MEMBER_ERROR);
};

export const fetchBillableMemberDetails = ({ dispatch, commit, state }, memberId) => {
  if (state.userDetails[memberId]) {
    commit(types.FETCH_BILLABLE_MEMBER_DETAILS_SUCCESS, {
      memberId,
      memberships: state.userDetails[memberId].items,
    });

    return Promise.resolve();
  }

  commit(types.FETCH_BILLABLE_MEMBER_DETAILS, memberId);

  return Api.fetchBillableGroupMemberMemberships(state.namespaceId, memberId)
    .then(({ data }) =>
      commit(types.FETCH_BILLABLE_MEMBER_DETAILS_SUCCESS, { memberId, memberships: data }),
    )
    .catch(() => dispatch('fetchBillableMemberDetailsError', memberId));
};

export const fetchBillableMemberDetailsError = ({ commit }, memberId) => {
  commit(types.FETCH_BILLABLE_MEMBER_DETAILS_ERROR, memberId);

  createFlash({
    message: s__('Billing|An error occurred while getting a billable member details'),
  });
};
