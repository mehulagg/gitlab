import Api from '~/api';
import * as types from './mutation_types';
import createFlash from '~/flash';
import { s__ } from '~/locale';

export const fetchBillableMembersList = ({ dispatch, state }, { page, search } = {}) => {
  dispatch('requestBillableMembersList');

  return Api.fetchBillableGroupMembersList(state.namespaceId, { page, search })
    .then(data => dispatch('receiveBillableMembersListSuccess', data))
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

export const setSearch = async ({ commit, state, dispatch, getters }, search) => {
  await commit(types.SET_SEARCH, search);

  if (state.search.length === 0) {
    dispatch('fetchBillableMembersList');
  } else if (getters.isSearchStringTooShort) {
    commit(types.RESET_MEMBERS);
  } else if (!getters.isSearchStringTooShort) {
    dispatch('fetchBillableMembersList', { search });
  }
};
