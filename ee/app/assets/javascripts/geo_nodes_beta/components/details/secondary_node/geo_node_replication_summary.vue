<script>
import { GlCard, GlButton } from '@gitlab/ui';
import GeoNodeReplicationCounts from './geo_node_replication_counts.vue';
import GeoNodeReplicationStatus from './geo_node_replication_status.vue';
import GeoNodeSyncSettings from './geo_node_sync_settings.vue';

export default {
  name: 'GeoNodeReplicationSummary',
  components: {
    GlCard,
    GlButton,
    GeoNodeReplicationStatus,
    GeoNodeSyncSettings,
    GeoNodeReplicationCounts,
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
  <gl-card header-class="gl-display-flex gl-align-items-center">
    <template #header>
      <h5 class="gl-my-0">{{ s__('Geo|Replication summary') }}</h5>
      <gl-button
        class="gl-ml-auto"
        variant="confirm"
        category="secondary"
        :href="node.webGeoProjectsUrl"
        target="_blank"
        >{{ s__('Geo|Replication details') }}</gl-button
      >
    </template>
    <div class="gl-display-flex gl-flex-direction-column gl-mb-5">
      <span>{{ s__('Geo|Replication status') }}</span>
      <geo-node-replication-status class="gl-mt-3" :node="node" />
    </div>
    <div class="gl-display-flex gl-flex-direction-column gl-mb-5">
      <span>{{ s__('Geo|Synchronization settings') }}</span>
      <geo-node-sync-settings class="gl-mt-2" :node="node" />
    </div>
    <geo-node-replication-counts :node="node" class="gl-mb-5" />
  </gl-card>
</template>
