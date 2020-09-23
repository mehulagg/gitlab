<script>
import eventHub from '../event_hub';

import GeoNodeHeader from './geo_node_header.vue';
import GeoNodeDetails from './geo_node_details.vue';

export default {
  components: {
    GeoNodeHeader,
    GeoNodeDetails,
  },
  props: {
    node: {
      type: Object,
      required: true,
    },
    primaryNode: {
      type: Boolean,
      required: true,
    },
    nodeActionsAllowed: {
      type: Boolean,
      required: true,
    },
    nodeEditAllowed: {
      type: Boolean,
      required: true,
    },
    nodeRemovalAllowed: {
      type: Boolean,
      required: true,
    },
    geoTroubleshootingHelpPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      isNodeDetailsLoading: true,
      nodeHealthStatus: '',
      nodeDetails: {},
    };
  },
  created() {
    eventHub.$on('nodeDetailsLoaded', this.handleNodeDetails);
  },
  mounted() {
    this.handleMounted();
  },
  beforeDestroy() {
    eventHub.$off('nodeDetailsLoaded', this.handleNodeDetails);
  },
  methods: {
    handleNodeDetails(nodeDetails) {
      if (this.node.id === nodeDetails.id) {
        this.isNodeDetailsLoading = false;
        this.nodeDetails = nodeDetails;
        this.nodeHealthStatus = nodeDetails.health;
      }
    },
    handleMounted() {
      eventHub.$emit('pollNodeDetails', this.node);
    },
  },
};
</script>

<template>
  <div :class="{ 'node-action-active': node.nodeActionActive }" class="card">
    <geo-node-header :node="node" :node-details-loading="isNodeDetailsLoading" />
    <geo-node-details
      v-if="!isNodeDetailsLoading"
      :node="node"
      :node-details="nodeDetails"
      :node-edit-allowed="nodeEditAllowed"
      :node-actions-allowed="nodeActionsAllowed"
      :node-removal-allowed="nodeRemovalAllowed"
      :geo-troubleshooting-help-path="geoTroubleshootingHelpPath"
    />
  </div>
</template>
