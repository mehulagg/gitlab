<script>
import { GlIcon, GlBadge } from '@gitlab/ui';
import GeoNodeHealthStatus from './geo_node_health_status.vue';
import GeoNodeLastUpdated from './geo_node_last_updated.vue';
import GeoNodeActions from './geo_node_actions.vue';

export default {
  name: 'GeoNodeHeader',
  components: {
    GlIcon,
    GlBadge,
    GeoNodeHealthStatus,
    GeoNodeLastUpdated,
    GeoNodeActions,
  },
  props: {
    node: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      showSection: true,
    };
  },
  computed: {
    chevronIcon() {
      return this.showSection ? 'chevron-down' : 'chevron-right';
    },
  },
};
</script>

<template>
  <div
    class="gl-display-grid geo-node-grid-columns gl-bg-gray-10 gl-border-b-1 gl-border-b-solid gl-border-b-gray-100 gl-border-t-1 gl-border-t-solid gl-border-t-gray-100 gl-p-3"
  >
    <div class="gl-display-flex gl-align-items-center">
      <gl-icon class="gl-text-blue-500 gl-mr-4" :name="chevronIcon" />
      <gl-badge v-if="node.current" variant="info" class="gl-mr-2">{{ __('Current') }}</gl-badge>
      <h4 class="gl-font-lg">{{ node.name }}</h4>
    </div>
    <div class="gl-display-flex gl-align-items-center">
      <geo-node-health-status :status="node.status" />
      <geo-node-last-updated class="gl-ml-2" :status-check-timestamp="node.statusCheckTimestamp" />
    </div>
    <div class="gl-display-flex gl-align-items-center gl-justify-content-end">
      <geo-node-actions :primary="node.primary" />
    </div>
  </div>
</template>
