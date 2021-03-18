<script>
import { s__ } from '~/locale';
import GeoNodeCoreDetails from './geo_node_core_details.vue';

export default {
  name: 'GeoNodeDetails',
  i18n: {
    primaryDetails: s__('Geo|Primary Details'),
    secondaryDetails: s__('Geo|Secondary Details'),
  },
  components: {
    GeoNodeCoreDetails,
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
      <p data-testid="primary-node-details">{{ $options.i18n.primaryDetails }}</p>
    </div>
    <div v-else class="gl-display-flex gl-flex-direction-column gl-h-full gl-w-full">
      <p data-testid="secondary-node-details">{{ $options.i18n.secondaryDetails }}</p>
    </div>
  </div>
</template>
