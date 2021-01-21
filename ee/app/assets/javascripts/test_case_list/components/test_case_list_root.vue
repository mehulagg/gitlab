<script>
import { GlButton } from '@gitlab/ui';

import Api from '~/api';
import { s__, __ } from '~/locale';
import createFlash from '~/flash';
import axios from '~/lib/utils/axios_utils';
import { urlParamsToObject } from '~/lib/utils/common_utils';
import { updateHistory, setUrlParams } from '~/lib/utils/url_utility';

import IssuableList from '~/issuable_list/components/issuable_list_root.vue';
import AuthorToken from '~/vue_shared/components/filtered_search_bar/tokens/author_token.vue';
import LabelToken from '~/vue_shared/components/filtered_search_bar/tokens/label_token.vue';

import TestCaseListEmptyState from './test_case_list_empty_state.vue';

import projectTestCases from '../queries/project_test_cases.query.graphql';
import projectTestCasesCount from '../queries/project_test_cases_count.query.graphql';

import { TestCaseTabs, AvailableSortOptions, DEFAULT_PAGE_SIZE } from '../constants';

export default {
  name: 'TestCaseList',
  TestCaseTabs,
  AvailableSortOptions,
  defaultPageSize: DEFAULT_PAGE_SIZE,
  components: {
    GlButton,
    IssuableList,
    TestCaseListEmptyState,
  },
  inject: [
    'canCreateTestCase',
    'initialState',
    'page',
    'prev',
    'next',
    'initialSortBy',
    'projectFullPath',
    'projectLabelsPath',
    'testCaseNewPath',
  ],
  props: {
    initialFilterParams: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  apollo: {
    testCases: {
      query: projectTestCases,
      variables() {
        const queryVariables = {
          projectPath: this.projectFullPath,
          state: this.currentState,
          types: ['TEST_CASE'],
        };

        if (this.prevPageCursor) {
          queryVariables.prevPageCursor = this.prevPageCursor;
          queryVariables.lastPageSize = DEFAULT_PAGE_SIZE;
        } else if (this.nextPageCursor) {
          queryVariables.nextPageCursor = this.nextPageCursor;
          queryVariables.firstPageSize = DEFAULT_PAGE_SIZE;
        } else {
          queryVariables.firstPageSize = DEFAULT_PAGE_SIZE;
        }

        if (this.sortedBy) {
          queryVariables.sortBy = this.sortedBy;
        }

        if (Object.keys(this.filterParams).length) {
          Object.assign(queryVariables, {
            ...this.filterParams,
          });
        }

        return queryVariables;
      },
      update(data) {
        const testCasesRoot = data.project?.issues;

        return {
          list: testCasesRoot?.nodes || [],
          pageInfo: testCasesRoot?.pageInfo || {},
        };
      },
      error(error) {
        createFlash({
          message: s__('TestCases|Something went wrong while fetching test cases list.'),
          captureError: true,
          error,
        });
      },
    },
    testCasesCount: {
      query: projectTestCasesCount,
      variables() {
        return {
          projectPath: this.projectFullPath,
          types: ['TEST_CASE'],
        };
      },
      update(data) {
        const { opened, closed, all } = data.project?.issueStatusCounts;

        return {
          opened,
          closed,
          all,
        };
      },
      error(error) {
        createFlash({
          message: s__('TestCases|Something went wrong while fetching count of test cases.'),
          captureError: true,
          error,
        });
      },
    },
  },
  data() {
    return {
      currentState: this.initialState,
      currentPage: this.page,
      prevPageCursor: this.prev,
      nextPageCursor: this.next,
      filterParams: this.initialFilterParams,
      sortedBy: this.initialSortBy,
      testCases: {
        list: [],
        pageInfo: {},
      },
      testCasesCount: {
        opened: 0,
        closed: 0,
        all: 0,
      },
    };
  },
  computed: {
    testCaseListLoading() {
      return this.$apollo.queries.testCases.loading;
    },
    testCaseListEmpty() {
      return !this.$apollo.queries.testCases.loading && !this.testCases.list.length;
    },
    showPaginationControls() {
      const { hasPreviousPage, hasNextPage } = this.testCases.pageInfo;

      // This explicit check is necessary as both the variables
      // can also be `false` and we just want to ensure that they're present.
      if (hasPreviousPage !== undefined || hasNextPage !== undefined) {
        return Boolean(hasPreviousPage || hasNextPage);
      }
      return !this.testCaseListEmpty;
    },
    previousPage() {
      return Math.max(this.currentPage - 1, 0);
    },
    nextPage() {
      const nextPage = this.currentPage + 1;
      return nextPage > Math.ceil(this.testCasesCount[this.currentState] / DEFAULT_PAGE_SIZE)
        ? null
        : nextPage;
    },
  },
  methods: {
    updateUrl() {
      const queryParams = urlParamsToObject(window.location.search);
      const { authorUsername, labelName, search } = this.filterParams || {};
      const { currentState, sortedBy, currentPage, prevPageCursor, nextPageCursor } = this;

      queryParams.state = currentState;
      queryParams.sort = sortedBy;
      queryParams.page = currentPage || 1;

      // Only keep params that have any values.
      if (prevPageCursor) {
        queryParams.prev = prevPageCursor;
      } else {
        delete queryParams.prev;
      }

      if (nextPageCursor) {
        queryParams.next = nextPageCursor;
      } else {
        delete queryParams.next;
      }

      if (authorUsername) {
        queryParams.author_username = authorUsername;
      } else {
        delete queryParams.author_username;
      }

      delete queryParams.label_name;
      if (labelName?.length) {
        queryParams['label_name[]'] = labelName;
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
          fetchPath: this.projectFullPath,
          fetchAuthors: Api.projectUsers.bind(Api),
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
              include_ancestor_groups: true,
            };

            if (search) {
              params.search = search;
            }

            return axios.get(this.projectLabelsPath, {
              params,
            });
          },
        },
      ];
    },
    getFilteredSearchValue() {
      const { authorUsername, labelName, search } = this.filterParams || {};
      const filteredSearchValue = [];

      if (authorUsername) {
        filteredSearchValue.push({
          type: 'author_username',
          value: { data: authorUsername },
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

      if (search) {
        filteredSearchValue.push(search);
      }

      return filteredSearchValue;
    },
    handleClickTab(stateName) {
      this.currentState = stateName;

      this.updateUrl();
    },
    handlePageChange(page) {
      const { startCursor, endCursor } = this.testCases.pageInfo;

      if (page > this.currentPage) {
        this.prevPageCursor = '';
        this.nextPageCursor = endCursor;
      } else {
        this.prevPageCursor = startCursor;
        this.nextPageCursor = '';
      }

      this.currentPage = page;

      this.updateUrl();
    },
    handleFilterTestCases(filters = []) {
      const filterParams = {};
      const labels = [];
      const plainText = [];

      filters.forEach((filter) => {
        switch (filter.type) {
          case 'author_username':
            filterParams.authorUsername = filter.value.data;
            break;
          case 'label_name':
            labels.push(filter.value.data);
            break;
          case 'filtered-search-term':
            if (filter.value.data) plainText.push(filter.value.data);
            break;
          default:
            break;
        }
      });

      if (labels.length) {
        filterParams.labelName = labels;
      }

      if (plainText.length) {
        filterParams.search = plainText.join(' ');
      }

      this.filterParams = filterParams;

      this.updateUrl();
    },
    handleSortTestCases(sortedBy) {
      this.sortedBy = sortedBy;

      this.updateUrl();
    },
  },
};
</script>

<template>
  <issuable-list
    :namespace="projectFullPath"
    :tabs="$options.TestCaseTabs"
    :tab-counts="testCasesCount"
    :current-tab="currentState"
    :search-input-placeholder="s__('TestCases|Search test cases')"
    :search-tokens="getFilteredSearchTokens()"
    :sort-options="$options.AvailableSortOptions"
    :initial-filter-value="getFilteredSearchValue()"
    :initial-sort-by="sortedBy"
    :issuables="testCases.list"
    :issuables-loading="testCaseListLoading"
    :show-pagination-controls="showPaginationControls"
    :default-page-size="$options.defaultPageSize"
    :current-page="currentPage"
    :previous-page="previousPage"
    :next-page="nextPage"
    recent-searches-storage-key="test_cases"
    issuable-symbol="#"
    @click-tab="handleClickTab"
    @page-change="handlePageChange"
    @filter="handleFilterTestCases"
    @sort="handleSortTestCases"
  >
    <template v-if="canCreateTestCase" #nav-actions>
      <gl-button :href="testCaseNewPath" category="primary" variant="success">{{
        s__('TestCases|New test case')
      }}</gl-button>
    </template>
    <template #empty-state>
      <test-case-list-empty-state
        :current-state="currentState"
        :test-cases-count="testCasesCount"
      />
    </template>
  </issuable-list>
</template>
