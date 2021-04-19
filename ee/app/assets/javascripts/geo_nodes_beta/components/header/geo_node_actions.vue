<script>
import GeoNodeActionsDesktop from './geo_node_actions_desktop.vue';
import GeoNodeActionsMobile from './geo_node_actions_mobile.vue';

export default {
  name: 'GeoNodeActions',
  components: {
    GeoNodeActionsMobile,
    GeoNodeActionsDesktop,
  },
  props: {
    node: {
      type: Object,
      required: true,
    },
  },
};
</script>

<template>
  <div>
    <geo-node-actions-mobile class="gl-lg-display-none" :node="node" />
    <geo-node-actions-desktop class="gl-display-none gl-lg-display-flex" :node="node" />
  </div>
</template>
