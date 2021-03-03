<script>
import { GlCard } from '@gitlab/ui';
import { mapGetters } from 'vuex';
import { numberToHumanSize } from '~/lib/utils/number_utils';
import { __ } from '~/locale';
import GeoNodeProgressBar from '../geo_node_progress_bar.vue';

export default {
  name: 'GeoNodePrimaryOtherInfo',
  components: {
    GlCard,
    GeoNodeProgressBar,
  },
  props: {
    node: {
      type: Object,
      required: true,
    },
  },
  computed: {
    ...mapGetters(['primaryOtherInfoBars']),
    replicationSlotWAL() {
      return numberToHumanSize(this.node.replicationSlotsMaxRetainedWalBytes);
    },
    primaryOtherInfoBars() {
      return [
        {
          title: __('Replication slots'),
          values: {
            total: this.node.replicationSlotsCount || 0,
            success: this.node.replicationSlotsUsedCount || 0,
            failed: 0,
          },
        },
      ];
    },
  },
};
</script>

<template>
  <gl-card>
    <template #header>
      <h5 class="gl-my-0">{{ __('Other information') }}</h5>
    </template>
    <div v-for="bar in primaryOtherInfoBars" :key="bar.title" class="gl-mb-5">
      <span>{{ bar.title }}</span>
      <geo-node-progress-bar class="gl-mt-3" :title="bar.title" :values="bar.values" />
    </div>
    <div v-if="node.replicationSlotsCount" class="gl-display-flex gl-flex-direction-column gl-mb-5">
      <span>{{ __('Replication slot WAL') }}</span>
      <span class="gl-font-weight-bold gl-mt-2">{{ replicationSlotWAL }}</span>
    </div>
  </gl-card>
</template>
