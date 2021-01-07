<script>
import { GlBadge } from '@gitlab/ui';
import {
  SCAN_TYPE,
  SCAN_TYPE_LABEL,
} from 'ee/security_configuration/dast_scanner_profiles/constants';
import ProfilesList from './dast_profiles_list.vue';

export default {
  components: {
    ProfilesList,
    GlBadge,
  },
  SCAN_TYPE,
  SCAN_TYPE_LABEL,
};
</script>
<template>
  <profiles-list v-bind="$attrs" v-on="$listeners">
    <template #cell(scanType)="{ value }">
      <gl-badge size="sm" :variant="value === $options.SCAN_TYPE.ACTIVE ? 'warning' : 'neutral'">
        {{ $options.SCAN_TYPE_LABEL[value].toLowerCase() }}
      </gl-badge>
    </template>
  </profiles-list>
</template>
