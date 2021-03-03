import {
  HEADER_TOTAL_ENTRIES,
  HEADER_PAGE_NUMBER,
  HEADER_ITEMS_PER_PAGE,
} from 'ee/billings/constants';
import * as types from './mutation_types';

export default {
  [types.REQUEST_BILLABLE_MEMBERS](state) {
    state.isLoading = true;
    state.hasError = false;
  },

  [types.RECEIVE_BILLABLE_MEMBERS_SUCCESS](state, payload) {
    const { data, headers } = payload;
    state.members = data;

    state.total = headers[HEADER_TOTAL_ENTRIES];
    state.page = headers[HEADER_PAGE_NUMBER];
    state.perPage = headers[HEADER_ITEMS_PER_PAGE];

    state.isLoading = false;
  },

  [types.RECEIVE_BILLABLE_MEMBERS_ERROR](state) {
    state.isLoading = false;
    state.hasError = true;
  },

  [types.SET_SEARCH](state, searchString) {
    state.search = searchString ?? '';
  },

  [types.RESET_MEMBERS](state) {
    state.members = [];

    state.total = null;
    state.page = null;
    state.perPage = null;

    state.isLoading = false;
  },

  [types.SET_MEMBER_TO_REMOVE](state, memberToRemove) {
    if (!memberToRemove) {
      state.memberToRemove = null;
    } else {
      state.memberToRemove = state.members.find((member) => member.id === memberToRemove.id);
    }
  },

  [types.REMOVE_MEMBER](state) {
    state.isLoading = true;
    state.hasError = false;
  },

  [types.REMOVE_MEMBER_SUCCESS](state) {
    state.isLoading = false;
    state.hasError = false;
    state.memberToRemove = null;
  },

  [types.REMOVE_MEMBER_ERROR](state) {
    state.isLoading = false;
    state.hasError = true;
    state.memberToRemove = null;
  },
};
