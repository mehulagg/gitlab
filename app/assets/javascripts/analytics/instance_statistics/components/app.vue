<script>
import InstanceCounts from './instance_counts.vue';
import UsersChart from './users_chart.vue';

export default {
  name: 'InstanceStatisticsApp',
  components: {
    InstanceCounts,
    UsersChart,
  },
};
</script>

<template>
  <div>
    <instance-counts />
    <users-chart />
  </div>
</template>
