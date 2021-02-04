import { SET_ALERT } from './mutation_types';

export default {
  [SET_ALERT](state, { message, variant } = {}) {
    state.alert = { message, variant };
  },
};
