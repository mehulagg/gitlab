<script>
import { GlIcon } from '@gitlab/ui';

export default {
  components: {
    GlIcon,
  },
  props: {
    isApproved: {
      type: Boolean,
      required: true,
    },
  },
};
</script>

<template>
  <div>
    <gl-icon v-if="isApproved" name="mobile-issue-close" class="text-success" :size="16" />
    <div v-else class="square s16"></div>
  </div>
</template>
