<script>
import GeoNodeCoreDetails from './geo_node_core_details.vue';
import GeoNodePrimaryOtherInfo from './primary_node/geo_node_primary_other_info.vue';
import GeoNodeVerificationInfo from './primary_node/geo_node_verification_info.vue';
import GeoNodeReplicationDetails from './secondary_node/geo_node_replication_details.vue';
import GeoNodeReplicationSummary from './secondary_node/geo_node_replication_summary.vue';
import GeoNodeSecondaryOtherInfo from './secondary_node/geo_node_secondary_other_info.vue';

export default {
  name: 'GeoNodeDetails',
  components: {
    GeoNodeCoreDetails,
    GeoNodePrimaryOtherInfo,
    GeoNodeVerificationInfo,
    GeoNodeReplicationSummary,
    GeoNodeSecondaryOtherInfo,
    GeoNodeReplicationDetails,
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
    <div
      v-if="node.primary"
      class="gl-display-flex gl-sm-flex-direction-column gl-align-items-flex-start gl-h-full gl-w-full"
    >
      <geo-node-verification-info
        class="gl-flex-grow-1 gl-mb-5 gl-md-mb-0 gl-md-mr-5 gl-h-full gl-w-full"
        :node="node"
      />
      <geo-node-primary-other-info class="gl-flex-grow-1 gl-h-full gl-w-full" :node="node" />
    </div>
    <div v-else class="gl-display-flex gl-flex-direction-column gl-h-full gl-w-full">
      <div
        class="gl-display-flex gl-sm-flex-direction-column gl-align-items-flex-start gl-h-full gl-w-full gl-mb-5"
      >
        <geo-node-replication-summary
          class="gl-flex-grow-1 gl-mb-5 gl-md-mb-0 gl-md-mr-5 gl-h-full gl-w-full"
          :node="node"
        />
        <geo-node-secondary-other-info class="gl-flex-grow-1 gl-h-full gl-w-full" :node="node" />
      </div>
      <geo-node-replication-details :node="node" />
    </div>
  </div>
</template>
