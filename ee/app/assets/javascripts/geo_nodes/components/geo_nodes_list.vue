<script>
import geoNodeItem from './geo_node_item.vue';

export default {
  components: {
    geoNodeItem,
  },
  props: {
    nodes: {
      type: Array,
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
};
</script>

<template>
  <div class="card">
    <geo-node-item
      v-for="(node, index) in nodes"
      :key="index"
      :node="node"
      :primary-node="node.primary"
      :node-actions-allowed="nodeActionsAllowed"
      :node-edit-allowed="nodeEditAllowed"
      :node-removal-allowed="nodeRemovalAllowed"
      :geo-troubleshooting-help-path="geoTroubleshootingHelpPath"
    />
  </div>
</template>
