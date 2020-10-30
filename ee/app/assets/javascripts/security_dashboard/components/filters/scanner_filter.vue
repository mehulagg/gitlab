<script>
import { GlDropdownDivider, GlDropdownItem, GlTruncate, GlLoadingIcon, GlIcon } from '@gitlab/ui';
import { assignWith, groupBy, union, uniq, without } from 'lodash';
import FilterBody from './filter_body.vue';
import FilterItem from './filter_item.vue';
import StandardFilter from './standard_filter.vue';
import { scannerFilter } from '../../helpers';
import projectSpecificScanners from '../../graphql/project_specific_scanners.query.graphql';
import groupSpecificScanners from '../../graphql/group_specific_scanners.query.graphql';
import instanceSpecificScanners from '../../graphql/instance_specific_scanners.query.graphql';
import createFlash from '~/flash';
import { s__ } from '~/locale';

export default {
  components: {
    GlDropdownDivider,
    GlDropdownItem,
    GlTruncate,
    GlLoadingIcon,
    GlIcon,
    FilterBody,
    FilterItem,
  },
  extends: StandardFilter,
  props: {
    queryPath: {
      type: String,
      required: true,
    },
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
        nodes = nodes.map(node => ({ ...node, id: `${node.externalId}.${node.reportType}` }));
        return groupBy(nodes, 'vendor');
      },
      error() {
        createFlash({
          message: s__('SecurityReports|Could not load scanner types. Please try again later.'),
        });
      },
    },
  },
  data() {
    return {
      customScanners: {},
    };
  },
  computed: {
    options() {
      const customerScannerOptions = Object.values(this.customScanners).flatMap(x => x);
      return this.filter.options.concat(customerScannerOptions);
    },
    filterObject() {
      const reportType = uniq(this.selectedOptions.map(x => x.reportType));
      const scanner = uniq(this.selectedOptions.map(x => x.externalId)).filter(x => Boolean(x));

      return { reportType, scanner };
    },
    queryType() {
      const { dashboardType } = this;
      if (dashboardType === 'project') return projectSpecificScanners;
      if (dashboardType === 'group') return groupSpecificScanners;
      return instanceSpecificScanners;
    },
    groups() {
      const defaultGroup = { GitLab: scannerFilter.options };
      // If the group already exists in defaultGroup, combine it with the one from customScanners.
      return assignWith(defaultGroup, this.customScanners, (original = [], updated) =>
        original.concat(updated),
      );
    },
  },
  watch: {
    customScanners() {
      // Update the selected options from the querystring when the custom scanners finish loading.
      this.selectedOptions = this.routeQueryOptions;
    },
  },
  methods: {
    toggleGroup(groupName) {
      const options = this.groups[groupName];
      // If every option is selected, de-select all of them. Otherwise, select all of them.
      if (options.every(this.selectedSet.has)) {
        this.selectedOptions = without(this.selectedOptions, ...options);
      } else {
        this.selectedOptions = union(this.selectedOptions, options);
      }

      this.updateRouteQuery();
    },
  },
};
</script>

<template>
  <filter-body
    v-model.trim="searchTerm"
    :name="filter.name"
    :selected-options="selectedOptionsOrAll"
    :show-search-box="showSearchBox"
  >
    <template v-if="$apollo.queries.customScanners.loading" #button-content>
      <gl-loading-icon />
      <gl-icon name="chevron-down" class="gl-flex-shrink-0 gl-ml-auto" />
    </template>

    <filter-item
      :text="filter.allOption.name"
      :is-checked="!selectedOptions.length"
      @click="deselectAllOptions"
    />

    <template v-for="[groupName, groupOptions] in Object.entries(groups)">
      <gl-dropdown-divider :key="`${groupName}:divider`" />

      <gl-dropdown-item
        :key="`${groupName}:header`"
        @click.native.capture.stop="toggleGroup(groupName)"
      >
        <gl-truncate class="gl-font-weight-bold" :text="groupName" />
      </gl-dropdown-item>

      <filter-item
        v-for="option in groupOptions"
        :key="option.id"
        :text="option.name"
        :is-checked="isSelected(option)"
        @click="toggleOption(option)"
      />
    </template>

    <gl-loading-icon v-if="$apollo.queries.customScanners.loading" class="gl-py-3" />
  </filter-body>
</template>
