<script>
import { groupBy, cloneDeep } from 'lodash';
import { filters } from 'ee/security_dashboard/helpers';
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
    customScannerOptions() {
      return Object.values(this.customScanners)
        .flatMap(x => x)
        .map(x => ({
          id: x.externalId,
          name: x.name,
        }));
    },
    filterWithCustomScanners() {
      const scannerFilter = cloneDeep(filters.scannerFilter);
      scannerFilter.options = scannerFilter.options.concat(this.customScannerOptions);
      return scannerFilter;
    },
    groups() {
      const defaultGroup = { GitLab: filters.scannerFilter.options };
      return { ...defaultGroup, ...this.customScanners };
    },
  },
};
</script>

<template>
  <dashboard-filter
    #default="{ isSelected, clickFilter }"
    :filter="filterWithCustomScanners"
    @setFilter="options => $emit('setFilter', options)"
  >
    <template v-for="[groupName, options] in groups">
      <h2 :key="groupName">{{ groupName }}</h2>
      <filter-option
        v-for="option in options"
        :key="option.id || option.externalId"
        :display-name="option.name"
        :is-selected="isSelected(option)"
        @click="clickFilter(option)"
      />
    </template>
  </dashboard-filter>
</template>
