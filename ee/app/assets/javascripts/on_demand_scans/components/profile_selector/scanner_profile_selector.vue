<script>
import { SCAN_TYPE_OPTIONS } from 'ee/security_configuration/dast_scanner_profiles/constants';
import ProfileSelector from './profile_selector.vue';
import SummaryCell from './summary_cell.vue';
import { __, s__ } from '~/locale';

export default {
  name: 'OnDemandScansScannerProfileSelector',
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
    scannerProfilesLibraryPath: {
      default: '',
    },
    newScannerProfilePath: {
      default: '',
    },
  },
  methods: {
    getScanModeText(scanType) {
      return SCAN_TYPE_OPTIONS.find(({ value }) => scanType === value)?.text;
    },
    getAjaxSpiderText(isEnabled) {
      return isEnabled ? __('On') : __('Off');
    },
    getDebugMessageText(isEnabled) {
      return isEnabled
        ? s__('DastProfiles|Show debug messages')
        : s__('DastProfiles|Hide debug messages');
    },
  },
};
</script>

<template>
  <profile-selector
    :library-path="scannerProfilesLibraryPath"
    :new-profile-path="newScannerProfilePath"
    :profiles="profiles.map(profile => ({ ...profile, dropdownLabel: profile.profileName }))"
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
    <template #new-profile>{{ s__('OnDemandScans|Create a new scanner profile') }}</template>
    <template #summary="{ profile }">
      <div class="row">
        <summary-cell
          :label="s__('DastProfiles|Scan mode')"
          :value="getScanModeText(profile.scanType)"
        />
      </div>
      <div class="row">
        <summary-cell
          :label="s__('DastProfiles|Spider timeout')"
          :value="n__('%d minute', '%d minutes', profile.spiderTimeout)"
        />
        <summary-cell
          :label="s__('DastProfiles|Target timeout')"
          :value="n__('%d second', '%d seconds', profile.targetTimeout)"
        />
      </div>
      <div class="row">
        <summary-cell
          :label="s__('DastProfiles|AJAX spider')"
          :value="getAjaxSpiderText(profile.useAjaxSpider)"
        />
        <summary-cell
          :label="s__('DastProfiles|Debug messages')"
          :value="getDebugMessageText(profile.showDebugMessages)"
        />
      </div>
    </template>
  </profile-selector>
</template>
