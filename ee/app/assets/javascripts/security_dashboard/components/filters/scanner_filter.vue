// apollo call for specificFilter // handles visual implementation of new dropdown // data retrieval
// emit event of filter change // filters component // parse data/prepare data in here
<script>
import { groupBy, isEmpty } from 'lodash';
import {
  GlDropdown,
  GlDropdownDivider,
  GlDropdownHeader,
  GlSearchBoxByType,
  GlIcon,
} from '@gitlab/ui';

import projectSpecificScanners from '../../graphql/project_specific_scanners.query.graphql';
import { setReportTypeAndScannerFilter } from '../../store/modules/filters/utils';
import { parseSpecificFilters } from '../../utils/filters_utils';
import { modifyReportTypeFilter } from '../../helpers';

export default {
  components: {
    GlDropdown,
    GlDropdownDivider,
    GlDropdownHeader,
    GlSearchBoxByType,
    GlIcon,
  },
  apollo: {
    specificFilters: {
      query: projectSpecificScanners,
      variables() {
        return {
          fullPath: this.path,
        };
      },
      update: ({
        project: {
          vulnerabilityScanners: { nodes },
        },
      }) => parseSpecificFilters(nodes), // { GitLab: { DAST: [bunderler, gem], SAST:}, 3rdPart: {Dast: []}}
    },
  },
  props: {
    filter: {
      type: Object,
      required: true,
    },
    path: {
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
    processedFilter() {
      const test = isEmpty(this.specificFilters)
        ? this.filter
        : modifyReportTypeFilter(this.filter, this.specificFilters);
      return test;
    },
    filterId() {
      return this.processedFilter.id;
    },
    selection() {
      return this.processedFilter.selection;
    },
    firstSelectedOption() {
      return (
        this.processedFilter.options.find(option => this.selection.reportType.has(option.id))
          ?.name || '-'
      );
    },
    extraOptionCount() {
      return this.selection.size - 1;
    },
    filteredOptions() {
      const groupedOptions = groupBy(
        this.processedFilter.options.filter(option =>
          option.name.toLowerCase().includes(this.filterTerm.toLowerCase()),
        ),
        'vendor',
      );
      return Object.entries(groupedOptions).map(([vendor, options]) => ({ name: vendor, options }));
    },
    qaSelector() {
      return `filter_${this.processedFilter.name.toLowerCase().replace(' ', '_')}_dropdown`;
    },
  },
  methods: {
    clickFilter(option) {
      const filters = setReportTypeAndScannerFilter(this.filter, option);
      this.$emit('onFilterChange', [filters]);
    },
    isSelected(option) {
      let isSelected = false;
      Object.keys(this.selection).forEach(key => {
        if (!isSelected) {
          if (option.id === 'all') {
            isSelected = key === 'reportType' ? this.selection[key].has(option.id) : isSelected;
          } else {
            isSelected = this.selection[key].has(option.id);
          }
        }
      });
      return isSelected;
    },
    closeDropdown() {
      this.$refs.dropdown.$children[0].hide(true);
    },
  },
};
</script>

<template>
  <div class="dashboard-filter">
    <strong class="js-name">{{ processedFilter.name }}</strong>
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
        {{ processedFilter.name }}
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
        v-if="processedFilter.options.length >= 20"
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
          <gl-dropdown-divider />
          <gl-dropdown-header>{{ vendor.name }}</gl-dropdown-header>
          <button
            v-for="option in vendor.options"
            :key="option.displayName || option.id"
            role="menuitem"
            type="button"
            class="dropdown-item"
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
                :class="{ 'gl-pl-5': !isSelected(option) }"
              >
                {{ option.displayName || option.name }}
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
