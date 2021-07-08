<script>
import { GlButton, GlModal } from '@gitlab/ui';

export default {
  name: 'ExtendTrialButton',
  components: {
    GlButton,
    GlModal,
  },
  props: {
    extend: {
      type: Boolean,
      default: true,
    },
  },
};
</script>

<template>
  <div>
    <gl-button category="secondary" variant="info"> </gl-button>
    <gl-modal />
  </div>
</template>
