import * as types from 'ee/pages/groups/saml_providers/saml_members/store/mutation_types';
import mutations from 'ee/pages/groups/saml_providers/saml_members/store/mutations';

describe('saml_members mutations', () => {
  describe(types.RECEIVE_SAML_MEMBERS_SUCCESS, () => {
    it('clears isInitialLoadInProgress', () => {
      const state = {};
      mutations[types.RECEIVE_SAML_MEMBERS_SUCCESS](state, {});
      expect(state.isInitialLoadInProgress).toBe(false);
    });

    it('sets provided members and pageInfo', () => {
      const state = {};
      const members = ['one', 'two'];
      const pageInfo = { dummy: 'pageInfo' };
      mutations[types.RECEIVE_SAML_MEMBERS_SUCCESS](state, { members, pageInfo });
      expect(state.members).toBe(members);
      expect(state.pageInfo).toBe(pageInfo);
    });
  });
});
