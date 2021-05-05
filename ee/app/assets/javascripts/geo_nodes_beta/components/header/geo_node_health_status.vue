<script>
import { GlIcon, GlBadge } from '@gitlab/ui';
import { HEALTH_STATUS_UI, DEFAULT_HEALTH_STATUS } from 'ee/geo_nodes_beta/constants';

export default {
  components: {
    GlIcon,
    GlBadge,
  },
  props: {
    status: {
      type: String,
      required: false,
      default: DEFAULT_HEALTH_STATUS,
    },
  },
  computed: {
    statusUi() {
      return HEALTH_STATUS_UI[this.status.toLowerCase()];
    },
  },
};
</script>

<template>
  <gl-badge :variant="statusUi.variant">
    <gl-icon :name="statusUi.icon" />
    <span class="gl-ml-2 gl-font-weight-bold">{{ status }}</span>
  </gl-badge>
</template>
