<script>
import MetricCard from '~/analytics/shared/components/metric_card.vue';

export default {
  name: 'TestCoverageSummary',
  components: {
    MetricCard,
  },
};
</script>
<template>
  <metric-card
    :title="__('Overall Activity')"
    :metrics="[
      { key: 1, value: 45, unit: '', label: 'Projects with Tests' },
      { key: 2, value: 72, unit: '%', label: 'Average Coverage by Job' },
      { key: 3, value: 103, unit: '', label: 'Total Number of Coverages' },
    ]"
    :is-loading="false"
  />
</template>
