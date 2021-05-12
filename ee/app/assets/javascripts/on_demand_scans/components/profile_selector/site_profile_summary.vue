<script>
import {
  EXCLUDED_URLS_SEPARATOR,
  TARGET_TYPES,
} from 'ee/security_configuration/dast_site_profiles_form/constants';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import ProfileSelectorSummaryCell from './summary_cell.vue';

export default {
  name: 'DastSiteProfileSummary',
  components: {
    ProfileSelectorSummaryCell,
  },
  mixins: [glFeatureFlagsMixin()],
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
        :label="s__('DastProfiles|Target URL')"
        :value="profile.targetUrl"
      />
      <profile-selector-summary-cell
        v-if="glFeatures.securityDastSiteProfilesApiOption"
        :label="s__('DastProfiles|Site type')"
        :value="targetTypeValue"
      />
    </div>
    <template v-if="glFeatures.securityDastSiteProfilesAdditionalFields">
      <template v-if="profile.auth.enabled">
        <div class="row">
          <profile-selector-summary-cell
            :label="s__('DastProfiles|Authentication URL')"
            :value="profile.auth.url"
          />
        </div>
        <div class="row">
          <profile-selector-summary-cell
            :label="s__('DastProfiles|Username')"
            :value="profile.auth.username"
          />
          <profile-selector-summary-cell :label="s__('DastProfiles|Password')" value="••••••••" />
        </div>
        <div class="row">
          <profile-selector-summary-cell
            :label="s__('DastProfiles|Username form field')"
            :value="profile.auth.usernameField"
          />
          <profile-selector-summary-cell
            :label="s__('DastProfiles|Password form field')"
            :value="profile.auth.passwordField"
          />
        </div>
      </template>
      <div class="row">
        <profile-selector-summary-cell
          v-if="hasExcludedUrls"
          :label="s__('DastProfiles|Excluded URLs')"
          :value="profile.excludedUrls.join($options.EXCLUDED_URLS_SEPARATOR)"
        />
        <profile-selector-summary-cell
          v-if="profile.requestHeaders"
          :label="s__('DastProfiles|Request headers')"
          :value="__('[Redacted]')"
        />
      </div>
    </template>
  </div>
</template>
