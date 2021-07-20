<script>
import { GlLabel } from '@gitlab/ui';
import { validateHexColor } from '~/lib/utils/color_utils';

export default {
  components: {
    GlLabel,
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
  <gl-label size="sm" :background-color="color" :title="name" :description="description" />
</template>
