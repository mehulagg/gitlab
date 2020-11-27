<script>
import { GlButton, GlIcon, GlTooltipDirective } from '@gitlab/ui';
import {
  DAST_SITE_VALIDATION_STATUS,
  DAST_SITE_VALIDATION_STATUS_PROPS,
} from 'ee/security_configuration/dast_site_validation/constants';
import DastSiteValidationModal from 'ee/security_configuration/dast_site_validation/components/dast_site_validation_modal.vue';
import dastSiteValidationsQuery from 'ee/security_configuration/dast_site_validation/graphql/dast_site_validations.query.graphql';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import ProfilesList from './dast_profiles_list.vue';
import { updateSiteProfilesStatuses } from '../graphql/cache_utils';

const { PENDING, INPROGRESS, FAILED, PASSED } = DAST_SITE_VALIDATION_STATUS;

export default {
  components: {
    GlButton,
    GlIcon,
    DastSiteValidationModal,
    ProfilesList,
  },
  apollo: {
    validation: {
      query: dastSiteValidationsQuery,
      manual: true,
      variables() {
        return {
          fullPath: this.fullPath,
          urls: this.urlsPendingValidation,
        };
      },
      pollInterval: 1500, // todo: make it a constant
      skip() {
        return !this.urlsPendingValidation.length;
      },
      result(response) {
        const {
          data: {
            validations: { edges },
          },
        } = response;
        const store = this.$apolloProvider.defaultClient;
        edges.forEach(({ node: { normalizedTargetUrl, status } }) => {
          updateSiteProfilesStatuses({
            fullPath: this.fullPath,
            normalizedTargetUrl,
            status,
            store,
          });
          if ([PASSED, FAILED].includes(status)) {
            this.urlsPendingValidation = this.urlsPendingValidation.filter(
              url => url !== normalizedTargetUrl,
            );
          }
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
      urlsPendingValidation: [],
    };
  },
  statuses: DAST_SITE_VALIDATION_STATUS_PROPS,
  watch: {
    profiles: {
      immediate: true,
      handler(profiles = []) {
        profiles.forEach(profile => {
          if (
            [PENDING, INPROGRESS].includes(profile.validationStatus) &&
            !this.urlsPendingValidation.includes(profile.targetUrl)
          ) {
            this.urlsPendingValidation.push(profile.targetUrl); // TODO: Use normalizedUrl here
          }
        });
      },
    },
  },
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
      this.validatingProfile = profile;
      this.$nextTick(() => {
        this.showValidationModal();
      });
    },
  },
};
</script>
<template>
  <profiles-list :full-path="fullPath" :profiles="profiles" v-bind="$attrs" v-on="$listeners">
    <template #cell(validationStatus)="{ value }">
      <template v-if="shouldShowValidationStatus(value)">
        <span :class="$options.statuses[value].cssClass">
          {{ $options.statuses[value].label }}
        </span>
        <gl-icon
          v-gl-tooltip
          name="question-o"
          class="gl-vertical-align-text-bottom gl-text-gray-300 gl-ml-2"
          :title="$options.statuses[value].tooltipText"
        />
      </template>
    </template>

    <template #actions="{ profile }">
      <gl-button
        v-if="shouldShowValidationBtn(profile.validationStatus)"
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
