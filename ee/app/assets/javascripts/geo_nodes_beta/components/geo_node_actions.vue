<script>
import { GlButton } from '@gitlab/ui';

export default {
  name: 'GeoNodeActions',
  components: {
    GlButton,
  },
  props: {
    primary: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
};
</script>

<template>
  <div>
    <gl-button class="gl-mr-3">{{ __('Edit') }}</gl-button>
    <gl-button variant="danger" category="secondary" :disabled="primary">{{
      __('Remove')
    }}</gl-button>
  </div>
</template>
