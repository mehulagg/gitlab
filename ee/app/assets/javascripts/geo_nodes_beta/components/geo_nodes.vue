<script>
import { s__ } from '~/locale';
import GeoNodeDetails from './details/geo_node_details.vue';
import GeoNodeHeader from './header/geo_node_header.vue';

export default {
  name: 'GeoNodes',
  components: {
    GeoNodeHeader,
    GeoNodeDetails,
  },
  props: {
    node: {
      type: Object,
      required: true,
      validator: (value) =>
        ['id', 'name', 'geoNodeId', 'url', 'healthStatus'].every((prop) => value[prop]),
    },
  },
  data() {
    return {
      collapsed: false,
    };
  },
  computed: {
    siteTitle() {
      return this.node.primary ? s__('Geo|Primary site') : s__('Geo|Secondary site');
    },
  },
  methods: {
    toggleCollapse() {
      this.collapsed = !this.collapsed;
    },
  },
};
</script>

<template>
  <div>
    <h4 class="gl-font-lg gl-my-5">{{ siteTitle }}</h4>
    <geo-node-header :node="node" :collapsed="collapsed" @collapse="toggleCollapse" />
    <geo-node-details v-if="!collapsed" :node="node" />
  </div>
</template>
