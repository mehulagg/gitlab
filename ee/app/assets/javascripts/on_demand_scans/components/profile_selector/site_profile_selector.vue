<script>
import { DAST_SITE_VALIDATION_STATUS } from 'ee/security_configuration/dast_site_validation/constants';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import ProfileSelector from './profile_selector.vue';
import { s__ } from '~/locale';

export default {
  name: 'OnDemandScansSiteProfileSelector',
  components: {
    ProfileSelector,
  },
  mixins: [glFeatureFlagsMixin()],
  inject: {
    siteProfilesLibraryPath: {
      default: '',
    },
    newSiteProfilePath: {
      default: '',
    },
  },
  props: {
    profiles: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  computed: {
    formattedProfiles() {
      return this.profiles.map((profile) => {
        const isValidated = profile.validationStatus === DAST_SITE_VALIDATION_STATUS.PASSED;
        const suffix = isValidated
          ? s__('DastProfiles|Validated')
          : s__('DastProfiles|Not Validated');
        const addSuffix = (str) =>
          this.glFeatures.securityOnDemandScansSiteValidation ? `${str} (${suffix})` : str;
        return {
          ...profile,
          dropdownLabel: addSuffix(`${profile.profileName}: ${profile.targetUrl}`),
        };
      });
    },
  },
};
</script>

<template>
  <profile-selector
    :library-path="siteProfilesLibraryPath"
    :new-profile-path="newSiteProfilePath"
    :profiles="formattedProfiles"
    v-bind="$attrs"
    v-on="$listeners"
  >
    <template #title>{{ s__('OnDemandScans|Site profile') }}</template>
    <template #label>{{ s__('OnDemandScans|Use existing site profile') }}</template>
    <template #no-profiles>{{
      s__(
        'OnDemandScans|No profile yet. In order to create a new scan, you need to have at least one completed site profile.',
      )
    }}</template>
    <template #new-profile>{{ s__('OnDemandScans|Create new site profile') }}</template>
    <template #manage-profile>{{ s__('OnDemandScans|Manage site profiles') }}</template>
    <template #summary>
      <slot name="summary"></slot>
    </template>
  </profile-selector>
</template>
