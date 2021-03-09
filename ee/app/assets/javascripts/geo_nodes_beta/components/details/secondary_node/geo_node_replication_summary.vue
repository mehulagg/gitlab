<script>
import { GlCard, GlButton } from '@gitlab/ui';

export default {
  name: 'GeoNodeReplicationSummary',
  components: {
    GlCard,
    GlButton,
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
      <span data-testid="replication-status">{{ s__('Geo|Replication status') }}</span>
    </div>
    <div class="gl-display-flex gl-flex-direction-column gl-mb-5">
      <span data-testid="sync-settings">{{ s__('Geo|Synchronization settings') }}</span>
    </div>
    <span data-testid="replication-counts">{{ s__('Geo|Replication counts') }}</span>
  </gl-card>
</template>
