<script>
import { mapActions, mapState } from 'vuex';
import { GlLink } from '@gitlab/ui';
import { LICENSE_MANAGEMENT } from 'ee/vue_shared/license_compliance/store/constants';
import { s__ } from '~/locale';
import DeprecatedModal2 from '~/vue_shared/components/deprecated_modal_2.vue';
import LicensePackages from './license_packages.vue';
import { LICENSE_APPROVAL_STATUS } from '../constants';

export default {
  name: 'LicenseSetApprovalStatusModal',
  components: { GlLink, LicensePackages, GlModal: DeprecatedModal2 },
  computed: {
    ...mapState(LICENSE_MANAGEMENT, ['currentLicenseInModal', 'canManageLicenses']),
    headerTitleText() {
      if (!this.canManageLicenses) {
        return s__('LicenseCompliance|License details');
      }
      return s__('LicenseCompliance|License review');
    },
    canApprove() {
      return (
        this.canManageLicenses &&
        this.currentLicenseInModal &&
        this.currentLicenseInModal.approvalStatus !== LICENSE_APPROVAL_STATUS.ALLOWED
      );
    },
    canBlacklist() {
      return (
        this.canManageLicenses &&
        this.currentLicenseInModal &&
        this.currentLicenseInModal.approvalStatus !== LICENSE_APPROVAL_STATUS.DENIED
      );
    },
  },
  methods: {
    ...mapActions(LICENSE_MANAGEMENT, ['resetLicenseInModal', 'allowLicense', 'denyLicense']),
  },
};
</script>
<template>
  <gl-modal
    id="modal-set-license-approval"
    :header-title-text="headerTitleText"
    modal-size="lg"
    data-qa-selector="license_management_modal"
    @cancel="resetLicenseInModal"
  >
    <slot v-if="currentLicenseInModal">
      <div class="row gl-mt-3 gl-mb-3 js-license-name">
        <label class="col-sm-3 text-right font-weight-bold">
          {{ s__('LicenseCompliance|License') }}:
        </label>
        <div class="col-sm-9 text-secondary">{{ currentLicenseInModal.name }}</div>
      </div>
      <div v-if="currentLicenseInModal.url" class="row gl-mt-3 gl-mb-3 js-license-url">
        <label class="col-sm-3 text-right font-weight-bold">
          {{ s__('LicenseCompliance|URL') }}:
        </label>
        <div class="col-sm-9 text-secondary">
          <gl-link :href="currentLicenseInModal.url" target="_blank" rel="nofollow">{{
            currentLicenseInModal.url
          }}</gl-link>
        </div>
      </div>
      <div class="row gl-mt-3 gl-mb-3 js-license-packages">
        <label class="col-sm-3 text-right font-weight-bold">
          {{ s__('LicenseCompliance|Packages') }}:
        </label>
        <license-packages
          :packages="currentLicenseInModal.packages"
          class="col-sm-9 text-secondary"
        />
      </div>
    </slot>
    <template slot="footer">
      <button
        type="button"
        class="btn js-modal-cancel-action"
        data-dismiss="modal"
        @click="resetLicenseInModal"
      >
        {{ s__('Modal|Cancel') }}
      </button>
      <button
        v-if="canBlacklist"
        class="btn btn-remove btn-inverted js-modal-secondary-action"
        data-dismiss="modal"
        data-qa-selector="deny_license_button"
        @click="denyLicense(currentLicenseInModal)"
      >
        {{ s__('LicenseCompliance|Deny') }}
      </button>
      <button
        v-if="canApprove"
        type="button"
        class="btn btn-success js-modal-primary-action"
        data-dismiss="modal"
        data-qa-selector="approve_license_button"
        @click="allowLicense(currentLicenseInModal)"
      >
        {{ s__('LicenseCompliance|Allow') }}
      </button>
    </template>
  </gl-modal>
</template>
