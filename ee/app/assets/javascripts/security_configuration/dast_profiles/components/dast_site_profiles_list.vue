<script>
import { GlButton, GlIcon, GlTooltipDirective, GlBadge, GlLink } from '@gitlab/ui';
import {
  DAST_SITE_VALIDATION_STATUS,
  DAST_SITE_VALIDATION_STATUS_PROPS,
  DAST_SITE_VALIDATION_POLLING_INTERVAL,
} from 'ee/security_configuration/dast_site_validation/constants';
import DastSiteValidationModal from 'ee/security_configuration/dast_site_validation/components/dast_site_validation_modal.vue';
import dastSiteValidationsQuery from 'ee/security_configuration/dast_site_validation/graphql/dast_site_validations.query.graphql';
import { updateSiteProfilesStatuses } from '../graphql/cache_utils';
import ProfilesList from './dast_profiles_list.vue';
import { s__ } from '~/locale';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { fetchPolicies } from '~/lib/graphql';

const { NONE, PENDING, INPROGRESS, FAILED } = DAST_SITE_VALIDATION_STATUS;

export default {
  components: {
    GlButton,
    GlIcon,
    GlBadge,
    GlLink,
    DastSiteValidationModal,
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
        return (
          !this.glFeatures.securityOnDemandScansSiteValidation || !this.urlsPendingValidation.length
        );
      },
      result({
        data: {
          project: {
            validations: { nodes = [] },
          },
        },
      }) {
        const store = this.$apollo.getClient();
        nodes.forEach(({ normalizedTargetUrl, status }) => {
          updateSiteProfilesStatuses({
            fullPath: this.fullPath,
            normalizedTargetUrl,
            status,
            store,
          });
        });
      },
    },
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [glFeatureFlagsMixin()],
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
    };
  },
  statuses: DAST_SITE_VALIDATION_STATUS_PROPS,
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
    isPendingValidation(status) {
      return [PENDING, INPROGRESS].includes(status);
    },
    shouldShowValidateBtn(status) {
      return [NONE, FAILED].includes(status);
    },
    validateBtnLabel(status) {
      return status === FAILED
        ? s__('DastSiteValidation|Retry validation')
        : s__('DastSiteValidation|Validate');
    },
    shouldShowValidationStatus(status) {
      return this.glFeatures.securityOnDemandScansSiteValidation && status !== NONE;
    },
    showValidationModal() {
      this.$refs['dast-site-validation-modal'].show();
    },
    setValidatingProfile(profile) {
      this.validatingProfile = profile;
      this.$nextTick(() => {
        this.showValidationModal();
      });
    },
    startValidatingProfile({ normalizedTargetUrl }) {
      updateSiteProfilesStatuses({
        fullPath: this.fullPath,
        normalizedTargetUrl,
        status: PENDING,
        store: this.$apollo.getClient(),
      });
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
        <gl-badge
          v-gl-tooltip
          size="sm"
          :variant="$options.statuses[value].badgeVariant"
          :title="$options.statuses[value].tooltipText"
        >
          <gl-icon :size="12" class="gl-mr-2" :name="$options.statuses[value].badgeIcon" />
          {{ $options.statuses[value].label }}</gl-badge
        >
      </template>
    </template>

    <template #actions="{ profile }">
      <gl-button
        v-if="glFeatures.securityOnDemandScansSiteValidation"
        :disabled="!shouldShowValidateBtn(profile.validationStatus)"
        variant="info"
        category="tertiary"
        size="small"
        @click="setValidatingProfile(profile)"
        >{{ validateBtnLabel(profile.validationStatus) }}</gl-button
      >
    </template>

    <dast-site-validation-modal
      v-if="validatingProfile"
      ref="dast-site-validation-modal"
      :full-path="fullPath"
      :target-url="validatingProfile.targetUrl"
      @primary="startValidatingProfile(validatingProfile)"
    />
  </profiles-list>
</template>
