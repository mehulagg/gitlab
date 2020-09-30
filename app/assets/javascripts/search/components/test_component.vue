<script>
import { GlButton } from '@gitlab/ui';

export default {
  name: 'TestComponent',
  components: {
    GlButton,
  },
  data() {
    return {
      hidden: false,
    };
  },
};
</script>

<template>
  <div v-if="!hidden">
    <h1>{{ __('This is mounted from nested HAML') }}</h1>
    <gl-button @click="hidden = true">{{ __('Hide') }}</gl-button>
  </div>
</template>
