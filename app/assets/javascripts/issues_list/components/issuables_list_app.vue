<script>
import { toNumber, omit } from 'lodash';
import {
  GlPagination,
  GlDeprecatedSkeletonLoading as GlSkeletonLoading,
} from '@gitlab/ui';
import { deprecatedCreateFlash as flash } from '~/flash';
import axios from '~/lib/utils/axios_utils';
import {
  scrollToElement,
  urlParamsToObject,
  historyPushState,
  getParameterByName,
} from '~/lib/utils/common_utils';
import { __ } from '~/locale';
import initManualOrdering from '~/manual_ordering';
import Issuable from './issuable.vue';
import FilteredSearchBar from '~/vue_shared/components/filtered_search_bar/filtered_search_bar_root.vue';
import {
  SortOrderMap,
  RELATIVE_POSITION,
  PAGE_SIZE,
  PAGE_SIZE_MANUAL,
  LOADING_LIST_ITEMS_LENGTH,
} from '../constants';
import { setUrlParams } from '~/lib/utils/url_utility';
import issueableEventHub from '../eventhub';
import IssuesListEmptyState from './issues_list_empty_state.vue';

export default {
  LOADING_LIST_ITEMS_LENGTH,
  components: {
    GlPagination,
    GlSkeletonLoading,
    Issuable,
    FilteredSearchBar,
    IssuesListEmptyState,
  },
  inject: ['canBulkEdit', 'endpoint', 'filteredSearchOptions'],
  props: {
    sortKey: {
      type: String,
      required: false,
      default: '',
    },
  },
  data() {
    return {
      filters: {},
      isBulkEditing: false,
      issuables: [],
      loading: false,
      page:
        getParameterByName('page', window.location.href) !== null
          ? toNumber(getParameterByName('page'))
          : 1,
      selection: {},
      totalItems: 0,
    };
  },
  computed: {
    allIssuablesSelected() {
      // WARNING: Because we are only keeping track of selected values
      // this works, we will need to rethink this if we start tracking
      // [id]: false for not selected values.
      return this.issuables.length === Object.keys(this.selection).length;
    },
    hasFilters() {
      const ignored = ['utf8', 'state', 'scope', 'order_by', 'sort'];
      return Object.keys(omit(this.filters, ignored)).length > 0;
    },
    isManualOrdering() {
      return this.sortKey === RELATIVE_POSITION;
    },
    itemsPerPage() {
      return this.isManualOrdering ? PAGE_SIZE_MANUAL : PAGE_SIZE;
    },
    baseUrl() {
      return window.location.href.replace(/(\?.*)?(#.*)?$/, '');
    },
    paginationNext() {
      return this.page + 1;
    },
    paginationPrev() {
      return this.page - 1;
    },
    paginationProps() {
      const paginationProps = { value: this.page };

      if (this.totalItems) {
        return {
          ...paginationProps,
          perPage: this.itemsPerPage,
          totalItems: this.totalItems,
        };
      }

      return {
        ...paginationProps,
        prevPage: this.paginationPrev,
        nextPage: this.paginationNext,
      };
    },
  },
  watch: {
    selection() {
      // We need to call nextTick here to wait for all of the boxes to be checked and rendered
      // before we query the dom in issuable_bulk_update_actions.js.
      this.$nextTick(() => {
        issueableEventHub.$emit('issuables:updateBulkEdit');
      });
    },
    issuables() {
      this.$nextTick(() => {
        initManualOrdering();
      });
    },
  },
  mounted() {
    if (this.canBulkEdit) {
      this.unsubscribeToggleBulkEdit = issueableEventHub.$on('issuables:toggleBulkEdit', val => {
        this.isBulkEditing = val;
      });
    }
    this.fetchIssuables();
  },
  beforeDestroy() {
    issueableEventHub.$off('issuables:toggleBulkEdit');
  },
  methods: {
    isSelected(issuableId) {
      return Boolean(this.selection[issuableId]);
    },
    setSelection(ids) {
      ids.forEach(id => {
        this.select(id, true);
      });
    },
    clearSelection() {
      this.selection = {};
    },
    select(id, isSelect = true) {
      if (isSelect) {
        this.$set(this.selection, id, true);
      } else {
        this.$delete(this.selection, id);
      }
    },
    fetchIssuables(pageToFetch) {
      this.loading = true;

      this.clearSelection();

      this.setFilters();

      return axios
        .get(this.endpoint, {
          params: {
            ...this.filters,

            with_labels_details: true,
            page: pageToFetch || this.page,
            per_page: this.itemsPerPage,
          },
        })
        .then(response => {
          this.loading = false;
          this.issuables = response.data;
          this.totalItems = Number(response.headers['x-total']);
          this.page = Number(response.headers['x-page']);
        })
        .catch(() => {
          this.loading = false;
          return flash(__('An error occurred while loading issues'));
        });
    },
    getQueryObject() {
      return urlParamsToObject(window.location.search);
    },
    onPaginate(newPage) {
      if (newPage === this.page) return;

      scrollToElement('#content-body');

      // NOTE: This allows for the params to be updated on pagination
      historyPushState(
        setUrlParams({ ...this.filters, page: newPage }, window.location.href, true),
      );

      this.fetchIssuables(newPage);
    },
    onSelectAll() {
      if (this.allIssuablesSelected) {
        this.selection = {};
      } else {
        this.setSelection(this.issuables.map(({ id }) => id));
      }
    },
    onSelectIssuable({ issuable, selected }) {
      if (!this.canBulkEdit) return;

      this.select(issuable.id, selected);
    },
    setFilters() {
      const {
        label_name: labels,
        milestone_title: milestoneTitle,
        'not[label_name]': excludedLabels,
        'not[milestone_title]': excludedMilestone,
        ...filters
      } = this.getQueryObject();

      // TODO: https://gitlab.com/gitlab-org/gitlab/-/issues/227880

      if (milestoneTitle) {
        filters.milestone = milestoneTitle;
      }
      if (Array.isArray(labels)) {
        filters.labels = labels.join(',');
      }
      if (!filters.state) {
        filters.state = 'opened';
      }

      if (excludedLabels) {
        filters['not[labels]'] = excludedLabels;
      }

      if (excludedMilestone) {
        filters['not[milestone]'] = excludedMilestone;
      }

      Object.assign(filters, SortOrderMap[this.sortKey]);

      this.filters = filters;
    },
    refetchIssuables() {
      const ignored = ['utf8'];
      const params = omit(this.filters, ignored);

      historyPushState(setUrlParams(params, window.location.href, true, true));
      this.fetchIssuables();
    },
    handleFilter(filters) {
      let search = null;

      filters.forEach(filter => {
        if (typeof filter === 'string') {
          search = filter;
        }
      });

      this.filters.search = search;
      this.page = 1;

      this.refetchIssuables();
    },
    handleSort(sort) {
      this.filters.sort = sort;
      this.page = 1;

      this.refetchIssuables();
    },
  },
};
</script>

<template>
  <div>
    <!-- Currently, only Jira issues list uses the Vue version of filtered search bar -->
    <filtered-search-bar
      v-if="filteredSearchOptions"
      :namespace="filteredSearchOptions.projectPath"
      :search-input-placeholder="filteredSearchOptions.searchInputPlaceholder"
      :tokens="[]"
      :sort-options="filteredSearchOptions.availableSortOptions"
      :initial-filter-value="filteredSearchOptions.initialFilterValue"
      :initial-sort-by="filteredSearchOptions.initialSortBy"
      class="row-content-block"
      @onFilter="handleFilter"
      @onSort="handleSort"
    />
    <ul v-if="loading" class="content-list">
      <li v-for="n in $options.LOADING_LIST_ITEMS_LENGTH" :key="n" class="issue gl-px-5! gl-py-5!">
        <gl-skeleton-loading />
      </li>
    </ul>
    <div v-else-if="issuables.length">
      <div v-if="isBulkEditing" class="issue px-3 py-3 border-bottom border-light">
        <input
          id="check-all-issues"
          type="checkbox"
          :checked="allIssuablesSelected"
          class="mr-2"
          @click="onSelectAll"
        />
        <strong>{{ __('Select all') }}</strong>
      </div>
      <ul
        class="content-list issuable-list issues-list"
        :class="{ 'manual-ordering': isManualOrdering }"
      >
        <issuable
          v-for="issuable in issuables"
          :key="issuable.id"
          class="pr-3"
          :class="{ 'user-can-drag': isManualOrdering }"
          :issuable="issuable"
          :is-bulk-editing="isBulkEditing"
          :selected="isSelected(issuable.id)"
          :base-url="baseUrl"
          @select="onSelectIssuable"
        />
      </ul>
      <div class="mt-3">
        <gl-pagination
          v-bind="paginationProps"
          class="gl-justify-content-center"
          @input="onPaginate"
        />
      </div>
    </div>
    <IssuesListEmptyState v-else :has-filters="hasFilters" :issues-state="filters.state" />
  </div>
</template>
