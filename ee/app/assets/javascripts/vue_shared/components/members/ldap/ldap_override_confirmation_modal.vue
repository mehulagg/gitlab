<script>
import { mapState, mapActions } from 'vuex';
import { GlModal, GlSprintf } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import { LDAP_OVERRIDE_CONFIRMATION_MODAL_ID } from '../constants';

export default {
  name: 'LdapOverrideConfirmationModal',
  i18n: {
    editPermissions: s__('Members|Edit permissions'),
    modalBody: s__(
      'Members|%{userName} is currently an LDAP user. Editing their permissions will override the settings from the LDAP group sync.',
    ),
    toastMessage: s__('Members|LDAP override enabled.'),
  },
  actionCancel: {
    text: __('Cancel'),
  },
  modalId: LDAP_OVERRIDE_CONFIRMATION_MODAL_ID,
  components: { GlModal, GlSprintf },
  data() {
    return {
      busy: false,
    };
  },
  computed: {
    ...mapState(['memberToOverride', 'ldapOverrideConfirmationModalVisible']),
    actionPrimary() {
      return {
        text: this.$options.i18n.editPermissions,
        attributes: {
          variant: 'warning',
          loading: this.busy,
        },
      };
    },
  },
  methods: {
    ...mapActions(['updateLdapOverride', 'hideLdapOverrideConfirmationModal']),
    handlePrimary() {
      this.busy = true;

      this.updateLdapOverride({ memberId: this.memberToOverride.id, override: true })
        .then(() => {
          this.busy = false;
          this.hideLdapOverrideConfirmationModal();
          this.$toast.show(this.$options.i18n.toastMessage);
        })
        .catch(() => {
          this.hideLdapOverrideConfirmationModal();
          this.busy = false;
        });
    },
  },
};
</script>

<template>
  <gl-modal
    v-bind="$attrs"
    :modal-id="$options.modalId"
    :title="$options.i18n.editPermissions"
    :visible="ldapOverrideConfirmationModalVisible"
    :action-primary="actionPrimary"
    :action-cancel="$options.actionCancel"
    size="sm"
    @primary="handlePrimary"
    @hide="hideLdapOverrideConfirmationModal"
  >
    <p v-if="memberToOverride">
      <gl-sprintf :message="$options.i18n.modalBody">
        <template #userName>{{ memberToOverride.user.name }}</template>
      </gl-sprintf>
    </p>
  </gl-modal>
</template>
