<script>
import { GlDropdownDivider, GlDropdownItem, GlTruncate, GlLoadingIcon, GlIcon } from '@gitlab/ui';
import { assignWith, groupBy, union, uniq, without } from 'lodash';
import FilterBody from './filter_body.vue';
import FilterItem from './filter_item.vue';
import StandardFilter from './standard_filter.vue';
import createFlash from '~/flash';
import { s__ } from '~/locale';
import { scannerFilterResultsKeyMap, dashboardTypeQuery } from '../../constants';

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
    fullPath: {
      type: String,
      required: false,
      default: '',
    },
  },
  inject: ['dashboardType'],
  apollo: {
    customScanners: {
      query() {
        return dashboardTypeQuery[this.dashboardType];
      },
      variables() {
        return { fullPath: this.fullPath };
      },
      update(data) {
        let nodes = data[this.scannerFilterResultsKey]?.vulnerabilityScanners.nodes;
        nodes = nodes?.map(node => ({ ...node, id: `${node.externalId}.${node.reportType}` }));
        return groupBy(nodes, 'vendor');
      },
      error() {
        createFlash({
          message: s__(
            'Could not retrieve custom scanners for scanner filter. Please try again later.',
          ),
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
      const scanner = uniq(this.selectedOptions.map(x => x.externalId));

      return { reportType, scanner };
    },
    groups() {
      const defaultGroup = { GitLab: this.filter.options };
      // If the group already exists in defaultGroup, combine it with the one from customScanners.
      return assignWith(defaultGroup, this.customScanners, (original = [], updated) =>
        original.concat(updated),
      );
    },
    scannerFilterResultsKey() {
      return scannerFilterResultsKeyMap[this.dashboardType];
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
      if (options.every(option => this.selectedSet.has(option))) {
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
      data-testid="allOption"
      @click="deselectAllOptions"
    />

    <template v-for="[groupName, groupOptions] in Object.entries(groups)">
      <gl-dropdown-divider :key="`${groupName}:divider`" />

      <gl-dropdown-item
        :key="`${groupName}:header`"
        :data-testid="`${groupName}Header`"
        @click.native.capture.stop="toggleGroup(groupName)"
      >
        <gl-truncate class="gl-font-weight-bold" :text="groupName" />
      </gl-dropdown-item>

      <filter-item
        v-for="option in groupOptions"
        :key="option.id"
        :text="option.name"
        data-testid="option"
        :is-checked="isSelected(option)"
        @click="toggleOption(option)"
      />
    </template>

    <gl-loading-icon v-if="$apollo.queries.customScanners.loading" class="gl-py-3" />
  </filter-body>
</template>
