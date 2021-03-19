<script>
import ProfilesList from './dast_profiles_list.vue';
import ScanTypeBadge from './dast_scan_type_badge.vue';

export default {
  components: {
    ProfilesList,
    ScanTypeBadge,
  },
};
</script>
<template>
  <profiles-list v-bind="$attrs" v-on="$listeners">
    <template #cell(scanType)="{ value }">
      <scan-type-badge :scan-type="value" />
    </template>
  </profiles-list>
</template>
