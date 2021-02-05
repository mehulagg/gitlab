<script>
import { GlLink, GlSprintf, GlTable, GlAlert } from '@gitlab/ui';
import { s__, sprintf } from '~/locale';
import ManageSast from './manage_sast.vue';
import Upgrade from './upgrade.vue';
import { features } from './features_constants';
import {
  REPORT_TYPE_SAST,
  REPORT_TYPE_DAST,
  REPORT_TYPE_DEPENDENCY_SCANNING,
  REPORT_TYPE_CONTAINER_SCANNING,
  REPORT_TYPE_COVERAGE_FUZZING,
  REPORT_TYPE_LICENSE_COMPLIANCE,
} from './constants';

export default {
  components: {
    GlLink,
    GlSprintf,
    GlTable,
    GlAlert,
  },
  data: () => ({
    features,
    errorMessage: '',
  }),
  computed: {
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
          key: 'manage',
          label: s__('SecurityConfiguration|Manage'),
          thClass,
        },
      ];
    },
  },
  methods: {
    getFeatureDocumentationLinkLabel(item) {
      return sprintf(s__('SecurityConfiguration|Feature documentation for %{featureName}'), {
        featureName: item.name,
      });
    },
    onError(value) {
      this.errorMessage = value;
    },
    getComponentForItem(item) {
      const COMPONENTS = {
        [REPORT_TYPE_SAST]: ManageSast,
        [REPORT_TYPE_DAST]: Upgrade,
        [REPORT_TYPE_DEPENDENCY_SCANNING]: Upgrade,
        [REPORT_TYPE_CONTAINER_SCANNING]: Upgrade,
        [REPORT_TYPE_COVERAGE_FUZZING]: Upgrade,
        [REPORT_TYPE_LICENSE_COMPLIANCE]: Upgrade,
      };

      return COMPONENTS[item.type];
    },
  },
};
</script>

<template>
  <div>
    <gl-alert
      v-if="errorMessage"
      data-test-id="error-message"
      variant="danger"
      :dismissible="false"
    >
      {{ errorMessage }}
    </gl-alert>
    <gl-table ref="securityControlTable" :items="features" :fields="fields" stacked="md">
      <template #cell(feature)="{ item }">
        <span :data-test-id="item.id">
          <div class="gl-text-gray-900">
            {{ item.name }}
          </div>
          <div>
            {{ item.description }}
            <gl-link
              target="_blank"
              :href="item.link"
              :aria-label="getFeatureDocumentationLinkLabel(item)"
            >
              {{ s__('SecurityConfiguration|More information') }}
            </gl-link>
          </div>
        </span>
      </template>

      <template #cell(manage)="{ item }">
        <component :is="getComponentForItem(item)" @error="onError" />
      </template>
    </gl-table>
  </div>
</template>