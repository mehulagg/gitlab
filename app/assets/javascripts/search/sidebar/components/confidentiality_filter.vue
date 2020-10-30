<script>
import confidentialFilterData from '../constants/confidential_filter_data';
import RadioFilter from './radio_filter.vue';

export default {
  name: 'StatusFilter',
  components: {
    RadioFilter,
  },
  confidentialFilterData,
};
</script>

<template>
  <radio-filter :filter-data="$options.confidentialFilterData" />
</template>
