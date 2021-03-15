<script>
import { GlFormCheckbox, GlFormGroup, GlSearchBoxByType } from '@gitlab/ui';
import { s__ } from '~/locale';
import { DEFAULT_FILTERS } from './constants';

export default {
  DEFAULT_DISMISSED_FILTER: true,
  components: { GlFormCheckbox, GlFormGroup, GlSearchBoxByType },
  props: {
    filters: {
      type: Object,
      required: false,
      default: () => {},
    },
  },
  data() {
    return {
      showMinimumSearchQueryMessage: false,
    };
  },
  i18n: {
    HIDE_DISMISSED_TITLE: s__('ThreatMonitoring|Hide dismissed alerts'),
  },
  methods: {
    changeDismissedFilter(filtered) {
      const newFilters = filtered ? DEFAULT_FILTERS : {};
      this.handleFilterChange(newFilters);
    },
    handleSearch(searchTerm) {
      const newFilters = { searchTerm };
      this.handleFilterChange(newFilters);
    },
    handleFilterChange(newFilters) {
      this.$emit('filter-change', { ...this.filters, ...newFilters });
    },
  },
};
</script>

<template>
  <div
    class="gl-p-4 gl-bg-gray-10 gl-display-flex gl-justify-content-space-between gl-align-items-center"
  >
    <gl-search-box-by-type
      debounce="250"
      :placeholder="__(`Search by policy name`)"
      @input="handleSearch"
    />
    <gl-form-group label-size="sm" class="gl-mb-0">
      <gl-form-checkbox
        class="gl-mt-3"
        :checked="$options.DEFAULT_DISMISSED_FILTER"
        @change="changeDismissedFilter"
      >
        {{ $options.i18n.HIDE_DISMISSED_TITLE }}
      </gl-form-checkbox>
    </gl-form-group>
  </div>
</template>
