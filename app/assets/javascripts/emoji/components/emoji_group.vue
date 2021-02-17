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
      <button
        v-for="emoji in emojis"
        :key="emoji"
        type="button"
        class="gl-border-0 gl-bg-transparent gl-p-0 gl-text-center emoji-picker-emoji"
      >
        <gl-emoji :data-name="emoji" />
      </button>
    </template>
  </div>
</template>
