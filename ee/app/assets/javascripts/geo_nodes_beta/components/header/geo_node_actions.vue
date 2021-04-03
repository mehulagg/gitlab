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
    primary: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
};
</script>

<template>
  <div>
    <geo-node-actions-mobile class="gl-lg-display-none" :primary="primary" />
    <geo-node-actions-desktop class="gl-display-none gl-lg-display-flex" :primary="primary" />
  </div>
</template>
