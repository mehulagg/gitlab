import * as types from './mutation_types';

export default {
  [types.REQUEST_SETTING](state) {
    Object.assign(state, {
      isLoading: true,
    });
  },
  [types.RECEIVE_SETTING_SUCCESS](state, data) {
    Object.assign(state, {
      allowAuthorApproval: Boolean(data.allow_author_approval),
      isLoading: false,
    });
  },
  [types.RECEIVE_SETTING_ERROR](state) {
    Object.assign(state, {
      isLoading: false,
    });
  },
};
