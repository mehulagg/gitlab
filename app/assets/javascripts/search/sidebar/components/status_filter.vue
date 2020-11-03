<script>
import { mapState } from 'vuex';
import stateFilterData from '../constants/state_filter_data';
import RadioFilter from './radio_filter.vue';

export default {
  name: 'StatusFilter',
  components: {
    RadioFilter,
  },
  computed: {
    ...mapState(['query']),
    supportedScopes() {
      return Object.values(stateFilterData.scopes);
    },
    showDropdown() {
      return this.supportedScopes.includes(this.query.scope);
    },
  },
  stateFilterData,
};
</script>

<template>
  <div v-if="showDropdown">
    <radio-filter :filter-data="$options.stateFilterData" />
  </div>
</template>
