<script>
import { engineeringNotation } from '@gitlab/ui/src/utils/number_utils';

export default {
  name: 'StatisticsSummary',
  components: {
    GlSingleStat: () => import(/* webpackChunkName: 'gl_single_stat' */ '@gitlab/ui/dist/charts'),
  },
  props: {
    data: {
      type: Object,
      required: true,
      validator: ({ anomalous, nominal }) =>
        Boolean(anomalous?.title && anomalous?.value) && Boolean(nominal?.title && nominal?.value),
    },
  },
  computed: {
    statistics() {
      const { anomalous, nominal } = this.data;
      return [
        {
          key: 'anomalousTraffic',
          title: anomalous.title,
          value: `${Math.round(anomalous.value * 100)}`,
          unit: '%',
          variant: 'warning',
        },
        {
          key: 'totalTraffic',
          title: nominal.title,
          value: engineeringNotation(nominal.value),
        },
      ];
    },
  },
};
</script>

<template>
  <div class="row">
    <gl-single-stat
      v-for="stat in statistics"
      :key="stat.key"
      class="col-sm-6 col-md-4 col-lg-3"
      v-bind="stat"
    />
  </div>
</template>
