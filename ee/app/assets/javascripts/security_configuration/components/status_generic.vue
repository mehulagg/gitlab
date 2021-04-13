<script>
import { s__ } from '~/locale';

export default {
  props: {
    feature: {
      type: Object,
      required: true,
    },
    autoDevopsEnabled: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    status() {
      if (this.feature.configured) {
        return this.autoDevopsEnabled
          ? this.$options.i18n.enabledWithAutoDevOps
          : this.$options.i18n.enabled;
      }

      return this.$options.i18n.notEnabled;
    },
  },
  i18n: {
    enabled: s__('SecurityConfiguration|Enabled'),
    enabledWithAutoDevOps: s__('SecurityConfiguration|Enabled with Auto DevOps'),
    notEnabled: s__('SecurityConfiguration|Not enabled'),
  },
};
</script>

<template>
  <div>{{ status }}</div>
</template>
