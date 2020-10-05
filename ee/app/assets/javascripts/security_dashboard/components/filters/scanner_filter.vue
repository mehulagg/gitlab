<script>
import { GlDropdownDivider, GlDropdownSectionHeader } from '@gitlab/ui';
import { assignWith, cloneDeep, groupBy } from 'lodash';
import { scannerFilter } from 'ee/security_dashboard/helpers';
import DashboardFilter from './filter.vue';
import FilterOption from './filter_option.vue';
import projectSpecificScanners from '../../graphql/project_specific_scanners.query.graphql';
import groupSpecificScanners from '../../graphql/group_specific_scanners.query.graphql';
import instanceSpecificScanners from '../../graphql/instance_specific_scanners.query.graphql';

export default {
  components: {
    GlDropdownSectionHeader,
    GlDropdownDivider,
    DashboardFilter,
    FilterOption,
  },
  inject: ['dashboardType'],
  apollo: {
    customScanners: {
      query() {
        return this.queryType;
      },
      variables() {
        return { fullPath: this.queryPath };
      },
      update(data) {
        let { nodes } = Object.values(data)[0].vulnerabilityScanners;
        nodes = nodes.map(node => ({ ...node, queryId: `${node.externalId}:${node.reportType}` }));
        const groups = groupBy(nodes, 'vendor');
        console.log('custom scanner groups', groups);
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
  data() {
    return {
      customScanners: {},
      selectedOptions: this.getSelectedOptions(),
    };
  },
  computed: {
    queryType() {
      const { dashboardType } = this;
      if (dashboardType === 'project') return projectSpecificScanners;
      if (dashboardType === 'group') return groupSpecificScanners;
      return instanceSpecificScanners;
    },
    filterWithCustomScanners() {
      const customScannerOptions = Object.values(this.customScanners).flatMap(x => x);

      const filter = cloneDeep(scannerFilter);
      filter.options = filter.options.concat(customScannerOptions);
      return filter;
    },
    groups() {
      const defaultGroup = { GitLab: scannerFilter.options };
      // If the group already exists, combine the one in defaultGroup with the one in customScanners.
      return assignWith(defaultGroup, this.customScanners, (original = [], updated) =>
        original.concat(updated),
      );
    },
  },
  watch: {
    selectedOptions() {
      const reportType = [];
      const scanner = [];
      const selectedOptions = Object.values(this.selectedOptions);

      selectedOptions.forEach(option => {
        reportType.push(option.reportType);
        scanner.push(option.externalId);
      });

      this.$router.push({ query: { [scannerFilter.id]: selectedOptions.map(x => x.queryId) } });
      this.$emit('filter-changed', { reportType, scanner });
    },
  },
  methods: {
    getSelectedOptions() {
      const values = this.$route.query[scannerFilter.id];
      const valueArray = Array.isArray(values) ? values : [values];
      const definedArray = valueArray.filter(x => x !== undefined);
      const selected = {};

      definedArray.forEach(x => {
        selected[x] = true;
      });

      return selected;
    },
    toggleFilter(option) {
      console.log('option', option);
      const { queryId } = option;
      if (this.selectedOptions[queryId]) {
        this.$delete(this.selectedOptions, queryId);
      } else {
        this.$set(this.selectedOptions, queryId, option);
      }
    },
    isSelected(option) {
      return Boolean(this.selectedOptions[option.queryId]);
    },
  },
};
</script>

<template>
  <dashboard-filter :filter="filterWithCustomScanners">
    <template v-for="[groupName, options] in Object.entries(groups)">
      <gl-dropdown-divider :key="`${groupName}:divider`" />
      <gl-dropdown-section-header :key="`${groupName}:header`">
        {{ groupName }}
      </gl-dropdown-section-header>
      <filter-option
        v-for="option in options"
        :key="option.queryId"
        :display-name="option.name"
        :is-selected="isSelected(option)"
        @click="toggleFilter(option)"
      />
    </template>
  </dashboard-filter>
</template>
