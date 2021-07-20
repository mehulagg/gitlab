<script>
import { propsUnion } from '~/vue_shared/components/lib/utils/props_utils';
import glFeatureFlagMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import ManageViaMr from '~/vue_shared/security_configuration/components/manage_via_mr.vue';
import {
  REPORT_TYPE_DAST_PROFILES,
  REPORT_TYPE_DEPENDENCY_SCANNING,
  REPORT_TYPE_SECRET_DETECTION,
} from '~/vue_shared/security_reports/constants';
import ManageDastProfiles from './manage_dast_profiles.vue';
import ManageGeneric from './manage_generic.vue';

const scannerComponentMap = {
  [REPORT_TYPE_DAST_PROFILES]: ManageDastProfiles,
  [REPORT_TYPE_DEPENDENCY_SCANNING]: ManageViaMr,
  [REPORT_TYPE_SECRET_DETECTION]: ManageViaMr,
};

export default {
  mixins: [glFeatureFlagMixin()],
  props: propsUnion([ManageGeneric, ...Object.values(scannerComponentMap)]),
  computed: {
    filteredScannerComponentMap() {
      const scannerComponentMapCopy = { ...scannerComponentMap };
      if (!this.glFeatures.secDependencyScanningUiEnable) {
        delete scannerComponentMapCopy[REPORT_TYPE_DEPENDENCY_SCANNING];
      }
      return scannerComponentMapCopy;
    },
    manageComponent() {
      return this.filteredScannerComponentMap[this.feature.type] ?? ManageGeneric;
    },
  },
};
</script>

<template>
  <component :is="manageComponent" v-bind="$props" @error="$emit('error', $event)" />
</template>
