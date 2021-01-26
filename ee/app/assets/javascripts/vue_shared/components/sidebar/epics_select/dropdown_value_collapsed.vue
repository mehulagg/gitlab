<script>
import { GlTooltipDirective, GlIcon } from '@gitlab/ui';

export default {
  components: {
    GlIcon,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    epic: {
      type: Object,
      required: true,
    },
  },
};
</script>

<template>
  <div
    v-gl-tooltip="{ boundary: 'viewport', placement: 'left' }"
    :title="epic.title"
    class="sidebar-collapsed-icon"
  >
    <gl-icon name="epic" />
    <span class="collapse-truncated-title mt-1">{{ epic.title }}</span>
  </div>
</template>
