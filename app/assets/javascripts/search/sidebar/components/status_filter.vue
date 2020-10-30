<script>
import stateFilterData from '../constants/state_filter_data';
import RadioFilter from './radio_filter.vue';

export default {
  name: 'StatusFilter',
  components: {
    RadioFilter,
  },
  stateFilterData,
};
</script>

<template>
  <radio-filter :filter-data="$options.stateFilterData" />
</template>
