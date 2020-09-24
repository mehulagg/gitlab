<script>
import { GlIcon } from '@gitlab/ui';
import GeoNodeLastUpdated from './geo_node_last_updated.vue';
import { HEALTH_STATUS_ICON, HEALTH_STATUS_CLASS } from '../constants';

export default {
  components: {
    GlIcon,
    GeoNodeLastUpdated,
  },
  props: {
    status: {
      type: String,
      required: true,
    },
    statusCheckTimestamp: {
      type: Number,
      required: true,
    },
  },
  computed: {
    healthCssClass() {
      return HEALTH_STATUS_CLASS[this.status.toLowerCase()];
    },
    statusIconName() {
      return HEALTH_STATUS_ICON[this.status.toLowerCase()];
    },
  },
};
</script>

<template>
  <div class="mt-2 detail-section-item">
    <div class="text-secondary-700 node-detail-title">{{ s__('GeoNodes|Health status') }}</div>
    <div class="d-flex align-items-center">
      <div
        :class="healthCssClass"
        class="rounded-pill d-inline-flex align-items-center px-2 py-1 my-1 mr-2"
      >
        <gl-icon :name="statusIconName" />
        <strong class="status-text ml-1"> {{ status }} </strong>
      </div>
      <geo-node-last-updated :status-check-timestamp="statusCheckTimestamp" />
    </div>
  </div>
</template>
