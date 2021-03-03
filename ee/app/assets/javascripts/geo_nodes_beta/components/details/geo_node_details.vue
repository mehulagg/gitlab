<script>
import { s__ } from '~/locale';
import GeoNodeCoreDetails from './geo_node_core_details.vue';
import GeoNodePrimaryOtherInfo from './primary_node/geo_node_primary_other_info.vue';
import GeoNodeVerificationInfo from './primary_node/geo_node_verification_info.vue';

export default {
  name: 'GeoNodeDetails',
  i18n: {
    secondaryDetails: s__('Geo|Secondary Details'),
  },
  components: {
    GeoNodeCoreDetails,
    GeoNodePrimaryOtherInfo,
    GeoNodeVerificationInfo,
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
      <geo-node-verification-info
        class="gl-flex-fill-1 gl-mb-5 gl-md-mb-0 gl-md-mr-5 gl-h-full gl-w-full"
        :node="node"
      />
      <geo-node-primary-other-info class="gl-flex-fill-1 gl-h-full gl-w-full" :node="node" />
    </div>
    <div v-else class="gl-display-flex gl-flex-direction-column gl-h-full gl-w-full">
      <p data-testid="secondary-node-details">{{ $options.i18n.secondaryDetails }}</p>
    </div>
  </div>
</template>
