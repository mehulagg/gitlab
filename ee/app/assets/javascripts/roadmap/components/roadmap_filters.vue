<script>
import { mapState, mapActions } from 'vuex';
import {
  GlFormGroup,
  GlSegmentedControl,
  GlDropdown,
  GlDropdownItem,
  GlDropdownDivider,
  GlFilteredSearchToken,
} from '@gitlab/ui';

import { __ } from '~/locale';
import Api from '~/api';
import axios from '~/lib/utils/axios_utils';
import { urlParamsToObject } from '~/lib/utils/common_utils';
import { visitUrl, mergeUrlParams, updateHistory, setUrlParams } from '~/lib/utils/url_utility';
import FilteredSearchBar from '~/vue_shared/components/filtered_search_bar/filtered_search_bar_root.vue';
import AuthorToken from '~/vue_shared/components/filtered_search_bar/tokens/author_token.vue';
import LabelToken from '~/vue_shared/components/filtered_search_bar/tokens/label_token.vue';
import MilestoneToken from '~/vue_shared/components/filtered_search_bar/tokens/milestone_token.vue';

import { EPICS_STATES, PRESET_TYPES } from '../constants';

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
  computed: {
    ...mapState([
      'presetType',
      'epicsState',
      'sortedBy',
      'fullPath',
      'groupLabelsEndpoint',
      'groupMilestonesEndpoint',
      'filterParams',
    ]),
    selectedEpicStateTitle() {
      if (this.epicsState === EPICS_STATES.ALL) {
        return __('All epics');
      } else if (this.epicsState === EPICS_STATES.OPENED) {
        return __('Open epics');
      }
      return __('Closed epics');
    },
  },
  methods: {
    ...mapActions(['setEpicsState', 'setFilterParams', 'setSortedBy', 'fetchEpics']),
    getFilteredSearchTokens() {
      return [
        {
          type: 'author_username',
          icon: 'user',
          title: __('Author'),
          unique: true,
          symbol: '@',
          token: AuthorToken,
          operators: [{ value: '=', description: __('is'), default: 'true' }],
          fetchAuthors: Api.users.bind(Api),
        },
        {
          type: 'label_name',
          icon: 'labels',
          title: __('Label'),
          unique: false,
          symbol: '~',
          token: LabelToken,
          operators: [{ value: '=', description: __('is'), default: 'true' }],
          fetchLabels: (search = '') => {
            const params = {
              only_group_labels: true,
              include_ancestor_groups: true,
              include_descendant_groups: true,
            };

            if (search) {
              params.search = search;
            }

            return axios.get(this.groupLabelsEndpoint, {
              params,
            });
          },
        },
        {
          type: 'milestone_title',
          icon: 'clock',
          title: __('Milestone'),
          unique: true,
          symbol: '%',
          token: MilestoneToken,
          operators: [{ value: '=', description: __('is'), default: 'true' }],
          fetchMilestones: (search = '') => {
            return axios.get(this.groupMilestonesEndpoint).then(({ data }) => {
              // TODO: Remove below condition check once either of the following is supported.
              // a) Milestones Private API supports search param.
              // b) Milestones Public API supports including child projects' milestones.
              if (search) {
                return {
                  data: data.filter((m) => m.title.toLowerCase().includes(search.toLowerCase())),
                };
              }
              return { data };
            });
          },
        },
        {
          type: 'confidential',
          icon: 'eye-slash',
          title: __('Confidential'),
          unique: true,
          token: GlFilteredSearchToken,
          operators: [{ value: '=', description: __('is'), default: 'true' }],
          options: [
            { icon: 'eye-slash', value: true, title: __('Yes') },
            { icon: 'eye', value: false, title: __('No') },
          ],
        },
      ];
    },
    getFilteredSearchValue() {
      const { authorUsername, labelName, milestoneTitle, confidential, search } =
        this.filterParams || {};
      const filteredSearchValue = [];

      if (authorUsername) {
        filteredSearchValue.push({
          type: 'author_username',
          value: { data: authorUsername },
        });
      }

      if (milestoneTitle) {
        filteredSearchValue.push({
          type: 'milestone_title',
          value: { data: milestoneTitle },
        });
      }

      if (labelName?.length) {
        filteredSearchValue.push(
          ...labelName.map((label) => ({
            type: 'label_name',
            value: { data: label },
          })),
        );
      }

      if (confidential !== undefined) {
        filteredSearchValue.push({
          type: 'confidential',
          value: { data: confidential },
        });
      }

      if (search) {
        filteredSearchValue.push(search);
      }

      return filteredSearchValue;
    },
    updateUrl() {
      const queryParams = urlParamsToObject(window.location.search);
      const { authorUsername, labelName, milestoneTitle, confidential, search } =
        this.filterParams || {};

      queryParams.state = this.epicsState;
      queryParams.sort = this.sortedBy;

      if (authorUsername) {
        queryParams.author_username = authorUsername;
      } else {
        delete queryParams.author_username;
      }

      if (milestoneTitle) {
        queryParams.milestone_title = milestoneTitle;
      } else {
        delete queryParams.milestone_title;
      }

      delete queryParams.label_name;
      if (labelName?.length) {
        queryParams['label_name[]'] = labelName;
      }

      if (confidential !== undefined) {
        queryParams.confidential = confidential;
      } else {
        delete queryParams.confidential;
      }

      if (search) {
        queryParams.search = search;
      } else {
        delete queryParams.search;
      }

      // We want to replace the history state so that back button
      // correctly reloads the page with previous URL.
      updateHistory({
        url: setUrlParams(queryParams, window.location.href, true),
        title: document.title,
        replace: true,
      });
    },
    handleRoadmapLayoutChange(presetType) {
      visitUrl(mergeUrlParams({ layout: presetType }, window.location.href));
    },
    handleEpicStateChange(epicsState) {
      this.setEpicsState(epicsState);
      this.fetchEpics();
      this.updateUrl();
    },
    handleFilterEpics(filters) {
      const filterParams = filters.length ? {} : null;
      const labels = [];

      filters.forEach((filter) => {
        if (typeof filter === 'object') {
          switch (filter.type) {
            case 'author_username':
              filterParams.authorUsername = filter.value.data;
              break;
            case 'milestone_title':
              filterParams.milestoneTitle = filter.value.data;
              break;
            case 'label_name':
              labels.push(filter.value.data);
              break;
            case 'confidential':
              filterParams.confidential = filter.value.data;
              break;
            default:
              break;
          }
        } else {
          filterParams.search = filter;
        }
      });

      if (labels.length) {
        filterParams.labelName = labels;
      }

      this.setFilterParams(filterParams);
      this.fetchEpics();
      this.updateUrl();
    },
    handleSortEpics(sortedBy) {
      this.setSortedBy(sortedBy);
      this.fetchEpics();
      this.updateUrl();
    },
  },
};
</script>

<template>
  <div class="epics-filters epics-roadmap-filters epics-roadmap-filters-gl-ui">
    <div
      class="epics-details-filters filtered-search-block gl-display-flex gl-flex-direction-column flex-xl-row row-content-block second-block"
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
        :namespace="fullPath"
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
