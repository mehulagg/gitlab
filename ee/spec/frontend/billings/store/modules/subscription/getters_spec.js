import * as getters from 'ee/billings/stores/modules/subscription/getters';
import State from 'ee/billings/stores/modules/subscription/state';

describe('EE billings subscription module getters', () => {
  let state;

  beforeEach(() => {
    state = State();
  });

  describe('isFreePlan', () => {
    it('should return false', () => {
      const plan = {
        name: 'Gold',
        code: 'gold',
      };
      state.plan = plan;

      expect(getters.isFreePlan(state)).toBe(false);
    });

    it('should return true', () => {
      const plan = {
        name: null,
        code: null,
      };
      state.plan = plan;

      expect(getters.isFreePlan(state)).toBe(true);
    });
  });
});
