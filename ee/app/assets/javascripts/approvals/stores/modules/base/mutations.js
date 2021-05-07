import { RULE_TYPE_ANY_APPROVER } from '../../../constants';
import * as types from './mutation_types';

export default {
  [types.SET_LOADING](state, isLoading) {
    state.isLoading = isLoading;
  },
  [types.SET_APPROVAL_SETTINGS](state, settings) {
    state.hasLoaded = true;
    state.rules = settings.rules;
    state.initialRules = [...settings.rules];
    state.fallbackApprovalsRequired = settings.fallbackApprovalsRequired;
    state.minFallbackApprovalsRequired = settings.minFallbackApprovalsRequired;
  },
  [types.ADD_EMPTY_RULE](state) {
    state.rules.unshift({
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
    });
  },
  [types.SET_RESET_TO_DEFAULT](state, resetToDefault) {
    state.resetToDefault = resetToDefault;
    state.oldRules = [...state.rules];
  },
  [types.UNDO_RULES](state) {
    state.resetToDefault = false;
    state.rules = [...state.oldRules];
  },
};
