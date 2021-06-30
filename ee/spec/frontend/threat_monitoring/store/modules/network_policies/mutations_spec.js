import * as types from 'ee/threat_monitoring/store/modules/network_policies/mutation_types';
import mutations from 'ee/threat_monitoring/store/modules/network_policies/mutations';

describe('Network Policies mutations', () => {
  let state;

  beforeEach(() => {
    state = { policies: [] };
  });

  describe(types.SET_ENDPOINT, () => {
    it('sets the endpoints', () => {
      mutations[types.SET_ENDPOINT](state, 'policies');
      expect(state.policiesEndpoint).toEqual('policies');
    });
  });

  describe(types.REQUEST_CREATE_POLICY, () => {
    beforeEach(() => {
      mutations[types.REQUEST_CREATE_POLICY](state);
    });

    it('sets isUpdatingPolicy to true and sets errorUpdatingPolicy to false', () => {
      expect(state.isUpdatingPolicy).toBe(true);
      expect(state.errorUpdatingPolicy).toBe(false);
    });
  });

  describe(types.RECEIVE_CREATE_POLICY_SUCCESS, () => {
    beforeEach(() => {
      mutations[types.RECEIVE_CREATE_POLICY_SUCCESS](state);
    });

    it('sets isUpdatingPolicy to false and sets errorUpdatingPolicy to false', () => {
      expect(state.isUpdatingPolicy).toBe(false);
      expect(state.errorUpdatingPolicy).toBe(false);
    });
  });

  describe(types.RECEIVE_CREATE_POLICY_ERROR, () => {
    beforeEach(() => {
      mutations[types.RECEIVE_CREATE_POLICY_ERROR](state);
    });

    it('sets isUpdatingPolicy to false and sets errorUpdatingPolicy to true', () => {
      expect(state.isUpdatingPolicy).toBe(false);
      expect(state.errorUpdatingPolicy).toBe(true);
    });
  });

  describe(types.REQUEST_UPDATE_POLICY, () => {
    beforeEach(() => {
      mutations[types.REQUEST_UPDATE_POLICY](state);
    });

    it('sets isUpdatingPolicy to true and sets errorUpdatingPolicy to false', () => {
      expect(state.isUpdatingPolicy).toBe(true);
      expect(state.errorUpdatingPolicy).toBe(false);
    });
  });

  describe(types.RECEIVE_UPDATE_POLICY_SUCCESS, () => {
    beforeEach(() => {
      mutations[types.RECEIVE_UPDATE_POLICY_SUCCESS](state);
    });

    it('sets isUpdatingPolicy to false and sets errorUpdatingPolicy to false', () => {
      expect(state.isUpdatingPolicy).toBe(false);
      expect(state.errorUpdatingPolicy).toBe(false);
    });
  });

  describe(types.RECEIVE_UPDATE_POLICY_ERROR, () => {
    beforeEach(() => {
      mutations[types.RECEIVE_UPDATE_POLICY_ERROR](state);
    });

    it('sets isUpdatingPolicy to false and sets errorUpdatingPolicy to true', () => {
      expect(state.isUpdatingPolicy).toBe(false);
      expect(state.errorUpdatingPolicy).toBe(true);
    });
  });

  describe(types.REQUEST_DELETE_POLICY, () => {
    beforeEach(() => {
      mutations[types.REQUEST_DELETE_POLICY](state);
    });

    it('sets isRemovingPolicy to true and sets errorRemovingPolicy to false', () => {
      expect(state.isRemovingPolicy).toBe(true);
      expect(state.errorRemovingPolicy).toBe(false);
    });
  });

  describe(types.RECEIVE_DELETE_POLICY_SUCCESS, () => {
    const policy = { id: 1, name: 'production', manifest: 'foo' };

    beforeEach(() => {
      state.policies.push(policy);
      mutations[types.RECEIVE_DELETE_POLICY_SUCCESS](state, {
        policy,
      });
    });

    it('removes the policy', () => {
      expect(state.policies).not.toEqual(expect.objectContaining(policy));
    });

    it('sets isRemovingPolicy to false and sets errorRemovingPolicy to false', () => {
      expect(state.isRemovingPolicy).toBe(false);
      expect(state.errorRemovingPolicy).toBe(false);
    });
  });

  describe(types.RECEIVE_DELETE_POLICY_ERROR, () => {
    beforeEach(() => {
      mutations[types.RECEIVE_DELETE_POLICY_ERROR](state);
    });

    it('sets isRemovingPolicy to false and sets errorRemovingPolicy to true', () => {
      expect(state.isRemovingPolicy).toBe(false);
      expect(state.errorRemovingPolicy).toBe(true);
    });
  });
});
