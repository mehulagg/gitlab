<script>
import ReleaseStatsCard from './release_stats_card.vue';

export default {
  name: 'CiCdAnalyticsApp',
  components: {
    ReleaseStatsCard,
  },
};
</script>
<template>
  <div>
    <release-stats-card class="gl-mt-5" />
  </div>
</template>
