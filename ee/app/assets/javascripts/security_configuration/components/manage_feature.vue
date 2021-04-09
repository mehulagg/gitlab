<script>
import { propsUnion } from '~/vue_shared/components/lib/utils/props_utils';
import glFeatureFlagMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import ManageViaMr from '~/vue_shared/security_configuration/components/manage_via_mr.vue';
import {
  REPORT_TYPE_DAST_PROFILES,
  REPORT_TYPE_DEPENDENCY_SCANNING,
  REPORT_TYPE_SECRET_DETECTION,
} from '~/vue_shared/security_reports/constants';
import { featureToMutationMap } from './constants';
import ManageDastProfiles from './manage_dast_profiles.vue';
import ManageGeneric from './manage_generic.vue';

const scannerComponentMap = {
  [REPORT_TYPE_DAST_PROFILES]: { component: ManageDastProfiles },
  [REPORT_TYPE_DEPENDENCY_SCANNING]: {
    component: ManageViaMr,
    mutation: {
      mutation: featureToMutationMap[REPORT_TYPE_DEPENDENCY_SCANNING].mutation,
    },
  },
  [REPORT_TYPE_SECRET_DETECTION]: {
    component: ManageViaMr,
    mutation: {
      mutation: featureToMutationMap[REPORT_TYPE_SECRET_DETECTION].mutation,
    },
  },
};

export default {
  mixins: [glFeatureFlagMixin()],
  inject: {
    projectPath: {
      from: 'projectPath',
      default: '',
    },
  },
  props: propsUnion([ManageGeneric, ...Object.values(scannerComponentMap)]),
  computed: {
    filteredScannerComponentMap() {
      const scannerComponentMapCopy = { ...scannerComponentMap };
      if (!this.glFeatures.secDependencyScanningUiEnable) {
        delete scannerComponentMapCopy[REPORT_TYPE_DEPENDENCY_SCANNING];
      }
      if (!this.glFeatures.secSecretDetectionUiEnable) {
        delete scannerComponentMapCopy[REPORT_TYPE_SECRET_DETECTION];
      }
      return scannerComponentMapCopy;
    },
    manageComponent() {
      return this.filteredScannerComponentMap[this.feature.type]?.component ?? ManageGeneric;
    },
    manageMutation() {
      return this.filteredScannerComponentMap[this.feature.type]?.mutation ?? {};
    },
  },
  methods: {
    getScannerSpecificProps() {
      if (
        this.feature.type === REPORT_TYPE_DEPENDENCY_SCANNING ||
        this.feature.type === REPORT_TYPE_SECRET_DETECTION
      ) {
        return {
          ...this.$props,
          mutationId: featureToMutationMap[this.feature.type].mutationId,
          mutation: {
            ...this.manageMutation,
            ...featureToMutationMap[this.feature.type].getMutationPayload(this.projectPath),
          },
        };
      }
      return this.$props;
    },
  },
};
</script>

<template>
  <component
    :is="manageComponent"
    v-bind="getScannerSpecificProps()"
    @error="$emit('error', $event)"
  />
</template>
