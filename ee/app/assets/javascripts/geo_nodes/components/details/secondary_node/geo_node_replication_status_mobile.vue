<script>
import GeoNodeProgressBar from 'ee/geo_nodes/components/details/geo_node_progress_bar.vue';

export default {
  name: 'GeoNodeReplicationStatusMobile',
  components: {
    GeoNodeProgressBar,
  },
  props: {
    item: {
      type: Object,
      required: true,
    },
    translations: {
      type: Object,
      required: true,
    },
  },
};
</script>

<template>
  <div>
    <div class="gl-mb-5 gl-display-flex gl-flex-direction-column" data-testid="sync-status">
      <span class="gl-font-sm gl-mb-3">{{ translations.syncStatus }}</span>
      <geo-node-progress-bar
        v-if="item.syncValues"
        :title="sprintf(translations.progressBarSyncTitle, { component: item.component })"
        :target="`mobile-sync-progress-${item.component}`"
        :values="item.syncValues"
      />
      <span v-else class="gl-text-gray-400 gl-font-sm">{{ translations.nA }}</span>
    </div>
    <div class="gl-display-flex gl-flex-direction-column" data-testid="verification-status">
      <span class="gl-font-sm gl-mb-3">{{ translations.verifStatus }}</span>
      <geo-node-progress-bar
        v-if="item.verificationValues"
        :title="sprintf(translations.progressBarVerifTitle, { component: item.component })"
        :target="`mobile-verification-progress-${item.component}`"
        :values="item.verificationValues"
        :success-label="translations.verified"
        :unavailable-label="translations.nothingToVerify"
      />
      <span v-else class="gl-text-gray-400 gl-font-sm">{{ translations.nA }}</span>
    </div>
  </div>
</template>
