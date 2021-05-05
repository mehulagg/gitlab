<script>
import { s__ } from '~/locale';
import GeoNodeDetails from './details/geo_node_details.vue';
import GeoNodeHeader from './header/geo_node_header.vue';

export default {
  name: 'GeoNodes',
  i18n: {
    primarySite: s__('Geo|Primary site'),
    secondarySite: s__('Geo|Secondary site'),
  },
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
  computed: {
    siteTitle() {
      return this.node.primary ? this.$options.i18n.primarySite : this.$options.i18n.secondarySite;
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
