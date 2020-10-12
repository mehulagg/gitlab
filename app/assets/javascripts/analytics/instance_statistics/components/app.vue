<script>
import InstanceCounts from './instance_counts.vue';
import PipelinesChart from './pipelines_chart.vue';
import { TOTAL_DATAPOINTS_TO_FETCH, TODAY, START_DATE } from '../constants';

export default {
  name: 'InstanceStatisticsApp',
  components: {
    InstanceCounts,
    PipelinesChart,
  },
  TOTAL_DATAPOINTS_TO_FETCH,
  TODAY,
  START_DATE,
};
</script>

<template>
  <div>
    <instance-counts />
    <pipelines-chart
      :start-date="$options.START_DATE"
      :end-date="$options.TODAY"
      :total-data-points="$options.TOTAL_DATAPOINTS_TO_FETCH"
    />
  </div>
</template>
