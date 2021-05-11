<script>
import { GlCard, GlIcon } from '@gitlab/ui';

export default {
  components: {
    GlCard,
    GlIcon,
  },
  props: {
    policy: {
      type: Object,
      required: true,
    },
  },
};
</script>
<template>
  <gl-card>
    <template #header
      ><b>{{ policy.title }}</b></template
    >
    <p>{{ policy.description }}</p>
    <gl-card>
      <div class="gl-display-flex gl-flex-direction-row gl-align-items-center">
        <gl-icon name="clock" />
        <span class="gl-ml-3">{{ __('IF alert is not acknowledged ...') }}</span>
      </div>
    </gl-card>
  </gl-card>
</template>
