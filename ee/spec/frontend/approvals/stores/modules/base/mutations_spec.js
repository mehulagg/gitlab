import * as types from 'ee/approvals/stores/modules/base/mutation_types';
import mutations from 'ee/approvals/stores/modules/base/mutations';
import createState from 'ee/approvals/stores/state';

describe('EE approvals base module mutations', () => {
  let state;

  beforeEach(() => {
    state = createState();
  });

  describe(types.SET_LOADING, () => {
    it('sets isLoading', () => {
      state.isLoading = false;

      mutations[types.SET_LOADING](state, true);

      expect(state.isLoading).toBe(true);
    });
  });

  describe(types.SET_APPROVAL_SETTINGS, () => {
    it('sets rules', () => {
      const settings = {
        rules: [{ id: 1 }, { id: 2 }],
        fallbackApprovalsRequired: 7,
        minFallbackApprovalsRequired: 1,
      };

      state.hasLoaded = false;
      state.rules = [];

      mutations[types.SET_APPROVAL_SETTINGS](state, settings);

      expect(state).toEqual(expect.objectContaining(settings));
    });
  });

  describe(types.SET_RESET_TO_DEFAULT, () => {
    it('resets rules', () => {
      state.rules = ['test'];

      mutations[types.SET_RESET_TO_DEFAULT](state, true);

      expect(state.resetToDefault).toBe(true);
      expect(state.oldRules).toEqual(['test']);
    });
  });

  describe(types.UNDO_RULES, () => {
    it('undos rules', () => {
      const oldRules = ['old'];
      state.rules = ['new'];
      state.oldRules = oldRules;

      mutations[types.UNDO_RULES](state, true);

      expect(state.resetToDefault).toBe(false);
      expect(state.rules).toEqual(oldRules);
    });
  });
});
