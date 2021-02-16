import Api from 'ee/api';
import createFlash from '~/flash';
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

export const resetMembers = ({ commit }) => {
  commit(types.RESET_MEMBERS);
};

export const removeMember = ({ dispatch, state }, member) => {
  return Api.removeBillableGroupMember(state.namespaceId, member.id)
    .then(() => dispatch('requestBillableMembersList'))
    .catch(() => dispatch('removeMemberError'));
};

export const removeMemberSuccess = ({ commit }) => commit(types.REMOVE_MEMBER_SUCCESS);

export const removeMemberError = ({ commit }) => {
  createFlash({
    message: s__('Billing|An error occurred while removing billable members list'),
  });
  commit(types.REMOVE_MEMBER_ERROR);
};
