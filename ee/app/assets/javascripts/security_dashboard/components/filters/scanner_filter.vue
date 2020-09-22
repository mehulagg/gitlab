<script>
import { get, groupBy } from 'lodash';
import {
  GlDropdown,
  GlDropdownDivider,
  GlDropdownSectionHeader,
  GlSearchBoxByType,
  GlIcon,
} from '@gitlab/ui';

import { ALL } from '../../store/modules/filters/constants';
import { setFilter, createScannerSelection } from '../../store/modules/filters/utils';
import { parseSpecificFilters } from '../../utils/filters_utils';
import { modifyReportTypeFilter } from '../../helpers';
import projectSpecificScanners from '../../graphql/project_specific_scanners.query.graphql';
import groupSpecificScanners from '../../graphql/group_specific_scanners.query.graphql';
import instanceSpecificScanners from '../../graphql/instance_specific_scanners.query.graphql';

export default {
  inject: ['dashboardType'],
  scannerFilterConfigs: {
    project: {
      query: projectSpecificScanners,
      pathToNodes: ['project', 'vulnerabilityScanners', 'nodes'],
    },
    group: {
      query: groupSpecificScanners,
      pathToNodes: ['group', 'vulnerabilityScanners', 'nodes'],
    },
    instance: {
      query: instanceSpecificScanners,
      pathToNodes: ['instanceSecurityDashboard', 'vulnerabilityScanners', 'nodes'],
    },
  },
  components: {
    GlDropdown,
    GlDropdownDivider,
    GlDropdownSectionHeader,
    GlSearchBoxByType,
    GlIcon,
  },
  apollo: {
    specificFilters: {
      query() {
        return this.$options.scannerFilterConfigs[this.dashboardType].query;
      },
      variables() {
        return {
          fullPath: this.queryPath,
        };
      },
      update(data) {
        const path = this.$options.scannerFilterConfigs[this.dashboardType].pathToNodes;
        const nodes = get(data, path);
        return parseSpecificFilters(nodes);
      },
    },
  },
  props: {
    filter: {
      type: Object,
      required: true,
    },
    queryPath: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      filterTerm: '',
      specificFilters: {},
    };
  },
  computed: {
    filterId() {
      return this.filter.id;
    },
    selection() {
      return this.filter.idSelection;
    },
    firstSelectedOption() {
      return this.filter.options.find(option => this.selection.has(option.id))?.name || '-';
    },
    extraOptionCount() {
      return this.selection.size - 1;
    },
    filteredOptions() {
      const groupedOptions = groupBy(
        this.filter.options.filter(option =>
          option.name.toLowerCase().includes(this.filterTerm.toLowerCase()),
        ),
        'vendor',
      );
      return Object.entries(groupedOptions).map(([vendor, options]) => ({ name: vendor, options }));
    },
    qaSelector() {
      return `filter_${this.filter.name.toLowerCase().replace(' ', '_')}_dropdown`;
    },
  },
  watch: {
    specificFilters(newSpecificFilters) {
      const filter = modifyReportTypeFilter(this.filter, newSpecificFilters);
      this.$emit('onFilterChange', [{ ...filter }]);
    },
  },
  methods: {
    clickFilter(option) {
      const filter = setFilter([{ ...this.filter, selection: this.selection }], {
        optionId: option.id,
        filterId: this.filter.id,
      });
      const updatedSelection = createScannerSelection(filter[0].selection, filter[0].options);
      this.$emit('onFilterChange', [{ ...filter[0], selection: updatedSelection }]);
    },
    isNotVendorAll(vendor) {
      return vendor.name !== ALL;
    },
    isDisabled(option) {
      return option.id !== ALL && !option.scanners?.length;
    },
    isSelected(option) {
      return this.selection.has(option.id);
    },
    closeDropdown() {
      this.$refs.dropdown.$children[0].hide(true);
    },
  },
};
</script>

<template>
  <div class="dashboard-filter">
    <strong class="js-name">{{ filter.name }}</strong>
    <gl-dropdown
      ref="dropdown"
      class="d-block mt-1"
      menu-class="dropdown-extended-height"
      toggle-class="d-flex w-100 justify-content-between align-items-center"
    >
      <template slot="button-content">
        <span class="text-truncate" :data-qa-selector="qaSelector">
          {{ firstSelectedOption }}
        </span>
        <span v-if="extraOptionCount" class="flex-grow-1 ml-1">
          {{ n__('+%d more', '+%d more', extraOptionCount) }}
        </span>
        <i class="fa fa-chevron-down" aria-hidden="true"></i>
      </template>

      <div class="dropdown-title mb-0">
        {{ filter.name }}
        <button
          ref="close"
          class="btn-blank float-right"
          type="button"
          :aria-label="__('Close')"
          @click="closeDropdown"
        >
          <gl-icon name="close" aria-hidden="true" class="vertical-align-middle" />
        </button>
      </div>

      <gl-search-box-by-type
        v-if="filter.options.length >= 20"
        ref="searchBox"
        v-model="filterTerm"
        class="gl-m-3"
        :placeholder="__('Filter...')"
      />

      <div
        data-qa-selector="filter_dropdown_content"
        :class="{ 'dropdown-content': filterId === 'project_id' }"
      >
        <span v-for="vendor in filteredOptions" :key="vendor.name">
          <gl-dropdown-divider v-if="isNotVendorAll(vendor)" />
          <gl-dropdown-section-header v-if="isNotVendorAll(vendor)">{{
            vendor.name
          }}</gl-dropdown-section-header>
          <button
            v-for="option in vendor.options"
            :key="option.id"
            role="menuitem"
            type="button"
            class="dropdown-item"
            :class="{ 'gl-pointer-events-all': isDisabled(option) }"
            :disabled="isDisabled(option)"
            @click="clickFilter(option)"
          >
            <span class="d-flex">
              <gl-icon
                v-if="isSelected(option)"
                class="flex-shrink-0 js-check"
                name="mobile-issue-close"
              />
              <span
                class="gl-white-space-nowrap gl-ml-2"
                :class="{ 'gl-pl-5': !isSelected(option), 'gl-text-gray-300': isDisabled(option) }"
              >
                {{ option.name }}
              </span>
            </span>
          </button>
        </span>
      </div>

      <button
        v-if="filteredOptions.length === 0"
        type="button"
        class="dropdown-item no-pointer-events text-secondary"
      >
        {{ __('No matching results') }}
      </button>
    </gl-dropdown>
  </div>
</template>
