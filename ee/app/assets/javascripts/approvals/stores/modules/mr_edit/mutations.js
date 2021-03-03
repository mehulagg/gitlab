import { RULE_TYPE_ANY_APPROVER } from '../../../constants';
import base from '../base/mutations';
import * as types from './mutation_types';

export default {
  ...base,
  [types.DELETE_RULE](state, id) {
    const idx = state.rules.findIndex((x) => x.id === id);

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
  [types.DELETE_ANY_RULE](state) {
    const [newRule, oldRule] = state.rules;

    if (!newRule && !oldRule) {
      return;
    }

    if (!oldRule.isNew) {
      state.rulesToDelete.push(oldRule.id);
    }

    state.rules = [newRule];
  },
  [types.PUT_RULE](state, { id, ...newRule }) {
    const idx = state.rules.findIndex((x) => x.id === id);

    if (idx < 0) {
      return;
    }

    const rule = { ...state.rules[idx], ...newRule };
    state.rules.splice(idx, 1, rule);
  },
  [types.POST_RULE](state, rule) {
    const [firstRule] = state.rules;

    if (
      firstRule &&
      firstRule.ruleType === RULE_TYPE_ANY_APPROVER &&
      rule.ruleType === RULE_TYPE_ANY_APPROVER
    ) {
      state.rules = [rule];
    } else {
      state.rules.push(rule);
    }
  },
  [types.POST_REGULAR_RULE](state, rule) {
    state.rules.unshift(rule);
  },
  [types.SET_FALLBACK_RULE](state, fallback) {
    state.fallbackApprovalsRequired = fallback.approvalsRequired;
  },
  [types.SET_EMPTY_RULE](state) {
    const anyRule = state.initialRules.find((rule) => rule.ruleType === RULE_TYPE_ANY_APPROVER);

    if (anyRule) {
      state.rules = [anyRule];
      state.rulesToDelete = [];
    } else {
      state.rules = [
        {
          id: null,
          name: '',
          approvalsRequired: 0,
          minApprovalsRequired: 0,
          approvers: [],
          containsHiddenGroups: false,
          users: [],
          groups: [],
          ruleType: RULE_TYPE_ANY_APPROVER,
          isNew: true,
        },
      ];
    }
  },
  [types.SET_TARGET_BRANCH](state, targetBranch) {
    state.targetBranch = targetBranch;
  },
};
