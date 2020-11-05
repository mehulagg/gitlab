import * as types from './mutation_types';
import axios from '~/lib/utils/axios_utils';

export * from '~/vuex_shared/modules/members/actions';

export const updateLdapOverride = async ({ state, commit }, { memberId, override }) => {
  try {
    await axios.patch(
      state.ldapOverridePath.replace(':id', memberId),
      state.requestFormatter({ override }),
    );

    commit(types.RECEIVE_LDAP_OVERRIDE_SUCCESS, {
      memberId,
      override,
    });
  } catch (error) {
    commit(types.RECEIVE_LDAP_OVERRIDE_ERROR, override);

    throw error;
  }
};

export const showLdapOverrideConfirmationModal = ({ commit }, member) => {
  commit(types.SHOW_LDAP_OVERRIDE_CONFIRMATION_MODAL, member);
};

export const hideLdapOverrideConfirmationModal = ({ commit }) => {
  commit(types.HIDE_LDAP_OVERRIDE_CONFIRMATION_MODAL);
};
