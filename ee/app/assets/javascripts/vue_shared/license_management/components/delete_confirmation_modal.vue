<script>
import _ from 'lodash-es';
import { s__, sprintf } from '~/locale';
import { mapActions, mapState } from 'vuex';
import DeprecatedModal2 from '~/vue_shared/components/deprecated_modal_2.vue';

export default {
  name: 'LicenseDeleteConfirmationModal',
  components: { GlModal: DeprecatedModal2 },
  computed: {
    ...mapState(['currentLicenseInModal']),
    confirmationText() {
      const name = `<strong>${_.escape(this.currentLicenseInModal.name)}</strong>`;

      return sprintf(
        s__('LicenseCompliance|You are about to remove the license, %{name}, from this project.'),
        { name },
        false,
      );
    },
  },
  methods: {
    ...mapActions(['resetLicenseInModal', 'deleteLicense']),
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
