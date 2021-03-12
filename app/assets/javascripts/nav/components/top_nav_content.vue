<script>
import { GlButton } from '@gitlab/ui';

export default {
  components: {
    GlButton,
  },
  props: {
    primary: {
      type: Array,
      required: true,
    },
    secondary: {
      type: Array,
      required: true,
    },
  },
};
</script>

<template>
  <div class="gl-display-flex gl-align-items-stretch">
    <div class="gl-bg-gray-50 gl-w-20">
      <div class="gl-p-3 gl-display-flex gl-align-items-stretch gl-flex-direction-column">
        <gl-button v-for="btn in primary" :key="btn.id">{{ btn.title }}</gl-button>
      </div>
    </div>
    <div class="gl-w-20"></div>
  </div>
</template>
