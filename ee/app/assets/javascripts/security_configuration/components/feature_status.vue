<script>
import { propsUnion } from '~/vue_shared/components/lib/utils/props_utils';
import {
  REPORT_TYPE_SAST,
  REPORT_TYPE_DAST_PROFILES,
} from '~/vue_shared/security_reports/constants';
import StatusDastProfiles from './status_dast_profiles.vue';
import StatusGeneric from './status_generic.vue';
import StatusSast from './status_sast.vue';

const scannerComponentMap = {
  [REPORT_TYPE_SAST]: StatusSast,
  [REPORT_TYPE_DAST_PROFILES]: StatusDastProfiles,
};

export default {
  props: propsUnion([StatusGeneric, ...Object.values(scannerComponentMap)]),
  computed: {
    statusComponent() {
      return scannerComponentMap[this.feature.type] ?? StatusGeneric;
    },
  },
};
</script>

<template>
  <component :is="statusComponent" v-bind="$props" />
</template>
