<script>
import { __ } from '~/locale';

export default {
  name: 'GeoNodes',
  props: {
    node: {
      type: Object,
      required: true,
    },
  },
  computed: {
    siteTitle() {
      return this.node.primary ? __('Primary site') : __('Secondary site');
    },
  },
};
</script>

<template>
  <div>
    <h4 class="gl-font-lg gl-my-5">{{ siteTitle }}</h4>
  </div>
</template>
