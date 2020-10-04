<script>
import { GlAlert, GlBadge, GlPagination, GlTab, GlTabs } from '@gitlab/ui';
import Api from '~/api';
import Tracking from '~/tracking';
import { __ } from '~/locale';
import { urlParamsToObject } from '~/lib/utils/common_utils';
import { updateHistory, setUrlParams } from '~/lib/utils/url_utility';
import { initialPaginationState } from './constants';
import FilteredSearchBar from '~/vue_shared/components/filtered_search_bar/filtered_search_bar_root.vue';
import AuthorToken from '~/vue_shared/components/filtered_search_bar/tokens/author_token.vue';

export default {
  components: {
    GlAlert,
    GlBadge,
    GlPagination,
    GlTabs,
    GlTab,
    FilteredSearchBar,
  },
  inject: ['projectPath'],
  props: {
    items: {
      type: Array,
      required: true,
    },
    itemsCount: {
      type: Object,
      required: true,
    },
    pageInfo: {
      type: Object,
      required: false,
      default: () => {},
    },
    statusTabs: {
      type: Array,
      required: true,
    },
    loading: {
      type: Boolean,
      required: true,
    },
    showItems: {
      type: Boolean,
      required: true,
    },
    showErrorMsg: {
      type: Boolean,
      required: true,
    },
    trackViewsOptions: {
      type: Object,
      required: true,
    },
    i18n: {
      type: Object,
      required: true,
    },
  },
  data() {
    return {
      searchTerm: '',
      authorUsername: '',
      assigneeUsernames: '',
      filterParams: {},
      pagination: initialPaginationState,
      filteredByStatus: '',
      statusFilter: '',
    };
  },
  computed: {
    filteredSearchTokens() {
      return [
        {
          type: 'author_username',
          icon: 'user',
          title: __('Author'),
          unique: true,
          symbol: '@',
          token: AuthorToken,
          operators: [{ value: '=', description: __('is'), default: 'true' }],
          fetchPath: this.projectPath,
          fetchAuthors: Api.projectUsers.bind(Api),
        },
        {
          type: 'assignee_username',
          icon: 'user',
          title: __('Assignees'),
          unique: true,
          symbol: '@',
          token: AuthorToken,
          operators: [{ value: '=', description: __('is'), default: 'true' }],
          fetchPath: this.projectPath,
          fetchAuthors: Api.projectUsers.bind(Api),
        },
      ];
    },
    filteredSearchValue() {
      const value = [];

      if (this.authorUsername) {
        value.push({
          type: 'author_username',
          value: { data: this.authorUsername },
        });
      }

      if (this.assigneeUsernames) {
        value.push({
          type: 'assignee_username',
          value: { data: this.assigneeUsernames },
        });
      }

      if (this.searchTerm) {
        value.push(this.searchTerm);
      }

      return value;
    },
    itemsForCurrentTab() {
      return this.itemsCount?.[this.filteredByStatus.toLowerCase()] ?? 0;
    },
    showPaginationControls() {
      return Boolean(this.pageInfo?.hasNextPage || this.pageInfo?.hasPreviousPage);
    },
    previousPage() {
      return Math.max(this.pagination.page - 1, 0);
    },
    nextPage() {
      const nextPage = this.pagination.page + 1;
      return nextPage > Math.ceil(this.itemsForCurrentTab / 10) ? null : nextPage;
    },
  },
  methods: {
    filterItemsByStatus(tabIndex) {
      this.resetPagination();
      const { filters, status } = this.statusTabs[tabIndex];
      this.statusFilter = filters;
      this.filteredByStatus = status;

      this.$emit('status-changed', { filters, status });
    },
    handlePageChange(page) {
      const { startCursor, endCursor } = this.pageInfo;

      if (page > this.pagination.page) {
        this.pagination = {
          ...initialPaginationState,
          nextPageCursor: endCursor,
          page,
        };
      } else {
        this.pagination = {
          lastPageSize: 10,
          firstPageSize: null,
          prevPageCursor: startCursor,
          nextPageCursor: '',
          page,
        };
      }

      this.$emit('page-changed', this.pagination);
    },
    resetPagination() {
      this.pagination = initialPaginationState;
      this.$emit('page-changed', this.pagination);
    },
    handleFilterIncidents(filters) {
      this.resetPagination();
      const filterParams = { authorUsername: '', assigneeUsername: '', search: '' };

      filters.forEach(filter => {
        if (typeof filter === 'object') {
          switch (filter.type) {
            case 'author_username':
              filterParams.authorUsername = filter.value.data;
              break;
            case 'assignee_username':
              filterParams.assigneeUsername = filter.value.data;
              break;
            case 'filtered-search-term':
              if (filter.value.data !== '') filterParams.search = filter.value.data;
              break;
            default:
              break;
          }
        }
      });

      this.filterParams = filterParams;
      this.updateUrl();
      this.searchTerm = filterParams?.search;
      this.authorUsername = filterParams?.authorUsername;
      this.assigneeUsernames = filterParams?.assigneeUsername;

      this.$emit('filters-changed', {
        searchTerm: this.searchTerm,
        authorUsername: this.authorUsername,
        assigneeUsernames: this.assigneeUsernames,
      });
    },
    updateUrl() {
      const queryParams = urlParamsToObject(window.location.search);
      const { authorUsername, assigneeUsername, search } = this.filterParams || {};

      if (authorUsername) {
        queryParams.author_username = authorUsername;
      } else {
        delete queryParams.author_username;
      }

      if (assigneeUsername) {
        queryParams.assignee_username = assigneeUsername;
      } else {
        delete queryParams.assignee_username;
      }

      if (search) {
        queryParams.search = search;
      } else {
        delete queryParams.search;
      }

      updateHistory({
        url: setUrlParams(queryParams, window.location.href, true),
        title: document.title,
        replace: true,
      });
    },
    methods: {
      trackPageViews() {
        const { category, action } = this.trackViewsOptions;
        Tracking.event(category, action);
      },
    },
  },
};
</script>
<template>
  <div class="incident-management-list">
    <gl-alert v-if="showErrorMsg" variant="danger" @dismiss="$emit('error-alert-dismissed')">
      {{ i18n.errorMsg }}
    </gl-alert>

    <div
      class="incident-management-list-header gl-display-flex gl-justify-content-space-between gl-border-b-solid gl-border-b-1 gl-border-gray-100"
    >
      <gl-tabs content-class="gl-p-0" @input="filterItemsByStatus">
        <gl-tab v-for="tab in statusTabs" :key="tab.status" :data-testid="tab.status">
          <template #title>
            <span>{{ tab.title }}</span>
            <gl-badge v-if="itemsCount" pill size="sm" class="gl-tab-counter-badge">
              {{ itemsCount[tab.status.toLowerCase()] }}
            </gl-badge>
          </template>
        </gl-tab>
      </gl-tabs>

      <slot v-if="!loading" name="header-actions"></slot>
    </div>

    <div class="filtered-search-wrapper">
      <filtered-search-bar
        :namespace="projectPath"
        :search-input-placeholder="i18n.searchPlaceholder"
        :tokens="filteredSearchTokens"
        :initial-filter-value="filteredSearchValue"
        initial-sortby="created_desc"
        recent-searches-storage-key="incidents"
        class="row-content-block"
        @onFilter="handleFilterIncidents"
      />
    </div>

    <h4 class="gl-display-block d-md-none my-3">
      <slot v-if="!loading" name="title"></slot>
    </h4>

    <slot v-if="showItems" name="table"></slot>

    <gl-pagination
      v-if="showPaginationControls"
      :value="pagination.page"
      :prev-page="previousPage"
      :next-page="nextPage"
      align="center"
      class="gl-pagination gl-mt-3"
      @input="handlePageChange"
    />

    <slot v-if="!showItems" name="emtpy-state"></slot>
  </div>
</template>
