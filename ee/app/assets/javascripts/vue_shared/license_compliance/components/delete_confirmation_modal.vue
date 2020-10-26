<script>
/* eslint-disable vue/no-v-html */
import { escape } from 'lodash';
import { mapActions, mapState } from 'vuex';
import { LICENSE_MANAGEMENT } from 'ee/vue_shared/license_compliance/store/constants';
import { s__, sprintf } from '~/locale';
import { GlModal } from '@gitlab/ui';

export default {
  name: 'LicenseDeleteConfirmationModal',
  components: { GlModal },
  computed: {
    primaryProps() {
      return {
        text: __('LicenseCompliance|Remove license'),
        attributes: [{ variant: 'danger' }],
      };
    },
    cancelProps() {
      return {
        text: __('Cancel'),
      };
    },
    ...mapState(LICENSE_MANAGEMENT, ['currentLicenseInModal']),
    confirmationText() {
      const name = `<strong>${escape(this.currentLicenseInModal.name)}</strong>`;

      return sprintf(
        s__('LicenseCompliance|You are about to remove the license, %{name}, from this project.'),
        { name },
        false,
      );
    },
  },
  methods: {
    ...mapActions(LICENSE_MANAGEMENT, ['resetLicenseInModal', 'deleteLicense']),
  },
};
</script>
<template>
  <gl-modal
    modal-id="modal-license-delete-confirmation"
    title-tag="s__('LicenseCompliance|Remove license?')"
    :primary-props="primaryProps"
    :cancel-props="cancelProps"
    @primary="deleteLicense(currentLicenseInModal)"
    @cancel="resetLicenseInModal"
  >
    <span v-if="currentLicenseInModal" v-html="confirmationText"></span>
  </gl-modal>
</template>
