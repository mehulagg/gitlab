<script>
/* eslint-disable vue/no-v-html */
import { escape } from 'lodash';
import { mapActions, mapState } from 'vuex';
import { LICENSE_MANAGEMENT } from 'ee/vue_shared/license_compliance/store/constants';
import { s__, sprintf } from '~/locale';
import DeprecatedModal2 from '~/vue_shared/components/deprecated_modal_2.vue';

export default {
  name: 'LicenseDeleteConfirmationModal',
  components: { GlModal: DeprecatedModal2 },
  computed: {
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
    id="modal-license-delete-confirmation"
    :header-title-text="s__('LicenseCompliance|Remove license?')"
    :footer-primary-button-text="s__('LicenseCompliance|Remove license')"
    footer-primary-button-variant="danger"
    @cancel="resetLicenseInModal"
    @submit="deleteLicense(currentLicenseInModal)"
  >
    <span v-if="currentLicenseInModal" v-html="confirmationText"></span>
  </gl-modal>
</template>
