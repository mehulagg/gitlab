<script>
import { groupBy } from 'lodash';
import { filters } from 'ee/security_dashboard/helpers';
import { BASE_FILTERS } from 'ee/security_dashboard/store/modules/filters/constants';
import DashboardFilter from './filter.vue';
import FilterOption from './filter_option.vue';
import projectSpecificScanners from '../../graphql/project_specific_scanners.query.graphql';
import groupSpecificScanners from '../../graphql/group_specific_scanners.query.graphql';
import instanceSpecificScanners from '../../graphql/instance_specific_scanners.query.graphql';

export default {
  inject: ['dashboardType'],
  components: {
    DashboardFilter,
    FilterOption,
  },
  apollo: {
    customScanners: {
      query() {
        return this.queryType;
      },
      variables() {
        return { fullPath: this.queryPath };
      },
      update(data) {
        const { nodes } = Object.values(data)[0].vulnerabilityScanners;
        const groups = groupBy(nodes, 'vendor');
        console.log('groups', groups);
        return groups;
      },
    },
  },
  props: {
    queryPath: {
      type: String,
      required: true,
    },
  },
  data: () => ({
    customScanners: {},
  }),
  computed: {
    queryType() {
      const { dashboardType } = this;
      if (dashboardType === 'project') return projectSpecificScanners;
      if (dashboardType === 'group') return groupSpecificScanners;
      return instanceSpecificScanners;
    },
    filter() {
      const { scannerFilter } = filters;
      console.log('trying map', this.customScanners);
      const customScanners = Object.values(this.customScanners)
        .flatMap(x => x)
        .map(x => ({
          id: x.externalId,
          name: x.name,
        }));

      console.log('custom scanners', customScanners, scannerFilter);

      customScanners.forEach(x => scannerFilter.options.push(x));

      console.log('final filter', scannerFilter);
      return scannerFilter;
    },
  },
  allOption: BASE_FILTERS.report_type,
};
</script>

<template>
  <dashboard-filter
    #default="{ isSelected, clickFilter }"
    :filter="filter"
    @setFilter="options => $emit('setFilter', options)"
  >
    <filter-option
      :display-name="$options.allOption.name"
      :is-selected="isSelected($options.allOption)"
      @click="clickFilter($options.allOption)"
    />
    <h2>{{ __('GitLab') }}</h2>
    <filter-option
      v-for="option in filter.options"
      :key="option.id"
      :display-name="option.name"
      :is-selected="isSelected(option)"
      @click="clickFilter(option)"
    />
  </dashboard-filter>
</template>
