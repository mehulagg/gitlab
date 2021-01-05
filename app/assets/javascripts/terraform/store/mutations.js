import * as types from './mutation_types';

export default {
  [types.SET_STATE_LIST](state, value) {
    state.statesList = value;
  },
};
