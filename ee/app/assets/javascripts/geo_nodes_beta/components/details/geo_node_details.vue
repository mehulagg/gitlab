<script>
import GeoNodeCoreDetails from './geo_node_core_details.vue';

export default {
  name: 'GeoNodeDetails',
  components: {
    GeoNodeCoreDetails,
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
  <div class="gl-display-grid geo-node-details-grid-columns gl-p-5">
    <geo-node-core-details :node="node" />
    <div>
      <div
        v-if="node.primary"
        class="gl-display-flex gl-sm-flex-direction-column gl-align-items-flex-start gl-h-full gl-w-full"
      >
        <p data-testid="primaryNodeDetails">{{ s__('Geo|Primary Details') }}</p>
      </div>
      <div v-else class="gl-display-flex gl-flex-direction-column gl-h-full gl-w-full">
        <p data-testid="secondaryNodeDetails">{{ s__('Geo|Secondary Details') }}</p>
      </div>
    </div>
  </div>
</template>
