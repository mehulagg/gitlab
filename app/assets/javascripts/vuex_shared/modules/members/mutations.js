import * as types from './mutation_types';
import { s__ } from '~/locale';
import { findAndUpdateMember } from './utils';

export default {
  [types.RECEIVE_MEMBER_ROLE_SUCCESS](state, { memberId, accessLevel }) {
    findAndUpdateMember(state, memberId, 'accessLevel', accessLevel);
  },
  [types.RECEIVE_MEMBER_ROLE_ERROR](state) {
    state.errorMessage = s__("Members|An error occurred while updating the member's role");
    state.showError = true;
  },
  [types.HIDE_ERROR](state) {
    state.showError = false;
    state.errorMessage = '';
  },
};
