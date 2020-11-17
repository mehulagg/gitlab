<script>
import { GlButton } from '@gitlab/ui';

export default {
  components: {
    GlButton,
  },
};
</script>

<template>
  <div class="dropdown-title gl-display-flex gl-align-items-center">
    <span class="gl-ml-auto">{{ __('Assign epic') }}</span>
    <gl-button
      :aria-label="__('Close')"
      category="tertiary"
      class="dropdown-title-button dropdown-menu-close gl-ml-auto"
      size="small"
      icon="close"
    />
  </div>
</template>
