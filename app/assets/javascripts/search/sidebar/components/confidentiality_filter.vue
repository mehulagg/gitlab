<script>
import { mapState } from 'vuex';
import confidentialFilterData from '../constants/confidential_filter_data';
import RadioFilter from './radio_filter.vue';

export default {
  name: 'ConfidentialityFilter',
  components: {
    RadioFilter,
  },
  computed: {
    ...mapState(['query']),
    supportedScopes() {
      return Object.values(confidentialFilterData.scopes);
    },
    showDropdown() {
      return this.supportedScopes.includes(this.query.scope);
    },
  },
  confidentialFilterData,
};
</script>

<template>
  <div v-if="showDropdown">
    <radio-filter :filter-data="$options.confidentialFilterData" />
  </div>
</template>
