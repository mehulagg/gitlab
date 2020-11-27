<script>
import { uniqueId } from 'lodash';
import { GlButton, GlTooltipDirective } from '@gitlab/ui';
import ProfilesList from './dast_profiles_list.vue';
import DastSiteValidationModal from 'ee/security_configuration/dast_site_validation/components/dast_site_validation_modal.vue';
import {
  DAST_SITE_VALIDATION_STATUS,
  DAST_SITE_VALIDATION_STATUS_PROPS,
} from 'ee/security_configuration/dast_site_validation/constants';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';

const { PENDING, FAILED } = DAST_SITE_VALIDATION_STATUS;

export default {
  components: {
    GlButton,
    ProfilesList,
    DastSiteValidationModal,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    profiles: {
      type: Array,
      required: true,
    },
    fields: {
      type: Array,
      required: true,
    },
    errorMessage: {
      type: String,
      required: false,
      default: '',
    },
    errorDetails: {
      type: Array,
      required: false,
      default: () => [],
    },
    isLoading: {
      type: Boolean,
      required: false,
      default: false,
    },
    profilesPerPage: {
      type: Number,
      required: true,
    },
    hasMoreProfilesToLoad: {
      type: Boolean,
      required: false,
      default: false,
    },
    fullPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      validatingProfile: null,
    };
  },
  statuses: DAST_SITE_VALIDATION_STATUS_PROPS,
  computed: {},
  methods: {
    shouldShowValidationBtn(status) {
      return (
        this.glFeatures.securityOnDemandScansSiteValidation &&
        (status === PENDING || status === FAILED)
      );
    },
    shouldShowValidationStatus(status) {
      return this.glFeatures.securityOnDemandScansSiteValidation && status !== PENDING;
    },
    showValidationModal() {
      this.$refs['dast-site-validation-modal'].show();
    },
    setValidatingProfile(profile) {
      debugger;
      this.validatingProfile = profile;
      this.$nextTick(() => {
        this.showValidationModal();
      });
    },
  },
};
</script>
<template>
  <profiles-list
    data-testid="siteProfilesList"
    :error-message="errorMessage"
    :error-details="errorDetails"
    :has-more-profiles-to-load="hasMoreProfilesToLoad"
    :is-loading="isLoading"
    :profiles-per-page="profilesPerPage"
    :profiles="profiles"
    :fields="fields"
    :full-path="fullPath"
    @load-more-profiles="$emit('load-more-profiles')"
    @delete-profile="$emit('delete-profile')"
  >
    <template #actions="{profile}">
      <gl-button
        variant="info"
        category="secondary"
        size="small"
        @click="setValidatingProfile(profile)"
        >{{ s__('DastSiteValidation|Validate target site') }}</gl-button
      >
    </template>

    <dast-site-validation-modal
      v-if="validatingProfile"
      ref="dast-site-validation-modal"
      :full-path="fullPath"
      :target-url="validatingProfile.targetUrl"
    />
  </profiles-list>
</template>
