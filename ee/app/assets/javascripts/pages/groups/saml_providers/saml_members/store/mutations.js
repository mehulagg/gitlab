import * as types from './mutation_types';

export default {
  [types.RECEIVE_SAML_MEMBERS_SUCCESS](state, { members, pageInfo }) {
    Object.assign(state, {
      isInitialLoadInProgress: false,
      members,
      pageInfo,
    });
  },
};
