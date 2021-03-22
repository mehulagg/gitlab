<script>
import { propsUnion } from '~/vue_shared/components/lib/utils/props_utils';
import { REPORT_TYPE_DAST_PROFILES } from '~/vue_shared/security_reports/constants';
import ManageDastProfiles from './manage_dast_profiles.vue';
import ManageGeneric from './manage_generic.vue';

const scannerComponentMap = {
  [REPORT_TYPE_DAST_PROFILES]: ManageDastProfiles,
};

export default {
  props: propsUnion([ManageGeneric, ...Object.values(scannerComponentMap)]),
  computed: {
    manageComponent() {
      return scannerComponentMap[this.feature.type] ?? ManageGeneric;
    },
  },
};
</script>

<template>
  <component :is="manageComponent" v-bind="$props" />
</template>
