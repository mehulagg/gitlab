<script>
import {
  EXCLUDED_URLS_SEPARATOR,
  TARGET_TYPES,
} from 'ee/security_configuration/dast_site_profiles_form/constants';
import { s__ } from '~/locale';
import ProfileSelectorSummaryCell from './summary_cell.vue';

export default {
  name: 'DastSiteProfileSummary',
  i18n: {
    targetUrl: s__('DastProfiles|Target URL'),
    targetType: s__('DastProfiles|Site type'),
    authUrl: s__('DastProfiles|Authentication URL'),
    username: s__('DastProfiles|Username'),
    password: s__('DastProfiles|Password'),
    usernameField: s__('DastProfiles|Username form field'),
    passwordField: s__('DastProfiles|Password form field'),
    excludedUrls: s__('DastProfiles|Excluded URLs'),
    requestHeaders: s__('DastProfiles|Request headers'),
  },
  components: {
    ProfileSelectorSummaryCell,
  },
  props: {
    profile: {
      type: Object,
      required: true,
    },
    hasConflict: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    hasExcludedUrls() {
      return this.profile.excludedUrls?.length > 0;
    },
    targetTypeValue() {
      return TARGET_TYPES[this.profile.targetType].text;
    },
  },
  EXCLUDED_URLS_SEPARATOR,
};
</script>

<template>
  <div>
    <div class="row">
      <profile-selector-summary-cell
        :class="{ 'gl-text-red-500': hasConflict }"
        :label="$options.i18n.targetUrl"
        :value="profile.targetUrl"
      />
      <profile-selector-summary-cell :label="$options.i18n.targetType" :value="targetTypeValue" />
    </div>
    <template v-if="profile.auth.enabled">
      <div class="row">
        <profile-selector-summary-cell :label="$options.i18n.authUrl" :value="profile.auth.url" />
      </div>
      <div class="row">
        <profile-selector-summary-cell
          :label="$options.i18n.username"
          :value="profile.auth.username"
        />
        <profile-selector-summary-cell :label="$options.i18n.password" value="••••••••" />
      </div>
      <div class="row">
        <profile-selector-summary-cell
          :label="$options.i18n.usernameField"
          :value="profile.auth.usernameField"
        />
        <profile-selector-summary-cell
          :label="$options.i18n.passwordField"
          :value="profile.auth.passwordField"
        />
      </div>
    </template>
    <div class="row">
      <profile-selector-summary-cell
        v-if="hasExcludedUrls"
        :label="$options.i18n.excludedUrls"
        :value="profile.excludedUrls.join($options.EXCLUDED_URLS_SEPARATOR)"
      />
      <profile-selector-summary-cell
        v-if="profile.requestHeaders"
        :label="$options.i18n.requestHeaders"
        :value="__('[Redacted]')"
      />
    </div>
  </div>
</template>
