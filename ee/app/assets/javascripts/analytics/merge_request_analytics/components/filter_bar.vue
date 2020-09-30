<script>
import { mapActions, mapState } from 'vuex';
import { getDateInPast } from '~/lib/utils/datetime_utility';
import { __ } from '~/locale';
import UrlSync from '~/vue_shared/components/url_sync.vue';
import FilteredSearchBar from '~/vue_shared/components/filtered_search_bar/filtered_search_bar_root.vue';
import BranchToken from '~/vue_shared/components/filtered_search_bar/tokens/branch_token.vue';
import MilestoneToken from '~/vue_shared/components/filtered_search_bar/tokens/milestone_token.vue';
import LabelToken from '~/vue_shared/components/filtered_search_bar/tokens/label_token.vue';
import AuthorToken from '~/vue_shared/components/filtered_search_bar/tokens/author_token.vue';
import {
  DEFAULT_LABEL_NONE,
  DEFAULT_LABEL_ANY,
} from '~/vue_shared/components/filtered_search_bar/constants';
import {
  prepareTokens,
  processFilters,
  filterToQueryObject,
} from '~/vue_shared/components/filtered_search_bar/filtered_search_utils';
import DateRange from '../../shared/components/daterange.vue';
import { DEFAULT_NUMBER_OF_DAYS } from '../constants';

export default {
  name: 'FilterBar',
  components: {
    DateRange,
    FilteredSearchBar,
    UrlSync,
  },
  inject: ['fullPath', 'type'],
  data() {
    return {
      startDate: getDateInPast(new Date(), DEFAULT_NUMBER_OF_DAYS),
      endDate: new Date(),
    };
  },
  computed: {
    ...mapState('filters', {
      selectedSourceBranch: state => state.branches.source.selected,
      selectedTargetBranch: state => state.branches.target.selected,
      selectedMilestone: state => state.milestones.selected,
      selectedAuthor: state => state.authors.selected,
      selectedAssignee: state => state.assignees.selected,
      selectedLabelList: state => state.labels.selectedList,
      milestonesData: state => state.milestones.data,
      labelsData: state => state.labels.data,
      assigneesData: state => state.assignees.data,
      authorsData: state => state.authors.data,
      branchesData: state => state.branches.data,
    }),
    tokens() {
      return [
        {
          icon: 'branch',
          title: __('Source Branch'),
          type: 'source_branch',
          token: BranchToken,
          initialBranches: this.branchesData,
          unique: true,
          operators: [{ value: '=', description: 'is', default: 'true' }],
          fetchBranches: this.fetchBranches,
        },
        {
          icon: 'branch',
          title: __('Target Branch'),
          type: 'target_branch',
          token: BranchToken,
          initialBranches: this.branchesData,
          unique: true,
          operators: [{ value: '=', description: 'is', default: 'true' }],
          fetchBranches: this.fetchBranches,
        },
        {
          icon: 'clock',
          title: __('Milestone'),
          type: 'milestone',
          token: MilestoneToken,
          initialMilestones: this.milestonesData,
          unique: true,
          symbol: '%',
          operators: [{ value: '=', description: 'is', default: 'true' }],
          fetchMilestones: this.fetchMilestones,
        },
        {
          icon: 'labels',
          title: __('Label'),
          type: 'labels',
          token: LabelToken,
          defaultLabels: [DEFAULT_LABEL_NONE, DEFAULT_LABEL_ANY],
          initialLabels: this.labelsData,
          unique: false,
          symbol: '~',
          operators: [{ value: '=', description: 'is', default: 'true' }],
          fetchLabels: this.fetchLabels,
        },
        {
          icon: 'pencil',
          title: __('Author'),
          type: 'author',
          token: AuthorToken,
          defaultAuthors: [],
          initialAuthors: this.authorsData,
          unique: true,
          operators: [{ value: '=', description: 'is', default: 'true' }],
          fetchAuthors: this.fetchAuthors,
        },
        {
          icon: 'user',
          title: __('Assignee'),
          type: 'assignee',
          token: AuthorToken,
          defaultAuthors: [],
          initialAuthors: this.assigneesData,
          unique: false,
          operators: [{ value: '=', description: 'is', default: 'true' }],
          fetchAuthors: this.fetchAssignees,
        },
      ];
    },
    query() {
      return filterToQueryObject({
        source_branch_name: this.selectedSourceBranch,
        target_branch_name: this.selectedTargetBranch,
        milestone_title: this.selectedMilestone,
        label_name: this.selectedLabelList,
        author_username: this.selectedAuthor,
        assignee_username: this.selectedAssignee,
        start_date: this.startDate,
        end_date: this.endDate,
      });
    },
    initialFilterValue() {
      return prepareTokens({
        source_branch: this.selectedSourceBranch,
        target_branch: this.selectedTargetBranch,
        milestone: this.selectedMilestone,
        author: this.selectedAuthor,
        assignee: this.selectedAssignee,
        labels: this.selectedLabelList,
      });
    },
  },
  methods: {
    ...mapActions('filters', [
      'setFilters',
      'fetchBranches',
      'fetchMilestones',
      'fetchAuthors',
      'fetchAssignees',
      'fetchLabels',
    ]),
    handleFilter(filters) {
      const {
        source_branch: sourceBranch,
        target_branch: targetBranch,
        milestone,
        author,
        assignee,
        labels,
      } = processFilters(filters);

      this.setFilters({
        selectedSourceBranch: sourceBranch ? sourceBranch[0] : null,
        selectedTargetBranch: targetBranch ? targetBranch[0] : null,
        selectedAuthor: author ? author[0] : null,
        selectedMilestone: milestone ? milestone[0] : null,
        selectedAssignee: assignee ? assignee[0] : null,
        selectedLabelList: labels || [],
      });
    },
    setDateRange() {},
  },
};
</script>

<template>
  <div class="gl-display-flex">
    <filtered-search-bar
      class="gl-flex-grow-1"
      :namespace="fullPath"
      recent-searches-storage-key="merge-request-analytics"
      :search-input-placeholder="__('Filter results')"
      :tokens="tokens"
      :initial-filter-value="initialFilterValue"
      @onFilter="handleFilter"
    />
    <date-range
      class="js-daterange-picker gl-ml-3"
      :start-date="startDate"
      :end-date="endDate"
      :max-date-range="$options.maxDateRange"
      :include-selected-date="true"
      @change="setDateRange"
    />
    <url-sync :query="query" />
  </div>
</template>
