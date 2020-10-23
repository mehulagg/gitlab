<script>
import { __ } from '~/locale';

export default {
  name: 'DevopsAdoptionApp',
  i18n: {
    description: __(
      'Feature adoption is based on usage over the last 30 days. Last updated: yyyy-mm-dd-hh:mm',
    ),
  },
};
</script>
<template>
  <p class="gl-mt-4">
    {{ $options.i18n.description }}
  </p>
</template>
