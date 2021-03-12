<script>
import GeoNodeProgressBar from 'ee/geo_nodes_beta/components/details/geo_node_progress_bar.vue';
import { s__, __ } from '~/locale';

export default {
  name: 'GeoNodeReplicationDetailsMobile',
  i18n: {
    component: __('Component'),
    status: __('Status'),
    syncStatus: s__('Geo|Synchronization status'),
    verifStatus: s__('Geo|Verification status'),
    nA: __('N/A'),
  },
  components: {
    GeoNodeProgressBar,
  },
  props: {
    replicationItems: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
};
</script>

<template>
  <div>
    <div
      class="gl-display-grid geo-node-replication-details-grid-columns gl-bg-gray-10 gl-p-5 gl-border-b-1 gl-border-b-solid gl-border-b-gray-100"
      data-testid="replication-details-header"
    >
      <span class="gl-font-weight-bold">{{ $options.i18n.component }}</span>
      <span class="gl-font-weight-bold">{{ $options.i18n.status }}</span>
    </div>
    <div
      v-for="item in replicationItems"
      :key="item.component"
      class="gl-display-grid geo-node-replication-details-grid-columns gl-p-5 gl-border-b-1 gl-border-b-solid gl-border-b-gray-100"
      data-testid="replication-details-item"
    >
      <span class="gl-mr-5">{{ item.component }}</span>
      <div>
        <div class="gl-mb-5 gl-display-flex gl-flex-direction-column" data-testid="sync-status">
          <span class="gl-font-sm gl-mb-3">{{ $options.i18n.syncStatus }}</span>
          <geo-node-progress-bar
            v-if="item.syncValues"
            :title="`${item.component} synced`"
            :values="item.syncValues"
          />
          <span v-else class="gl-text-gray-400 gl-font-sm">{{ $options.i18n.nA }}</span>
        </div>
        <div class="gl-display-flex gl-flex-direction-column" data-testid="verification-status">
          <span class="gl-font-sm gl-mb-3">{{ $options.i18n.verifStatus }}</span>
          <geo-node-progress-bar
            v-if="item.verificationValues"
            :title="`${item.component} synced`"
            :values="item.verificationValues"
          />
          <span v-else class="gl-text-gray-400 gl-font-sm">{{ $options.i18n.nA }}</span>
        </div>
      </div>
    </div>
  </div>
</template>
