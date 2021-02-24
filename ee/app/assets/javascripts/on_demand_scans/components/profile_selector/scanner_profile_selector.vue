<script>
import { SCAN_TYPE_LABEL } from 'ee/security_configuration/dast_scanner_profiles/constants';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import ProfileSelector from './profile_selector.vue';
import DastScannerProfileForm from 'ee/security_configuration/dast_scanner_profiles/components/dast_scanner_profile_form.vue';

export default {
  name: 'OnDemandScansScannerProfileSelector',
  components: {
    ProfileSelector,
    DastScannerProfileForm,
  },
  mixins: [glFeatureFlagsMixin()],
  inject: {
    scannerProfilesLibraryPath: {
      default: '',
    },
    newScannerProfilePath: {
      default: '',
    },
    projectPath: {
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
        const addSuffix = (str) => `${str} (${SCAN_TYPE_LABEL[profile.scanType]})`;
        return {
          ...profile,
          dropdownLabel: addSuffix(profile.profileName),
        };
      });
    },
    // Todo: To be removed later
    onDemandScansPath() {
      return this.projectPath + '-/on_demand_scans/new';
    },
  },
};
</script>

<template>
  <profile-selector
    :library-path="scannerProfilesLibraryPath"
    :new-profile-path="newScannerProfilePath"
    :profiles="formattedProfiles"
    v-bind="$attrs"
    v-on="$listeners"
  >
    <template #title>{{ s__('OnDemandScans|Scanner profile') }}</template>
    <template #label>{{ s__('OnDemandScans|Use existing scanner profile') }}</template>
    <template #no-profiles>{{
      s__(
        'OnDemandScans|No profile yet. In order to create a new scan, you need to have at least one completed scanner profile.',
      )
    }}</template>
    <template #new-profile>{{ s__('OnDemandScans|Create new scanner profile') }}</template>
    <template #manage-profile>{{ s__('OnDemandScans|Manage scanner profiles') }}</template>
    <template #summary>
      <slot name="summary"></slot>
    </template>
    <template #profile-form="{ profile, onSuccess, onCancel }">
      <dast-scanner-profile-form
        :project-full-path="projectPath"
        :profile="profile"
        @success="onSuccess"
        @cancel="onCancel"
      ></dast-scanner-profile-form>
    </template>
  </profile-selector>
</template>
