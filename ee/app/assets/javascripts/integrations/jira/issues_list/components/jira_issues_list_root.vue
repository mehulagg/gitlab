<script>
import jiraLogo from '@gitlab/svgs/dist/illustrations/logos/jira.svg';
import { GlButton, GlIcon, GlLink, GlSprintf, GlSafeHtmlDirective as SafeHtml } from '@gitlab/ui';

import createFlash from '~/flash';
import IssuableList from '~/issuable_list/components/issuable_list_root.vue';
import {
  IssuableStates,
  IssuableListTabs,
  AvailableSortOptions,
  DEFAULT_PAGE_SIZE,
} from '~/issuable_list/constants';
import axios from '~/lib/utils/axios_utils';
import { convertObjectPropsToCamelCase } from '~/lib/utils/common_utils';

import { __ } from '~/locale';
import JiraIssuesListEmptyState from './jira_issues_list_empty_state.vue';

export default {
  name: 'JiraIssuesList',
  IssuableListTabs,
  AvailableSortOptions,
  defaultPageSize: DEFAULT_PAGE_SIZE,
  components: {
    GlButton,
    GlIcon,
    GlLink,
    GlSprintf,
    IssuableList,
    JiraIssuesListEmptyState,
  },
  directives: {
    SafeHtml,
  },
  inject: [
    'initialState',
    'initialSortBy',
    'page',
    'issuesFetchPath',
    'projectFullPath',
    'issueCreateUrl',
  ],
  props: {
    initialFilterParams: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  data() {
    return {
      jiraLogo,
      issues: [],
      issuesListLoading: false,
      issuesListLoadFailed: false,
      totalIssues: 0,
      currentState: this.initialState,
      filterParams: this.initialFilterParams,
      sortedBy: this.initialSortBy,
      currentPage: this.page,
      issuesCount: {
        [IssuableStates.Opened]: 0,
        [IssuableStates.Closed]: 0,
        [IssuableStates.All]: 0,
      },
    };
  },
  computed: {
    showPaginationControls() {
      return Boolean(
        !this.issuesListLoading &&
          !this.issuesListLoadFailed &&
          this.issues.length &&
          this.totalIssues > 1,
      );
    },
    hasFiltersApplied() {
      return Boolean(this.filterParams.search || this.filterParams.labels);
    },
    urlParams() {
      return {
        state: this.currentState,
        page: this.currentPage,
        sort: this.sortedBy,
        'labels[]': this.filterParams.labels,
        search: this.filterParams.search,
      };
    },
  },
  mounted() {
    this.fetchIssues();
  },
  methods: {
    fetchIssues() {
      this.issuesListLoading = true;
      this.issuesListLoadFailed = false;
      return axios
        .get(this.issuesFetchPath, {
          params: {
            with_labels_details: true,
            page: this.currentPage,
            per_page: this.$options.defaultPageSize,
            state: this.currentState,
            sort: this.sortedBy,
            labels: this.filterParams.labels,
            search: this.filterParams.search,
          },
        })
        .then((res) => {
          const { headers, data } = res;
          this.currentPage = parseInt(headers['x-page'], 10);
          this.totalIssues = parseInt(headers['x-total'], 10);
          this.issues = data.map((rawIssue, index) => {
            const issue = convertObjectPropsToCamelCase(rawIssue, { deep: true });

            return {
              ...issue,
              // JIRA issues don't have ID so we extract
              // an ID equivalent from references.relative
              id: parseInt(rawIssue.references.relative.split('-').pop(), 10),
              author: {
                ...issue.author,
                id: index,
              },
            };
          });
          this.issuesCount[this.currentState] = this.issues.length;
        })
        .catch((error) => {
          this.issuesListLoadFailed = true;
          createFlash({
            message: __('An error occurred while loading issues'),
            captureError: true,
            error,
          });
        })
        .finally(() => {
          this.issuesListLoading = false;
        });
    },
    getFilteredSearchValue() {
      return [
        {
          type: 'filtered-search-term',
          value: {
            data: this.filterParams.search || '',
          },
        },
      ];
    },
    fetchIssuesBy(propsName, propValue) {
      this[propsName] = propValue;
      this.fetchIssues();
    },
    handleFilterIssues(filters = []) {
      const filterParams = {};
      const plainText = [];

      filters.forEach((filter) => {
        if (filter.type === 'filtered-search-term' && filter.value.data) {
          plainText.push(filter.value.data);
        }
      });

      if (plainText.length) {
        filterParams.search = plainText.join(' ');
      }

      this.filterParams = filterParams;
      this.fetchIssues();
    },
  },
};
</script>

<template>
  <issuable-list
    :namespace="projectFullPath"
    :tabs="$options.IssuableListTabs"
    :current-tab="currentState"
    :search-input-placeholder="s__('Integrations|Search Jira issues')"
    :search-tokens="[]"
    :sort-options="$options.AvailableSortOptions"
    :initial-filter-value="getFilteredSearchValue()"
    :initial-sort-by="sortedBy"
    :issuables="issues"
    :issuables-loading="issuesListLoading"
    :show-pagination-controls="showPaginationControls"
    :default-page-size="$options.defaultPageSize"
    :total-items="totalIssues"
    :current-page="currentPage"
    :previous-page="currentPage - 1"
    :next-page="currentPage + 1"
    :url-params="urlParams"
    label-filter-param="labels"
    recent-searches-storage-key="jira_issues"
    @click-tab="fetchIssuesBy('currentState', $event)"
    @page-change="fetchIssuesBy('currentPage', $event)"
    @sort="fetchIssuesBy('sortedBy', $event)"
    @filter="handleFilterIssues"
  >
    <template #nav-actions>
      <gl-button :href="issueCreateUrl" target="_blank" class="gl-my-5"
        >{{ s__('Integrations|Create new issue in Jira') }}<gl-icon name="external-link"
      /></gl-button>
    </template>
    <template #reference="{ issuable }">
      <span v-safe-html="jiraLogo" class="svg-container jira-logo-container"></span>
      <span>{{ issuable.references.relative }}</span>
    </template>
    <template #author="{ author }">
      <gl-sprintf message="%{authorName} in Jira">
        <template #authorName>
          <gl-link class="author-link js-user-link" target="_blank" :href="author.webUrl"
            >{{ author.name }}
          </gl-link>
        </template>
      </gl-sprintf>
    </template>
    <template #status="{ issuable }">
      {{ issuable.status }}
    </template>
    <template #empty-state>
      <jira-issues-list-empty-state
        :current-state="currentState"
        :issues-count="issuesCount"
        :has-filters-applied="hasFiltersApplied"
      />
    </template>
  </issuable-list>
</template>
