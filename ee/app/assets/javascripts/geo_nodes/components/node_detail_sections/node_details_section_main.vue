<script>
import { GlLink, GlIcon } from '@gitlab/ui';
import { __, sprintf } from '~/locale';

import GeoNodeHealthStatus from '../geo_node_health_status.vue';
import GeoNodeReplicationStatus from '../geo_node_replication_status.vue';
import GeoNodeActions from '../geo_node_actions.vue';

export default {
  components: {
    GlLink,
    GlIcon,
    GeoNodeHealthStatus,
    GeoNodeActions,
    GeoNodeReplicationStatus,
  },
  props: {
    node: {
      type: Object,
      required: true,
    },
    nodeDetails: {
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
    nodeRemovalAllowed: {
      type: Boolean,
      required: true,
    },
    versionMismatch: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    nodeVersion() {
      if (this.nodeDetails.version == null && this.nodeDetails.revision == null) {
        return __('Unknown');
      }
      return `${this.nodeDetails.version} (${this.nodeDetails.revision})`;
    },
    nodeHealthStatus() {
      return this.nodeDetails.healthy ? this.nodeDetails.health : this.nodeDetails.healthStatus;
    },
    selectiveSyncronization() {
      const { selectiveSyncType } = this.nodeDetails;

      if (selectiveSyncType === 'shards') {
        return sprintf(__('Shards (%{shards})'), {
          shards: this.node.selectiveSyncShards.join(', '),
        });
      }

      if (selectiveSyncType === 'namespaces') {
        return sprintf(__('Groups (%{groups})'), {
          groups: this.nodeDetails.namespaces.map(n => n.full_path).join(', '),
        });
      }

      return null;
    },
  },
};
</script>

<template>
  <div class="row-fluid clearfix py-3 primary-section">
    <div class="col-md-12">
      <div class="gl-display-flex gl-flex-wrap gl-flex-direction-column gl-sm-flex-direction-row">
        <div data-testid="nodeUrl" class="d-flex flex-column">
          <span class="gl-text-gray-500">{{ s__('GeoNodes|Node URL') }}</span>
          <gl-link
            class="gl-display-flex gl-align-items-center gl-text-body gl-font-weight-bold gl-text-decoration-underline gl-mt-1"
            :href="node.url"
            target="_blank"
            >{{ node.url }} <gl-icon name="external-link" class="gl-ml-1"
          /></gl-link>
        </div>
        <geo-node-actions
          class="flex-grow-1"
          :node="node"
          :node-actions-allowed="nodeActionsAllowed"
          :node-edit-allowed="nodeEditAllowed"
          :node-removal-allowed="nodeRemovalAllowed"
          :node-missing-oauth="nodeDetails.missingOAuthApplication"
        />
      </div>
      <div data-testid="nodeVersion" class="d-flex flex-column mt-2">
        <span class="gl-text-gray-500">{{ s__('GeoNodes|GitLab version') }}</span>
        <span :class="{ 'gl-text-red-500': versionMismatch }" class="gl-mt-1 gl-font-weight-bold">
          {{ nodeVersion }}
        </span>
      </div>
      <div v-if="selectiveSyncronization" class="d-flex flex-column mt-2">
        <span class="text-secondary-700">{{ s__('GeoNodes|Selective synchronization') }}</span>
        <span data-testid="selectiveSync" class="gl-mt-1 gl-font-weight-bold">
          {{ selectiveSyncronization }}
        </span>
      </div>
      <geo-node-health-status
        :status="nodeHealthStatus"
        :status-check-timestamp="nodeDetails.statusCheckTimestamp"
      />
      <div v-if="!node.primary">
        <geo-node-replication-status :node="node" />
      </div>
    </div>
  </div>
</template>
