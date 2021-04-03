<script>
import { GlIcon, GlLink, GlCard, GlFormCheckbox, GlSprintf } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { __ } from '~/locale';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';

export default {
  components: {
    GlIcon,
    GlLink,
    GlCard,
    GlFormCheckbox,
    GlSprintf,
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    autoFixEnabled: {
      type: Object,
      required: true,
    },
    autoFixHelpPath: {
      type: String,
      required: true,
    },
    autoFixUserPath: {
      type: String,
      required: true,
    },
    containerScanningHelpPath: {
      type: String,
      required: true,
    },
    dependencyScanningHelpPath: {
      type: String,
      required: true,
    },
    toggleAutofixSettingEndpoint: {
      type: String,
      required: true,
    },
    canToggleAutoFixSettings: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    // In this first iteration, the auto-fix settings is toggled for all features at once via a
    // single checkbox. The line below is a temporary workaround to initialize the setting's state
    // until we have distinct checkboxes for each auto-fixable feature.
    const autoFixEnabled = Object.values(this.autoFixEnabled).some((enabled) => enabled);
    return {
      autoFixEnabledLocal: autoFixEnabled,
      isChecked: autoFixEnabled,
      autoFixStatusLoading: false,
    };
  },
  computed: {
    hasAutoFixDisabled() {
      return !this.canToggleAutoFixSettings || this.autoFixStatusLoading;
    },
  },
  methods: {
    toggleAutoFix(enabled) {
      this.autoFixStatusLoading = true;
      return axios
        .post(this.toggleAutofixSettingEndpoint, {
          // When we have distinct checkboxes for each feature, we'll need to pass the feature being
          // toggled to the API. It's not required for now as all features are being toggled at once.
          feature: '',
          enabled,
        })
        .then(() => {
          this.autoFixEnabledLocal = enabled;
          this.isChecked = enabled;
        })
        .catch((e) => {
          Sentry.captureException(e);
          createFlash({
            message: __(
              'Something went wrong while toggling auto-fix settings, please try again later.',
            ),
          });
          this.isChecked = !enabled;
        })
        .finally(() => {
          this.autoFixStatusLoading = false;
        });
    },
  },
};
</script>

<template>
  <section>
    <h4 class="gl-h4 gl-my-5">
      {{ __('Suggested Solutions') }}
      <gl-link
        target="_blank"
        :href="autoFixHelpPath"
        :aria-label="__('Suggested solutions help link')"
      >
        <gl-icon name="question" />
      </gl-link>
    </h4>
    <gl-card>
      <gl-form-checkbox v-model="isChecked" :disabled="hasAutoFixDisabled" @change="toggleAutoFix">
        {{
          __('Automatically create merge requests for vulnerabilities that have fixes available.')
        }}
        <template #help>{{ __('Available for dependency and container scanning') }}</template>
      </gl-form-checkbox>
      <footer class="gl-bg-blue-100 gl-px-5 gl-py-3">
        <gl-sprintf
          :message="
            __(
              '%{containerScanningLinkStart}Container Scanning%{containerScanningLinkEnd} and/or %{dependencyScanningLinkStart}Dependency Scanning%{dependencyScanningLinkEnd} must be enabled. %{securityBotLinkStart}GitLab-Security-Bot%{securityBotLinkEnd} will be the author of the auto-created merge request. %{moreInfoLinkStart}More information%{moreInfoLinkEnd}.',
            )
          "
        >
          <template #containerScanningLink="{ content }">
            <gl-link :href="containerScanningHelpPath">{{ content }}</gl-link>
          </template>
          <template #dependencyScanningLink="{ content }">
            <gl-link :href="dependencyScanningHelpPath">{{ content }}</gl-link>
          </template>
          <template #securityBotLink="{ content }">
            <gl-link :href="autoFixUserPath">{{ content }}</gl-link>
          </template>
          <template #moreInfoLink="{ content }">
            <gl-link :href="autoFixHelpPath">{{ content }}</gl-link>
          </template>
        </gl-sprintf>
      </footer>
    </gl-card>
  </section>
</template>
