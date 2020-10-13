<script>
import { GlAlert, GlLink, GlSprintf, GlTable } from '@gitlab/ui';
import { parseBoolean } from '~/lib/utils/common_utils';
import { sprintf, s__, __ } from '~/locale';
import LocalStorageSync from '~/vue_shared/components/local_storage_sync.vue';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import AutoFixSettings from './auto_fix_settings.vue';
import FeatureStatus from './feature_status.vue';
import ManageFeature from './manage_feature.vue';

export default {
  components: {
    GlAlert,
    GlLink,
    GlSprintf,
    GlTable,
    AutoFixSettings,
    LocalStorageSync,
    FeatureStatus,
    ManageFeature,
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    autoDevopsEnabled: {
      type: Boolean,
      required: false,
      default: false,
    },
    helpPagePath: {
      type: String,
      required: true,
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
    // TODO: Remove as part of https://gitlab.com/gitlab-org/gitlab/-/issues/241377
    createSastMergeRequestPath: {
      type: String,
      required: true,
    },
  },
  data: () => ({
    autoDevopsAlertDismissed: 'false',
  }),
  computed: {
    devopsMessage() {
      return this.autoDevopsEnabled
        ? __(
            'All security scans are enabled because %{linkStart}Auto DevOps%{linkEnd} is enabled on this project',
          )
        : __(
            `The status of the table below only applies to the default branch and is based on the %{linkStart}latest pipeline%{linkEnd}. Once you've enabled a scan for the default branch, any subsequent feature branch you create will include the scan.`,
          );
    },
    devopsUrl() {
      return this.autoDevopsEnabled ? this.autoDevopsHelpPagePath : this.latestPipelinePath;
    },
    fields() {
      const borderClasses = 'gl-border-b-1! gl-border-b-solid! gl-border-gray-100!';
      const thClass = `gl-text-gray-900 gl-bg-transparent! ${borderClasses}`;

      return [
        {
          key: 'feature',
          label: s__('SecurityConfiguration|Security Control'),
          thClass,
        },
        {
          key: 'status',
          label: s__('SecurityConfiguration|Status'),
          thClass,
        },
        {
          key: 'manage',
          label: s__('SecurityConfiguration|Manage'),
          thClass,
        },
      ];
    },
    shouldShowAutoDevopsAlert() {
      return Boolean(
        !parseBoolean(this.autoDevopsAlertDismissed) &&
          !this.autoDevopsEnabled &&
          !this.gitlabCiPresent &&
          this.canEnableAutoDevops,
      );
    },
  },
  methods: {
    dismissAutoDevopsAlert() {
      this.autoDevopsAlertDismissed = 'true';
    },
    getFeatureDocumentationLinkLabel(item) {
      return sprintf(s__('SecurityConfiguration|Feature documentation for %{featureName}'), {
        featureName: item.name,
      });
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

    <gl-table ref="securityControlTable" :items="features" :fields="fields" stacked="md">
      <template #cell(feature)="{ item }">
        <div class="gl-text-gray-900">{{ item.name }}</div>
        <div>
          {{ item.description }}
          <gl-link
            target="_blank"
            :href="item.link"
            :aria-label="getFeatureDocumentationLinkLabel(item)"
            data-testid="docsLink"
          >
            {{ s__('SecurityConfiguration|More information') }}
          </gl-link>
        </div>
      </template>

      <template #cell(status)="{ item }">
        <feature-status
          :feature="item"
          :gitlab-ci-present="gitlabCiPresent"
          :gitlab-ci-history-path="gitlabCiHistoryPath"
        />
      </template>

      <template #cell(manage)="{ item }">
        <manage-feature
          :feature="item"
          :auto-devops-enabled="autoDevopsEnabled"
          :create-sast-merge-request-path="createSastMergeRequestPath"
        />
      </template>
    </gl-table>
    <auto-fix-settings v-if="glFeatures.securityAutoFix" v-bind="autoFixSettingsProps" />
  </article>
</template>
