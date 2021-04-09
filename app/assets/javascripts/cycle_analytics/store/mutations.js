import * as types from './mutation_types';

export default {
  [types.INITIALIZE](state, { requestPath }) {
    state.requestPath = requestPath;
  },
};
