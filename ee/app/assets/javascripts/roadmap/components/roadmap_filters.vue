<script>
import {
  GlFormGroup,
  GlSegmentedControl,
  GlDropdown,
  GlDropdownItem,
  GlDropdownDivider,
} from '@gitlab/ui';
import { mapState, mapActions } from 'vuex';

import { visitUrl, mergeUrlParams, updateHistory, setUrlParams } from '~/lib/utils/url_utility';
import { __ } from '~/locale';
import FilteredSearchBar from '~/vue_shared/components/filtered_search_bar/filtered_search_bar_root.vue';

import { EPICS_STATES, PRESET_TYPES } from '../constants';
import EpicsFilteredSearchMixin from '../mixins/filtered_search_mixin';

export default {
  epicStates: EPICS_STATES,
  availablePresets: [
    { text: __('Quarters'), value: PRESET_TYPES.QUARTERS },
    { text: __('Months'), value: PRESET_TYPES.MONTHS },
    { text: __('Weeks'), value: PRESET_TYPES.WEEKS },
  ],
  availableSortOptions: [
    {
      id: 1,
      title: __('Start date'),
      sortDirection: {
        descending: 'start_date_desc',
        ascending: 'start_date_asc',
      },
    },
    {
      id: 2,
      title: __('Due date'),
      sortDirection: {
        descending: 'end_date_desc',
        ascending: 'end_date_asc',
      },
    },
  ],
  components: {
    GlFormGroup,
    GlSegmentedControl,
    GlDropdown,
    GlDropdownItem,
    GlDropdownDivider,
    FilteredSearchBar,
  },
  mixins: [EpicsFilteredSearchMixin],
  computed: {
    ...mapState(['presetType', 'epicsState', 'sortedBy', 'filterParams']),
    selectedEpicStateTitle() {
      if (this.epicsState === EPICS_STATES.ALL) {
        return __('All epics');
      } else if (this.epicsState === EPICS_STATES.OPENED) {
        return __('Open epics');
      }
      return __('Closed epics');
    },
  },
  watch: {
    urlParams: {
      deep: true,
      immediate: true,
      handler(params) {
        if (Object.keys(params).length) {
          updateHistory({
            url: setUrlParams(params, window.location.href, true),
            title: document.title,
            replace: true,
          });
        }
      },
    },
  },
  methods: {
    ...mapActions(['setEpicsState', 'setFilterParams', 'setSortedBy', 'fetchEpics']),
    handleRoadmapLayoutChange(presetType) {
      visitUrl(mergeUrlParams({ layout: presetType }, window.location.href));
    },
    handleEpicStateChange(epicsState) {
      this.setEpicsState(epicsState);
      this.fetchEpics();
    },
    handleFilterEpics(filters) {
      this.setFilterParams(this.getFilterParams(filters));
      this.fetchEpics();
    },
    handleSortEpics(sortedBy) {
      this.setSortedBy(sortedBy);
      this.fetchEpics();
    },
  },
};
</script>

<template>
  <div class="epics-filters epics-roadmap-filters epics-roadmap-filters-gl-ui">
    <div
      class="epics-details-filters filtered-search-block gl-display-flex gl-flex-direction-column gl-xl-flex-direction-row row-content-block second-block"
    >
      <gl-form-group class="mb-0">
        <gl-segmented-control
          :checked="presetType"
          :options="$options.availablePresets"
          class="gl-display-flex d-xl-block"
          buttons
          @input="handleRoadmapLayoutChange"
        />
      </gl-form-group>
      <gl-dropdown
        :text="selectedEpicStateTitle"
        class="gl-my-2 my-xl-0 mx-xl-2"
        toggle-class="gl-rounded-small"
      >
        <gl-dropdown-item
          :is-check-item="true"
          :is-checked="epicsState === $options.epicStates.ALL"
          @click="handleEpicStateChange('all')"
          >{{ __('All epics') }}</gl-dropdown-item
        >
        <gl-dropdown-divider />
        <gl-dropdown-item
          :is-check-item="true"
          :is-checked="epicsState === $options.epicStates.OPENED"
          @click="handleEpicStateChange('opened')"
          >{{ __('Open epics') }}</gl-dropdown-item
        >
        <gl-dropdown-item
          :is-check-item="true"
          :is-checked="epicsState === $options.epicStates.CLOSED"
          @click="handleEpicStateChange('closed')"
          >{{ __('Closed epics') }}</gl-dropdown-item
        >
      </gl-dropdown>
      <filtered-search-bar
        :namespace="groupFullPath"
        :search-input-placeholder="__('Search or filter results...')"
        :tokens="getFilteredSearchTokens()"
        :sort-options="$options.availableSortOptions"
        :initial-filter-value="getFilteredSearchValue()"
        :initial-sort-by="sortedBy"
        recent-searches-storage-key="epics"
        class="gl-flex-grow-1"
        @onFilter="handleFilterEpics"
        @onSort="handleSortEpics"
      />
    </div>
  </div>
</template>
