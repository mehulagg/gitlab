import * as types from 'ee/vuex_shared/modules/members/mutation_types';
import mutations from 'ee/vuex_shared/modules/members/mutations';
import { members, member } from 'jest/vue_shared/components/members/mock_data';

describe('Vuex members mutations', () => {
  describe(types.RECEIVE_LDAP_OVERRIDE_SUCCESS, () => {
    it('updates member', () => {
      const state = {
        members,
      };

      mutations[types.RECEIVE_LDAP_OVERRIDE_SUCCESS](state, {
        memberId: members[0].id,
        override: true,
      });

      expect(state.members[0].isOverridden).toEqual(true);
    });
  });

  describe(types.RECEIVE_LDAP_OVERRIDE_ERROR, () => {
    const state = {
      showError: false,
      errorMessage: '',
    };

    describe('when enabling LDAP override', () => {
      it('shows error message', () => {
        mutations[types.RECEIVE_LDAP_OVERRIDE_ERROR](state, true);

        expect(state.showError).toBe(true);
        expect(state.errorMessage).toBe(
          'An error occurred while trying to enable LDAP override, please try again.',
        );
      });
    });

    describe('when disabling LDAP override', () => {
      it('shows error message', () => {
        mutations[types.RECEIVE_LDAP_OVERRIDE_ERROR](state, false);

        expect(state.showError).toBe(true);
        expect(state.errorMessage).toBe(
          'An error occurred while trying to revert to LDAP group sync settings, please try again.',
        );
      });
    });
  });

  describe(types.SHOW_LDAP_OVERRIDE_CONFIRMATION_MODAL, () => {
    it('sets `ldapOverrideConfirmationModalVisible` and `memberToOverride`', () => {
      const state = {
        memberToOverride: null,
        ldapOverrideConfirmationModalVisible: false,
      };

      mutations[types.SHOW_LDAP_OVERRIDE_CONFIRMATION_MODAL](state, member);

      expect(state).toEqual({
        memberToOverride: member,
        ldapOverrideConfirmationModalVisible: true,
      });
    });
  });

  describe(types.HIDE_LDAP_OVERRIDE_CONFIRMATION_MODAL, () => {
    it('sets `ldapOverrideConfirmationModalVisible` to `false`', () => {
      const state = {
        ldapOverrideConfirmationModalVisible: true,
      };

      mutations[types.HIDE_LDAP_OVERRIDE_CONFIRMATION_MODAL](state);

      expect(state.ldapOverrideConfirmationModalVisible).toBe(false);
    });
  });
});
