<script>
import { s__ } from '~/locale';

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
      return this.node.primary ? s__('Geo|Primary site') : s__('Geo|Secondary site');
    },
  },
};
</script>

<template>
  <div>
    <h4 class="gl-font-lg gl-my-5">{{ siteTitle }}</h4>
  </div>
</template>
