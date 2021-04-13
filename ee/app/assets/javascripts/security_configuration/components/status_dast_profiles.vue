<script>
import { s__ } from '~/locale';

export default {
  i18n: {
    availableForOnDemand: s__('SecurityConfiguration|Available for on-demand DAST'),
  },
};
</script>

<template>
  <div>{{ $options.i18n.availableForOnDemand }}</div>
</template>
