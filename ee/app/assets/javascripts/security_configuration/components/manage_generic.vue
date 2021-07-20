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
  computed: {
    canConfigure() {
      return Boolean(this.feature.configuration_path && this.feature.configured);
    },
    canEnable() {
      return Boolean(this.feature.configuration_path && !this.feature.configured);
    },
  },
};
</script>

<template>
  <gl-button
    v-if="canConfigure"
    :href="feature.configuration_path"
    data-testid="configure-button"
    >{{ s__('SecurityConfiguration|Configure') }}</gl-button
  >

  <gl-button
    v-else-if="canEnable"
    variant="confirm"
    category="primary"
    :href="feature.configuration_path"
    data-testid="enable-button"
    :data-qa-selector="`${feature.type}_enable_button`"
    >{{ s__('SecurityConfiguration|Enable') }}</gl-button
  >
</template>
