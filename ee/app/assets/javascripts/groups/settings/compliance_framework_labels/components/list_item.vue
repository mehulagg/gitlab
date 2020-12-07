<script>
import { GlLabel } from '@gitlab/ui';

export default {
  components: {
    GlLabel,
  },
  props: {
    framework: {
      type: Object,
      required: true,
    },
  },
  computed: {
    isScoped() {
      return this.framework.name.includes('::');
    },
  },
};
</script>
<template>
  <div
    class="gl-display-flex gl-align-items-center gl-justify-content-space-between gl-inset-border-1-gray-100 gl-px-5 gl-p-6 gl-mb-4"
  >
    <div class="gl-w-quarter gl-mr-3 gl-flex-shrink-0">
      <gl-label
        target="#"
        :background-color="framework.color"
        :title="framework.name"
        :scoped="isScoped"
      />
    </div>
    <p class="gl-w-full gl-m-0!">{{ framework.description }}</p>
  </div>
</template>
