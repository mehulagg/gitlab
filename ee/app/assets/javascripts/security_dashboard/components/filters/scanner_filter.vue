// apollo call for specificFilter // handles visual implementation of new dropdown // data retrieval
// emit event of filter change // filters component // parse data/prepare data in here
<script>
import { isEmpty } from 'lodash';
import {
  GlDropdown,
  GlDropdownDivider,
  GlDropdownHeader,
  GlSearchBoxByType,
  GlIcon,
} from '@gitlab/ui';

import projectSpecificScanners from '../../graphql/project_specific_scanners.query.graphql';
import { setFilter } from '../../store/modules/filters/utils';
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
      return this.processedFilter.options.reduce((acc, curr) => {
        return curr.options.find(option => this.selection.has(option.id))?.name || acc;
      }, '-');
    },
    extraOptionCount() {
      return this.selection.size - 1;
    },
    filteredOptions() {
      const test = this.processedFilter.options.map(group => {
        const newGroup = { ...group };
        newGroup.options = group.options.filter(option =>
          option.name.toLowerCase().includes(this.filterTerm.toLowerCase()),
        );
        return newGroup;
      });
      return test;
    },
    qaSelector() {
      return `filter_${this.processedFilter.name.toLowerCase().replace(' ', '_')}_dropdown`;
    },
  },
  methods: {
    prepareData() {
      console.log('prepareData:');
      return null;
    },
    clickFilter(option) {
      // setFilter
      const filters = setFilter([this.filter], option);
      console.log('filters:', filters);
      this.$emit('onFilterChange', filters);
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
        :placeholder="__('processedFilter...')"
      />

      <div
        data-qa-selector="filter_dropdown_content"
        :class="{ 'dropdown-content': filterId === 'project_id' }"
      >
        <span v-for="vendor in filteredOptions" :key="vendor.name">
          <gl-dropdown-divider />
          <gl-dropdown-header>{{ vendor.title }}</gl-dropdown-header>
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
