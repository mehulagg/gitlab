<script>
import { GlIcon, GlBadge } from '@gitlab/ui';
import { HEALTH_STATUS_UI } from 'ee/geo_nodes/constants';

export default {
  components: {
    GlIcon,
    GlBadge,
  },
  props: {
    status: {
      type: String,
      required: false,
      default: null,
    },
  },
  computed: {
    statusUi() {
      return this.status ? HEALTH_STATUS_UI[this.status.toLowerCase()] : HEALTH_STATUS_UI.unknown;
    },
  },
};
</script>

<template>
  <gl-badge :variant="statusUi.variant">
    <gl-icon :name="statusUi.icon" />
    <span class="gl-ml-2 gl-font-weight-bold">{{ statusUi.text }}</span>
  </gl-badge>
</template>
