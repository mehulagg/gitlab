<script>
import { GlAlert, GlLoadingIcon } from '@gitlab/ui';

export default {
  components: {
    GlAlert,
    GlLoadingIcon,
  },
  props: {
    error: {
      type: String,
      required: false,
      default: null,
    },
    loading: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
};
</script>

<template>
  <div class="gl-border-t-1 gl-border-t-solid gl-border-t-gray-100 gl-pt-5">
    <gl-alert v-if="error" class="gl-mb-5" variant="danger" :dismissible="false">
      {{ error }}
    </gl-alert>
    <gl-loading-icon v-if="loading" size="lg" />

    <slot v-else></slot>
  </div>
</template>
