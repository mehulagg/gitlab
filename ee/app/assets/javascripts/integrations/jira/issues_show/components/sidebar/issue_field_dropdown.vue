<script>
import { GlDropdown, GlLoadingIcon } from '@gitlab/ui';

export default {
  components: {
    GlDropdown,
    GlLoadingIcon,
  },
  props: {
    text: {
      type: String,
      required: false,
      default: null,
    },
    title: {
      type: String,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      isLoading: true,
    };
  },
};
</script>

<template>
  <gl-dropdown :text="text" :header-text="title" block lazy>
    <div v-if="isLoading" class="gl-h-13">
      <gl-loading-icon size="md" />
    </div>
  </gl-dropdown>
</template>
