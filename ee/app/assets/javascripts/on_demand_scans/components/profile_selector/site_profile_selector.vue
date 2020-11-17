<script>
import ProfileSelector from './profile_selector.vue';
import SummaryCell from './summary_cell.vue';

export default {
  name: 'OnDemandScansSiteProfileSelector',
  components: {
    ProfileSelector,
    SummaryCell,
  },
  props: {
    profiles: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  inject: {
    siteProfilesLibraryPath: {
      default: '',
    },
    newSiteProfilePath: {
      default: '',
    },
  },
};
</script>

<template>
  <profile-selector
    :library-path="siteProfilesLibraryPath"
    :new-profile-path="newSiteProfilePath"
    :profiles="
      profiles.map(profile => ({
        ...profile,
        dropdownLabel: `${profile.profileName}: ${profile.targetUrl}`,
      }))
    "
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
    <template #new-profile>{{ s__('OnDemandScans|Create a new site profile') }}</template>
    <template #summary="{ profile }">
      <div class="row">
        <summary-cell :label="s__('DastProfiles|Target URL')" :value="profile.targetUrl" />
      </div>
    </template>
  </profile-selector>
</template>
