<script>
import { GlAlert, GlLink, GlSprintf } from '@gitlab/ui';
import { parseBoolean } from '~/lib/utils/common_utils';
import { s__, __ } from '~/locale';
import { scanners } from '~/security_configuration/components/constants';
import LocalStorageSync from '~/vue_shared/components/local_storage_sync.vue';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import AutoFixSettings from './auto_fix_settings.vue';
import ConfigurationTable from './configuration_table.vue';

export default {
  components: {
    GlAlert,
    GlLink,
    GlSprintf,
    AutoFixSettings,
    LocalStorageSync,
    ConfigurationTable,
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    autoDevopsEnabled: {
      type: Boolean,
      required: false,
      default: false,
    },
    autoDevopsHelpPagePath: {
      type: String,
      required: true,
    },
    latestPipelinePath: {
      type: String,
      required: false,
      default: '',
    },
    features: {
      type: Array,
      required: true,
    },
    autoFixSettingsProps: {
      type: Object,
      required: true,
    },
    gitlabCiPresent: {
      type: Boolean,
      required: false,
      default: false,
    },
    gitlabCiHistoryPath: {
      type: String,
      required: false,
      default: '',
    },
    autoDevopsPath: {
      type: String,
      required: false,
      default: '',
    },
    canEnableAutoDevops: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      autoDevopsAlertDismissed: 'false',
    };
  },
  computed: {
    devopsMessage() {
      return this.autoDevopsEnabled
        ? __(
            'Several security scans are enabled because %{linkStart}Auto DevOps%{linkEnd} is enabled on this project',
          )
        : __(
            `The status of the table below only applies to the default branch and is based on the %{linkStart}latest pipeline%{linkEnd}. Once you've enabled a scan for the default branch, any subsequent feature branch you create will include the scan.`,
          );
    },
    devopsUrl() {
      return this.autoDevopsEnabled ? this.autoDevopsHelpPagePath : this.latestPipelinePath;
    },
    shouldShowAutoDevopsAlert() {
      return Boolean(
        !parseBoolean(this.autoDevopsAlertDismissed) &&
          !this.autoDevopsEnabled &&
          !this.gitlabCiPresent &&
          this.canEnableAutoDevops,
      );
    },
    featuresForDisplay() {
      const featuresByType = this.features.reduce((acc, feature) => {
        acc[feature.type] = feature;
        return acc;
      }, {});

      return scanners.map((scanner) => {
        const feature = featuresByType[scanner.type] ?? {};

        return {
          ...feature,
          ...scanner,
        };
      });
    },
  },
  methods: {
    dismissAutoDevopsAlert() {
      this.autoDevopsAlertDismissed = 'true';
    },
  },
  autoDevopsAlertMessage: s__(`
    SecurityConfiguration|You can quickly enable all security scanning tools by
    enabling %{linkStart}Auto DevOps%{linkEnd}.`),
  autoDevopsAlertStorageKey: 'security_configuration_auto_devops_dismissed',
};
</script>

<template>
  <article>
    <header>
      <h4 class="my-3">{{ __('Security Configuration') }}</h4>
      <h5 class="gl-font-lg mt-5">{{ s__('SecurityConfiguration|Testing & Compliance') }}</h5>
      <p>
        <gl-sprintf :message="devopsMessage">
          <template #link="{ content }">
            <gl-link ref="pipelinesLink" :href="devopsUrl" target="_blank">{{ content }}</gl-link>
          </template>
        </gl-sprintf>
      </p>
    </header>

    <local-storage-sync
      v-model="autoDevopsAlertDismissed"
      :storage-key="$options.autoDevopsAlertStorageKey"
    />

    <gl-alert
      v-if="shouldShowAutoDevopsAlert"
      :title="__('Auto DevOps')"
      :primary-button-text="__('Enable Auto DevOps')"
      :primary-button-link="autoDevopsPath"
      class="gl-mb-5"
      @dismiss="dismissAutoDevopsAlert"
    >
      <gl-sprintf :message="$options.autoDevopsAlertMessage">
        <template #link="{ content }">
          <gl-link :href="autoDevopsHelpPagePath" v-text="content" />
        </template>
      </gl-sprintf>
    </gl-alert>

    <configuration-table
      :features="featuresForDisplay"
      :auto-devops-enabled="autoDevopsEnabled"
      :gitlab-ci-present="gitlabCiPresent"
      :gitlab-ci-history-path="gitlabCiHistoryPath"
    />

    <auto-fix-settings v-if="glFeatures.securityAutoFix" v-bind="autoFixSettingsProps" />
  </article>
</template>
