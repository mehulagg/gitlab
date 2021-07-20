<script>
import { GlButton } from '@gitlab/ui';

export default {
  components: {
    GlButton,
  },
  props: {
    feature: {
      type: Object,
      required: true,
    },
  },
};
</script>

<template>
  <gl-button :href="feature.configuration_path" data-testid="manage-button">{{
    s__('SecurityConfiguration|Manage')
  }}</gl-button>
</template>
