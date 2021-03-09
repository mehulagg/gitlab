<script>
import { mapGetters } from 'vuex';
import { REPOSITORY, BLOB } from 'ee/geo_nodes_beta/constants';
import { roundDownFloat } from '~/lib/utils/common_utils';
import { __ } from '~/locale';

export default {
  name: 'GeoNodeReplicationCounts',
  props: {
    node: {
      type: Object,
      required: true,
    },
  },
  computed: {
    ...mapGetters(['verificationInfo', 'syncInfo']),
    replicationOverview() {
      const syncInfoData = this.syncInfo(this.node.id);
      const verificationInfoData = this.verificationInfo(this.node.id);

      const overview = [
        {
          title: __('Git'),
          sync: syncInfoData.filter((replicable) => replicable.dataType === REPOSITORY),
          verification: verificationInfoData.filter(
            (replicable) => replicable.dataType === REPOSITORY,
          ),
        },
        {
          title: __('File'),
          sync: syncInfoData.filter((replicable) => replicable.dataType === BLOB),
          verification: verificationInfoData.filter((replicable) => replicable.dataType === BLOB),
        },
      ];

      return overview.map((type) => {
        return {
          title: type.title,
          synchronizationPercent: this.getPercent(type.sync),
          verificationPercent: this.getPercent(type.verification),
        };
      });
    },
  },
  methods: {
    getPercent(type) {
      if (!type.length) {
        return NaN;
      }

      const total = type.map((t) => t.values.total).reduce((a, b) => a + b);
      const success = type.map((t) => t.values.success).reduce((a, b) => a + b);

      const percent = roundDownFloat((success / total) * 100, 1);
      if (percent > 0 && percent < 1) {
        return '< 1';
      }
      return percent;
    },
    percentColor(value) {
      if (Number.isNaN(value)) {
        return 'gl-bg-gray-200';
      }

      return value < 100 ? 'gl-bg-red-500' : 'gl-bg-green-500';
    },
  },
};
</script>

<template>
  <div>
    <div class="gl-display-flex gl-align-items-center gl-mb-3">
      <span class="gl-flex-fill-1">{{ __('Data type') }}</span>
      <span class="gl-flex-fill-1">{{ __('Synchronization') }}</span>
      <span class="gl-flex-fill-1">{{ __('Verification') }}</span>
    </div>
    <div
      v-for="type in replicationOverview"
      :key="type.title"
      class="gl-display-flex gl-align-items-center gl-mb-3"
    >
      <span class="gl-flex-fill-1">{{ type.title }}</span>
      <div class="gl-display-flex gl-align-items-center gl-flex-fill-1">
        <div
          :class="percentColor(type.synchronizationPercent)"
          class="gl-rounded-full gl-w-3 gl-h-3 gl-mr-2"
        ></div>
        <span class="gl-font-weight-bold">{{
          Number.isNaN(type.synchronizationPercent) ? __('N/A') : `${type.synchronizationPercent}%`
        }}</span>
      </div>
      <div class="gl-display-flex gl-align-items-center gl-flex-fill-1">
        <div
          :class="percentColor(type.verificationPercent)"
          class="gl-rounded-full gl-w-3 gl-h-3 gl-mr-2"
        ></div>
        <span class="gl-font-weight-bold">{{
          Number.isNaN(type.verificationPercent) ? __('N/A') : `${type.verificationPercent}%`
        }}</span>
      </div>
    </div>
  </div>
</template>
