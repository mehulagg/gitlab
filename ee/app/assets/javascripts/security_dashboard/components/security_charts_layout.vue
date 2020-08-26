<script>
import { s__ } from '~/locale';

export default {
  i18n: {
    title: s__('SecurityReports|Security Dashboard'),
  },

  emits: [],
};
</script>

<template functional>
  <div>
    <h2>{{ $options.i18n.title }}</h2>
    <div class="security-charts gl-display-flex gl-flex-wrap">
      <slot></slot>
    </div>
  </div>
</template>
