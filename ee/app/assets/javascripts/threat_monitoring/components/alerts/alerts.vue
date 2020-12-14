<script>
import AlertsList from './alerts_list.vue';
import AlertFilters from './alert_filters.vue';
import { DEFAULT_FILTERS } from './constants';

export default {
  name: 'ThreatAlerts',
  components: {
    AlertsList,
    AlertFilters,
  },
  data: () => {
    return {
      filters: DEFAULT_FILTERS,
    };
  },
  methods: {
    handleFilterChange(newFilters) {
      this.filters = newFilters;
    },
  },
};
</script>

<template>
  <div>
    <alert-filters :filters="filters" @filter-change="handleFilterChange" />
    <alerts-list :filters="filters" />
  </div>
</template>
