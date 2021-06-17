<script>
import { GlBadge, GlTooltipDirective } from '@gitlab/ui';
import { validateHexColor } from '~/lib/utils/color_utils';

export default {
  components: {
    GlBadge,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    color: {
      type: String,
      required: true,
      validator: (color) => validateHexColor(color),
    },
    description: {
      type: String,
      required: true,
    },
    name: {
      type: String,
      required: true,
    },
  },
};
</script>

<template>
  <gl-badge
    v-gl-tooltip
    class="gl-text-white!"
    variant="neutral"
    size="sm"
    :style="{ backgroundColor: color }"
    :title="description"
  >
    {{ name }}
  </gl-badge>
</template>
