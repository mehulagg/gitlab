<script>
import DateRange from '../../shared/components/daterange.vue';
import ProjectsDropdownFilter from '../../shared/components/projects_dropdown_filter.vue';
import { DATE_RANGE_LIMIT } from '../../shared/constants';
import { PROJECTS_PER_PAGE } from '../constants';
import FilterBar from './filter_bar.vue';

export default {
  name: 'ValueStreamFilters',
  components: {
    DateRange,
    ProjectsDropdownFilter,
    FilterBar,
  },
  props: {
    selectedProjects: {
      type: Array,
      required: false,
      default: () => [],
    },
    showProjectFilter: {
      type: Boolean,
      required: false,
      default: true,
    },
    groupId: {
      type: Number,
      required: true,
    },
    groupPath: {
      type: String,
      required: true,
    },
    startDate: {
      type: String,
      required: true,
    },
    endDate: {
      type: String,
      required: true,
    },
  },
  computed: {
    projectsQueryParams() {
      return {
        first: PROJECTS_PER_PAGE,
        includeSubgroups: true,
      };
    },
  },
  multiProjectSelect: true,
  dateOptions: [7, 30, 90],
  maxDateRange: DATE_RANGE_LIMIT,
};
</script>
<template>
  <div class="gl-mt-3 gl-py-2 gl-px-3 bg-gray-light border-top border-bottom">
    <filter-bar
      v-if="shouldDisplayFilters"
      class="js-filter-bar filtered-search-box gl-display-flex gl-mb-2 gl-mr-3 gl-border-none"
      :group-path="groupPath"
    />
    <div
      v-if="shouldDisplayFilters"
      class="gl-display-flex gl-flex-direction-column gl-lg-flex-direction-row gl-justify-content-space-between"
    >
      <projects-dropdown-filter
        v-if="showProjectFilter"
        :key="groupId"
        class="js-projects-dropdown-filter project-select gl-mb-2 gl-lg-mb-0"
        :group-id="groupId"
        :group-namespace="groupPath"
        :query-params="projectsQueryParams"
        :multi-select="$options.multiProjectSelect"
        :default-projects="selectedProjects"
        @selected="$emit('onSelectProject')"
      />
      <date-range
        :start-date="startDate"
        :end-date="endDate"
        :max-date-range="$options.maxDateRange"
        :include-selected-date="true"
        class="js-daterange-picker"
        @change="$emit('onSetDateRange')"
      />
    </div>
  </div>
</template>
