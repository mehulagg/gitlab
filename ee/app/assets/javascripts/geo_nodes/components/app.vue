<script>
import { GlLoadingIcon, GlModal } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import { deprecatedCreateFlash as Flash } from '~/flash';
import SmartInterval from '~/smart_interval';
import { BV_SHOW_MODAL, BV_HIDE_MODAL } from '~/lib/utils/constants';

import eventHub from '../event_hub';

import { NODE_ACTIONS } from '../constants';

import GeoNodeItem from './geo_node_item.vue';

export default {
  components: {
    GlModal,
    GeoNodeItem,
    GlLoadingIcon,
  },
  props: {
    store: {
      type: Object,
      required: true,
    },
    service: {
      type: Object,
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
    geoTroubleshootingHelpPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      isLoading: true,
      hasError: false,
      targetNode: null,
      targetNodeActionType: '',
      modalTitle: '',
      modalKind: 'warning',
      modalMessage: '',
      modalActionLabel: '',
      modalId: 'node-action',
    };
  },
  computed: {
    nodes() {
      return this.store.getNodes();
    },
  },
  created() {
    eventHub.$on('pollNodeDetails', this.initNodeDetailsPolling);
    eventHub.$on('showNodeActionModal', this.showNodeActionModal);
    eventHub.$on('repairNode', this.repairNode);
  },
  mounted() {
    this.fetchGeoNodes();
  },
  beforeDestroy() {
    eventHub.$off('pollNodeDetails', this.initNodeDetailsPolling);
    eventHub.$off('showNodeActionModal', this.showNodeActionModal);
    eventHub.$off('repairNode', this.repairNode);
    if (this.nodePollingInterval) {
      this.nodePollingInterval.stopTimer();
    }
  },
  methods: {
    setNodeActionStatus(node, status) {
      Object.assign(node, { nodeActionActive: status });
    },
    initNodeDetailsPolling(node) {
      this.nodePollingInterval = new SmartInterval({
        callback: this.fetchNodeDetails.bind(this, node),
        startingInterval: 30000,
        maxInterval: 120000,
        hiddenInterval: 240000,
        incrementByFactorOf: 15000,
        immediateExecution: true,
      });
    },
    fetchGeoNodes() {
      return this.service
        .getGeoNodes()
        .then((res) => res.data)
        .then((nodes) => {
          this.store.setNodes(nodes);
          this.isLoading = false;
        })
        .catch(() => {
          this.isLoading = false;
          Flash(s__('GeoNodes|Something went wrong while fetching nodes'));
        });
    },
    fetchNodeDetails(node) {
      const nodeId = node.id;
      return this.service
        .getGeoNodeDetails(node)
        .then((res) => res.data)
        .then((nodeDetails) => {
          const primaryNodeVersion = this.store.getPrimaryNodeVersion();
          const updatedNodeDetails = Object.assign(nodeDetails, {
            primaryVersion: primaryNodeVersion.version,
            primaryRevision: primaryNodeVersion.revision,
          });
          this.store.setNodeDetails(nodeId, updatedNodeDetails);
          eventHub.$emit('nodeDetailsLoaded', this.store.getNodeDetails(nodeId));
        })
        .catch((err) => {
          this.store.setNodeDetails(nodeId, {
            geo_node_id: nodeId,
            health: err.message,
            health_status: __('Unknown'),
            missing_oauth_application: null,
            sync_status_unavailable: true,
            storage_shards_match: null,
          });
          eventHub.$emit('nodeDetailsLoaded', this.store.getNodeDetails(nodeId));
        });
    },
    repairNode(targetNode) {
      this.setNodeActionStatus(targetNode, true);
      return this.service
        .repairNode(targetNode)
        .then(() => {
          this.setNodeActionStatus(targetNode, false);
          this.$toast.show(s__('GeoNodes|Node Authentication was successfully repaired.'));
        })
        .catch(() => {
          this.setNodeActionStatus(targetNode, false);
          Flash(s__('GeoNodes|Something went wrong while repairing node'));
        });
    },
    toggleNode(targetNode) {
      this.setNodeActionStatus(targetNode, true);
      return this.service
        .toggleNode(targetNode)
        .then((res) => res.data)
        .then((node) => {
          Object.assign(targetNode, {
            enabled: node.enabled,
            nodeActionActive: false,
          });
        })
        .catch(() => {
          this.setNodeActionStatus(targetNode, false);
          Flash(s__('GeoNodes|Something went wrong while changing node status'));
        });
    },
    removeNode(targetNode) {
      this.setNodeActionStatus(targetNode, true);
      return this.service
        .removeNode(targetNode)
        .then(() => {
          this.store.removeNode(targetNode);
          this.$toast.show(s__('GeoNodes|Node was successfully removed.'));
        })
        .catch(() => {
          this.setNodeActionStatus(targetNode, false);
          Flash(s__('GeoNodes|Something went wrong while removing node'));
        });
    },
    handleNodeAction() {
      this.hideNodeActionModal();

      if (this.targetNodeActionType === NODE_ACTIONS.TOGGLE) {
        this.toggleNode(this.targetNode);
      } else if (this.targetNodeActionType === NODE_ACTIONS.REMOVE) {
        this.removeNode(this.targetNode);
      }
    },
    showNodeActionModal({
      actionType,
      node,
      modalKind = 'warning',
      modalMessage,
      modalActionLabel,
      modalTitle,
    }) {
      this.targetNode = node;
      this.targetNodeActionType = actionType;
      this.modalKind = modalKind;
      this.modalMessage = modalMessage;
      this.modalActionLabel = modalActionLabel;
      this.modalTitle = modalTitle;

      if (actionType === NODE_ACTIONS.TOGGLE && !node.enabled) {
        this.toggleNode(this.targetNode);
      } else {
        this.$root.$emit(BV_SHOW_MODAL, this.modalId);
      }
    },
    hideNodeActionModal() {
      this.$root.$emit(BV_HIDE_MODAL, this.modalId);
    },
    nodeRemovalAllowed(node) {
      return !node.primary || this.nodes.length <= 1;
    },
  },
};
</script>

<template>
  <div class="geo-nodes-container">
    <gl-loading-icon
      v-if="isLoading"
      :label="s__('GeoNodes|Loading nodes')"
      size="md"
      class="loading-animation prepend-top-20 append-bottom-20"
    />
    <geo-node-item
      v-for="(node, index) in nodes"
      :key="index"
      :node="node"
      :primary-node="node.primary"
      :node-actions-allowed="nodeActionsAllowed"
      :node-edit-allowed="nodeEditAllowed"
      :node-removal-allowed="nodeRemovalAllowed(node)"
      :geo-troubleshooting-help-path="geoTroubleshootingHelpPath"
    />
    <gl-modal
      :modal-id="modalId"
      :title="modalTitle"
      :ok-variant="modalKind"
      :ok-title="modalActionLabel"
      @cancel="hideNodeActionModal"
      @ok="handleNodeAction"
    >
      {{ modalMessage }}
    </gl-modal>
  </div>
</template>
