<script>
import { __ } from '~/locale';
import GeoNodeHeader from './geo_node_header.vue';

export default {
  name: 'GeoNodes',
  components: {
    GeoNodeHeader,
  },
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
    <geo-node-header :node="node" />
  </div>
</template>
