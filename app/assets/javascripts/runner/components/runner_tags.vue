<script>
import { GlBadge } from '@gitlab/ui';

export default {
  components: {
    GlBadge,
  },
  props: {
    tagList: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
};
</script>
<template>
  <div>
    <gl-badge v-for="tag in tagList" :key="tag" variant="info">
      {{ tag }}
    </gl-badge>
  </div>
</template>
