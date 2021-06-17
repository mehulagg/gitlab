<script>
import { debounce } from 'lodash';
import {
  stateFilter,
  severityFilter,
  vendorScannerFilter,
  standardScannerFilter,
  activityFilter,
  getProjectFilter,
} from 'ee/security_dashboard/helpers';
import { DASHBOARD_TYPES } from 'ee/security_dashboard/store/constants';
import ActivityFilter from './activity_filter.vue';
import ScannerFilter from './scanner_filter.vue';
import StandardFilter from './standard_filter.vue';

export default {
  components: { StandardFilter, ScannerFilter, ActivityFilter },
  inject: ['dashboardType'],
  props: {
    projects: { type: Array, required: false, default: undefined },
  },
  data() {
    return {
      filterQuery: {},
      standardFilters: [stateFilter, severityFilter],
    };
  },
  computed: {
    isProjectDashboard() {
      return this.dashboardType === DASHBOARD_TYPES.PROJECT;
    },
    isPipeline() {
      return this.dashboardType === DASHBOARD_TYPES.PIPELINE;
    },
    shouldShowProjectFilter() {
      return Boolean(this.projects?.length);
    },
    projectFilter() {
      return getProjectFilter(this.projects);
    },
  },
  methods: {
    updateFilterQuery(query) {
      this.filterQuery = { ...this.filterQuery, ...query };
      this.emitFilterChange();
    },
    // When this component is first shown, every filter will emit its own @filter-changed event at,
    // which will trigger this method multiple times. We'll debounce it so that it only runs once.
    emitFilterChange: debounce(function emit() {
      this.$emit('filterChange', this.filterQuery);
    }),
  },
  vendorScannerFilter,
  standardScannerFilter,
  activityFilter,
};
</script>

<template>
  <div
    class="vulnerability-report-filters gl-p-5 gl-bg-gray-10 gl-border-b-1 gl-border-b-solid gl-border-b-gray-100"
  >
    <standard-filter
      v-for="filter in standardFilters"
      :key="filter.id"
      :filter="filter"
      :data-testid="filter.id"
      @filter-changed="updateFilterQuery"
    />

    <scanner-filter
      v-if="isProjectDashboard"
      :filter="$options.vendorScannerFilter"
      @filter-changed="updateFilterQuery"
    />
    <standard-filter
      v-else
      :filter="$options.standardScannerFilter"
      :data-testid="$options.standardScannerFilter.id"
      @filter-changed="updateFilterQuery"
    />

    <activity-filter
      v-if="!isPipeline"
      :filter="$options.activityFilter"
      @filter-changed="updateFilterQuery"
    />
    <standard-filter
      v-if="shouldShowProjectFilter"
      :filter="projectFilter"
      :data-testid="projectFilter.id"
      @filter-changed="updateFilterQuery"
    />
  </div>
</template>
