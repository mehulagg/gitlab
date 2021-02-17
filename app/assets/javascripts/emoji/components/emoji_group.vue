<script>
import { GlIntersectionObserver } from '@gitlab/ui';

export default {
  components: {
    GlIntersectionObserver,
  },
  props: {
    emojis: {
      type: Array,
      required: true,
    },
    renderGroup: {
      type: Boolean,
      required: true,
    },
  },
};
</script>

<template>
  <div class="gl-display-flex gl-flex-wrap">
    <template v-if="renderGroup">
      <span v-for="emoji in emojis" :key="emoji" class="gl-text-center emoji-picker-emoji">
        <gl-emoji :data-name="emoji" />
      </span>
    </template>
  </div>
</template>
