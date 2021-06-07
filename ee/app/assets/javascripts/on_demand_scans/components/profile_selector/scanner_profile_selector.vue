<script>
import * as Sentry from '@sentry/browser';
import {
  ERROR_RUN_SCAN,
  ERROR_FETCH_SCANNER_PROFILES,
  ERROR_FETCH_SITE_PROFILES,
  ERROR_MESSAGES,
  SCANNER_PROFILES_QUERY,
  SITE_PROFILES_QUERY,
  TYPE_SITE_PROFILE,
  TYPE_SCANNER_PROFILE,
} from 'ee/on_demand_scans/settings';
import { SCAN_TYPE_LABEL } from 'ee/security_configuration/dast_scanner_profiles/constants';
import ProfileSelector from './profile_selector.vue';
import ScannerProfileSummary from './scanner_profile_summary.vue';

const createProfilesApolloOptions = (name, field, { fetchQuery, fetchError }) => ({
  query: fetchQuery,
  variables() {
    return {
      fullPath: this.fullPath,
    };
  },
  update(data) {
    const edges = data?.project?.[name]?.edges ?? [];
    if (edges.length === 1) {
      this[field] = edges[0].node.id;
    }
    return edges.map(({ node }) => node);
  },
  error(e) {
    Sentry.captureException(e);
    // this.showErrors(fetchError);
  },
});

export default {
  name: 'OnDemandScansScannerProfileSelector',
  components: {
    ProfileSelector,
    ScannerProfileSummary,
  },
  // inject: ['scannerProfilesLibraryPath', 'newScannerProfilePath', 'fullPath'],
  inject: {
    scannerProfilesLibraryPath: {
      default: '',
    },
    newScannerProfilePath: {
      default: '',
    },
    fullPath: {
      default: '',
    },
  },
  apollo: {
    scannerProfiles: createProfilesApolloOptions(
      'scannerProfiles',
      'selectedScannerProfileId',
      SCANNER_PROFILES_QUERY,
    ),
  },
  props: {
    profiles: {
      type: Array,
      required: false,
      default: () => [],
    },
    selectedProfile: {
      type: Object,
      required: false,
      default: null,
    },
    hasConflict: {
      type: Boolean,
      required: false,
      default: null,
    },
  },
  computed: {
    formattedProfiles() {
      return this.scannerProfiles?.map((profile) => {
        const addSuffix = (str) => `${str} (${SCAN_TYPE_LABEL[profile.scanType]})`;
        return {
          ...profile,
          dropdownLabel: addSuffix(profile.profileName),
        };
      });
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
      <scanner-profile-summary
        v-if="selectedProfile"
        :profile="selectedProfile"
        :has-conflict="hasConflict"
      />
    </template>
  </profile-selector>
</template>
