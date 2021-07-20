<script>
import { GlButton, GlIcon, GlTooltipDirective, GlLink } from '@gitlab/ui';
import DastSiteValidationModal from 'ee/security_configuration/dast_site_validation/components/dast_site_validation_modal.vue';
import DastSiteValidationRevokeModal from 'ee/security_configuration/dast_site_validation/components/dast_site_validation_revoke_modal.vue';
import {
  DAST_SITE_VALIDATION_STATUS,
  DAST_SITE_VALIDATION_STATUS_PROPS,
  DAST_SITE_VALIDATION_POLLING_INTERVAL,
  DAST_SITE_VALIDATION_MODAL_ID,
  DAST_SITE_VALIDATION_REVOKE_MODAL_ID,
} from 'ee/security_configuration/dast_site_validation/constants';
import dastSiteValidationsQuery from 'ee/security_configuration/dast_site_validation/graphql/dast_site_validations.query.graphql';
import { fetchPolicies } from '~/lib/graphql';
import { s__ } from '~/locale';
import { updateSiteProfilesStatuses } from '../graphql/cache_utils';
import ProfilesList from './dast_profiles_list.vue';

const { NONE, PENDING, INPROGRESS, FAILED, PASSED } = DAST_SITE_VALIDATION_STATUS;

export default {
  components: {
    GlButton,
    GlIcon,
    GlLink,
    DastSiteValidationModal,
    DastSiteValidationRevokeModal,
    ProfilesList,
  },
  apollo: {
    validations: {
      query: dastSiteValidationsQuery,
      fetchPolicy: fetchPolicies.NO_CACHE,
      manual: true,
      variables() {
        return {
          fullPath: this.fullPath,
          urls: this.urlsPendingValidation,
        };
      },
      pollInterval: DAST_SITE_VALIDATION_POLLING_INTERVAL,
      skip() {
        return !this.urlsPendingValidation.length;
      },
      result({
        data: {
          project: {
            validations: { nodes = [] },
          },
        },
      }) {
        nodes.forEach(({ normalizedTargetUrl, status }) => {
          this.updateSiteProfilesStatuses(normalizedTargetUrl, status);
        });
      },
    },
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    fullPath: {
      type: String,
      required: true,
    },
    profiles: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      validatingProfile: null,
      revokeValidationProfile: null,
    };
  },
  statuses: DAST_SITE_VALIDATION_STATUS_PROPS,
  DAST_SITE_VALIDATION_MODAL_ID,
  DAST_SITE_VALIDATION_REVOKE_MODAL_ID,
  VALIDATION_STATUS: DAST_SITE_VALIDATION_STATUS,
  computed: {
    urlsPendingValidation() {
      return this.profiles.reduce((acc, { validationStatus, normalizedTargetUrl }) => {
        if (this.isPendingValidation(validationStatus) && !acc.includes(normalizedTargetUrl)) {
          return [...acc, normalizedTargetUrl];
        }
        return acc;
      }, []);
    },
  },
  methods: {
    updateSiteProfilesStatuses(normalizedTargetUrl, status) {
      updateSiteProfilesStatuses({
        fullPath: this.fullPath,
        normalizedTargetUrl,
        status,
        store: this.$apollo.getClient(),
      });
    },
    isPendingValidation(status) {
      return [PENDING, INPROGRESS].includes(status);
    },
    canValidateProfile(status) {
      return [NONE, FAILED].includes(status);
    },
    validateBtnLabel(status) {
      return status === FAILED
        ? s__('DastSiteValidation|Retry validation')
        : s__('DastSiteValidation|Validate');
    },
    shouldShowValidationStatus(status) {
      return status !== NONE;
    },
    hasValidationPassed(status) {
      return status === PASSED;
    },
    showModal(modalId) {
      this.$refs[modalId].show();
    },
    setValidatingProfile(profile) {
      this.validatingProfile = profile;
      this.$nextTick(() => {
        this.showModal(DAST_SITE_VALIDATION_MODAL_ID);
      });
    },
    setRevokeValidationProfile(profile) {
      this.revokeValidationProfile = profile;
      this.$nextTick(() => {
        this.showModal(DAST_SITE_VALIDATION_REVOKE_MODAL_ID);
      });
    },
    similarProfilesCount(profile) {
      // Ideally checking the normalized URL should be sufficient,
      // but checking the validation status is necessary to avoid anomalies
      // until https://gitlab.com/gitlab-org/gitlab/-/issues/300740 is resolved
      return (
        this.profiles.filter(
          ({ normalizedTargetUrl, validationStatus }) =>
            normalizedTargetUrl === profile.normalizedTargetUrl &&
            validationStatus === profile.validationStatus,
        ).length - 1
      );
    },
  },
};
</script>
<template>
  <profiles-list :full-path="fullPath" :profiles="profiles" v-bind="$attrs" v-on="$listeners">
    <template #head(validationStatus)="{ label }">
      {{ label }}
      <gl-link
        href="https://docs.gitlab.com/ee/user/application_security/dast/#site-profile-validation"
        target="_blank"
        class="gl-text-gray-300 gl-ml-2"
      >
        <gl-icon name="question-o" />
      </gl-link>
    </template>
    <template #cell(validationStatus)="{ value }">
      <template v-if="shouldShowValidationStatus(value)">
        <gl-icon v-gl-tooltip v-bind="$options.statuses[value]" :size="12" class="gl-mr-3" /><span
          >{{ $options.statuses[value].labelText }}</span
        >
      </template>
    </template>

    <template #actions="{ profile }">
      <gl-button
        v-if="!hasValidationPassed(profile.validationStatus)"
        :disabled="!canValidateProfile(profile.validationStatus)"
        variant="confirm"
        category="tertiary"
        size="small"
        @click="setValidatingProfile(profile)"
        >{{ validateBtnLabel(profile.validationStatus) }}</gl-button
      >
      <gl-button
        v-else
        variant="confirm"
        category="tertiary"
        size="small"
        @click="setRevokeValidationProfile(profile)"
        >{{ s__('DastSiteValidation|Revoke validation') }}</gl-button
      >
    </template>

    <dast-site-validation-modal
      v-if="validatingProfile"
      :ref="$options.DAST_SITE_VALIDATION_MODAL_ID"
      :full-path="fullPath"
      :target-url="validatingProfile.targetUrl"
      @primary="
        updateSiteProfilesStatuses(
          validatingProfile.normalizedTargetUrl,
          $options.VALIDATION_STATUS.PENDING,
        )
      "
    />

    <dast-site-validation-revoke-modal
      v-if="revokeValidationProfile"
      :ref="$options.DAST_SITE_VALIDATION_REVOKE_MODAL_ID"
      :full-path="fullPath"
      :target-url="revokeValidationProfile.targetUrl"
      :normalized-target-url="revokeValidationProfile.normalizedTargetUrl"
      :profile-count="similarProfilesCount(revokeValidationProfile)"
      @revoke="
        updateSiteProfilesStatuses(
          revokeValidationProfile.normalizedTargetUrl,
          $options.VALIDATION_STATUS.NONE,
        )
      "
    />
  </profiles-list>
</template>
