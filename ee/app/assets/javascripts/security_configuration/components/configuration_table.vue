<script>
import { GlAlert, GlLink, GlTable } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';
import FeatureStatus from './feature_status.vue';
import ManageFeature from './manage_feature.vue';

const borderClasses = 'gl-border-b-1! gl-border-b-solid! gl-border-gray-100!';
const thClass = `gl-text-gray-900 gl-bg-transparent! ${borderClasses}`;

export default {
  components: {
    GlAlert,
    GlLink,
    GlTable,
    FeatureStatus,
    ManageFeature,
  },
  props: {
    features: {
      type: Array,
      required: true,
    },
    autoDevopsEnabled: {
      type: Boolean,
      required: false,
      default: false,
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
  },
  data() {
    return {
      errorMessage: '',
    };
  },
  methods: {
    getFeatureDocumentationLinkLabel(item) {
      return sprintf(this.$options.i18n.docsLinkLabel, {
        featureName: item.name,
      });
    },
    onError(value) {
      this.errorMessage = value;
    },
  },
  fields: [
    {
      key: 'description',
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
  ],
  i18n: {
    docsLinkLabel: s__('SecurityConfiguration|Feature documentation for %{featureName}'),
    docsLinkText: s__('SecurityConfiguration|More information'),
  },
};
</script>

<template>
  <div>
    <gl-alert v-if="errorMessage" variant="danger" :dismissible="false">
      {{ errorMessage }}
    </gl-alert>
    <gl-table
      :items="features"
      :fields="$options.fields"
      stacked="md"
      :tbody-tr-attr="{ 'data-testid': 'security-scanner-row' }"
    >
      <template #cell(description)="{ item }">
        <div class="gl-text-gray-900">{{ item.name }}</div>
        <div>
          {{ item.description }}
          <gl-link
            target="_blank"
            :href="item.helpPath"
            :aria-label="getFeatureDocumentationLinkLabel(item)"
          >
            {{ $options.i18n.docsLinkText }}
          </gl-link>
        </div>
      </template>

      <template #cell(status)="{ item }">
        <feature-status
          :feature="item"
          :gitlab-ci-present="gitlabCiPresent"
          :gitlab-ci-history-path="gitlabCiHistoryPath"
          :auto-devops-enabled="autoDevopsEnabled"
          :data-qa-selector="`${item.type}_status`"
        />
      </template>

      <template #cell(manage)="{ item }">
        <manage-feature :feature="item" @error="onError" />
      </template>
    </gl-table>
  </div>
</template>
