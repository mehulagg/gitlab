<script>
import { GlButton } from '@gitlab/ui';

export default {
  components: {
    GlButton,
  },

  emits: [],
};
</script>

<template>
  <div class="dropdown-title">
    <span>{{ __('Assign epic') }}</span>
    <gl-button
      :aria-label="__('Close')"
      category="tertiary"
      class="dropdown-title-button dropdown-menu-close"
      icon="close"
    />
  </div>
</template>
