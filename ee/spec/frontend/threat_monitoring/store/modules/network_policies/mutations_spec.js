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

  describe(types.REQUEST_POLICIES, () => {
    beforeEach(() => {
      mutations[types.REQUEST_POLICIES](state);
    });

    it('sets isLoadingPolicies to true and sets errorLoadingPolicies to false', () => {
      expect(state.isLoadingPolicies).toBe(true);
      expect(state.errorLoadingPolicies).toBe(false);
    });
  });

  describe(types.RECEIVE_POLICIES_SUCCESS, () => {
    let policies;

    beforeEach(() => {
      policies = [{ id: 1, name: 'production' }];
      mutations[types.RECEIVE_POLICIES_SUCCESS](state, policies);
    });

    it('sets policies to the payload', () => {
      expect(state.policies).toEqual(expect.objectContaining(policies));
    });

    it('sets isLoadingPolicies to false and sets errorLoadingPolicies to false', () => {
      expect(state.isLoadingPolicies).toBe(false);
      expect(state.errorLoadingPolicies).toBe(false);
    });
  });

  describe(types.RECEIVE_POLICIES_ERROR, () => {
    beforeEach(() => {
      mutations[types.RECEIVE_POLICIES_ERROR](state);
    });

    it('sets isLoadingPolicies to false and sets errorLoadingPolicies to true', () => {
      expect(state.isLoadingPolicies).toBe(false);
      expect(state.errorLoadingPolicies).toBe(true);
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
    const policy = { id: 1, name: 'production', manifest: 'foo' };

    beforeEach(() => {
      mutations[types.RECEIVE_CREATE_POLICY_SUCCESS](state, policy);
    });

    it('adds a policy to the store', () => {
      expect(state.policies).toEqual(expect.objectContaining([policy]));
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
    const policy = { id: 1, name: 'production', manifest: 'foo' };
    const updatedPolicy = { id: 1, name: 'production', manifest: 'bar' };

    beforeEach(() => {
      state.policies.push(policy);
      mutations[types.RECEIVE_UPDATE_POLICY_SUCCESS](state, {
        policy,
        updatedPolicy,
      });
    });

    it('replaces policies with the updatedPolicy', () => {
      expect(state.policies).not.toEqual(expect.objectContaining(policy));
      expect(state.policies).toEqual(expect.objectContaining([updatedPolicy]));
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
