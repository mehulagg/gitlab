<script>
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
      validator: (value) => ['id', 'name', 'url'].every((prop) => value[prop]),
    },
  },
  data() {
    return {
      collapsed: false,
    };
  },
  methods: {
    toggleCollapse() {
      this.collapsed = !this.collapsed;
    },
  },
};
</script>

<template>
  <div class="gl-mb-4">
    <geo-node-header :node="node" :collapsed="collapsed" @collapse="toggleCollapse" />
    <geo-node-details v-if="!collapsed" :node="node" />
  </div>
</template>
