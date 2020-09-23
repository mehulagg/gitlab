<script>
import { GlStackedColumnChart } from '@gitlab/ui/dist/charts';

export default {
  name: 'TasksByTypeChart',
  components: {
    GlStackedColumnChart,
  },
  props: {
    data: {
      type: Array,
      required: true,
    },
    groupBy: {
      type: Array,
      required: true,
    },
    seriesNames: {
      type: Array,
      required: true,
    },
  },
};
</script>
<template>
  <gl-stacked-column-chart
    :data="data"
    :group-by="groupBy"
    x-axis-type="category"
    y-axis-type="value"
    :x-axis-title="__('Date')"
    :y-axis-title="s__('CycleAnalytics|Number of tasks')"
    :series-names="seriesNames"
  />
</template>
