import createState from 'ee/threat_monitoring/store/modules/network_policies/state';
import * as getters from 'ee/threat_monitoring/store/modules/network_policies/getters';

describe('networkPolicies module getters', () => {
  let state;

  beforeEach(() => {
    state = createState();
  });

  describe('policiesWithDefaults', () => {
    describe('without policies in the state', () => {
      it('returns predefined policies', () => {
        expect(getters.policiesWithDefaults(state).map(({ name }) => name)).toEqual([
          'drop-outbound',
          'allow-inbound-http',
        ]);
      });
    });

    describe('with policies in the state', () => {
      beforeEach(() => {
        state.policies = [{ name: 'user-policy' }];
      });

      it('returns user owned and predefined policies', () => {
        expect(getters.policiesWithDefaults(state).map(({ name }) => name)).toEqual([
          'user-policy',
          'drop-outbound',
          'allow-inbound-http',
        ]);
      });

      describe('with deployed predefined policy', () => {
        beforeEach(() => {
          state.policies = [{ name: 'user-policy' }, { name: 'drop-outbound' }];
        });

        it('returns user policies and a single predefined policy', () => {
          expect(getters.policiesWithDefaults(state).map(({ name }) => name)).toEqual([
            'user-policy',
            'drop-outbound',
            'allow-inbound-http',
          ]);
        });
      });
    });
  });
});
