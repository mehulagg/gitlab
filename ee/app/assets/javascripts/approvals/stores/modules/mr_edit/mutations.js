import _ from 'lodash-es';
import base from '../base/mutations';
import * as types from './mutation_types';

export default {
  ...base,
  [types.DELETE_RULE](state, id) {
    const idx = _.findIndex(state.rules, x => x.id === id);

    if (idx < 0) {
      return;
    }

    const rule = state.rules[idx];

    // Keep track of rules we need to submit that are deleted
    if (!rule.isNew) {
      state.rulesToDelete.push(rule.id);
    }

    state.rules.splice(idx, 1);
  },
  [types.PUT_RULE](state, { id, ...newRule }) {
    const idx = _.findIndex(state.rules, x => x.id === id);

    if (idx < 0) {
      return;
    }

    const rule = { ...state.rules[idx], ...newRule };
    state.rules.splice(idx, 1, rule);
  },
  [types.POST_RULE](state, rule) {
    state.rules.push(rule);
  },
  [types.SET_FALLBACK_RULE](state, fallback) {
    state.fallbackApprovalsRequired = fallback.approvalsRequired;
  },
};
