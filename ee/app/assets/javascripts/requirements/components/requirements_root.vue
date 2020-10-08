<script>
import * as Sentry from '~/sentry/wrapper';
import { GlPagination } from '@gitlab/ui';
import { __, sprintf } from '~/locale';
import Api from '~/api';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import { urlParamsToObject } from '~/lib/utils/common_utils';
import { updateHistory, setUrlParams } from '~/lib/utils/url_utility';

import FilteredSearchBar from '~/vue_shared/components/filtered_search_bar/filtered_search_bar_root.vue';
import AuthorToken from '~/vue_shared/components/filtered_search_bar/tokens/author_token.vue';
import { DEFAULT_LABEL_ANY } from '~/vue_shared/components/filtered_search_bar/constants';

import RequirementsTabs from './requirements_tabs.vue';
import RequirementsLoading from './requirements_loading.vue';
import RequirementsEmptyState from './requirements_empty_state.vue';
import RequirementItem from './requirement_item.vue';
import RequirementForm from './requirement_form.vue';

import projectRequirements from '../queries/projectRequirements.query.graphql';
import projectRequirementsCount from '../queries/projectRequirementsCount.query.graphql';
import createRequirement from '../queries/createRequirement.mutation.graphql';
import updateRequirement from '../queries/updateRequirement.mutation.graphql';

import { FilterState, AvailableSortOptions, DEFAULT_PAGE_SIZE } from '../constants';

export default {
  DEFAULT_PAGE_SIZE,
  AvailableSortOptions,
  components: {
    GlPagination,
    FilteredSearchBar,
    RequirementsTabs,
    RequirementsLoading,
    RequirementsEmptyState,
    RequirementItem,
    RequirementCreateForm: RequirementForm,
    RequirementEditForm: RequirementForm,
  },
  props: {
    projectPath: {
      type: String,
      required: true,
    },
    initialFilterBy: {
      type: String,
      required: true,
    },
    initialTextSearch: {
      type: String,
      required: false,
      default: '',
    },
    initialSortBy: {
      type: String,
      required: false,
      default: 'created_desc',
    },
    initialAuthorUsernames: {
      type: Array,
      required: false,
      default: () => [],
    },
    initialRequirementsCount: {
      type: Object,
      required: true,
      validator: value =>
        ['OPENED', 'ARCHIVED', 'ALL'].every(prop => typeof value[prop] === 'number'),
    },
    page: {
      type: Number,
      required: false,
      default: 1,
    },
    prev: {
      type: String,
      required: false,
      default: '',
    },
    next: {
      type: String,
      required: false,
      default: '',
    },
    emptyStatePath: {
      type: String,
      required: true,
    },
    canCreateRequirement: {
      type: Boolean,
      required: true,
    },
    requirementsWebUrl: {
      type: String,
      required: true,
    },
  },
  apollo: {
    requirements: {
      query: projectRequirements,
      variables() {
        const queryVariables = {
          projectPath: this.projectPath,
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

        // Include `state` only if `filterBy` is not `ALL`.
        // as Grqph query only supports `OPEN` and `ARCHIVED`.
        if (this.filterBy !== FilterState.all) {
          queryVariables.state = this.filterBy;
        }

        if (this.textSearch) {
          queryVariables.search = this.textSearch;
        }

        if (this.authorUsernames.length) {
          queryVariables.authorUsernames = this.authorUsernames;
        }

        if (this.sortBy) {
          queryVariables.sortBy = this.sortBy;
        }

        return queryVariables;
      },
      update(data) {
        const requirementsRoot = data.project?.requirements;

        return {
          list: requirementsRoot?.nodes || [],
          pageInfo: requirementsRoot?.pageInfo || {},
        };
      },
      error: e => {
        createFlash(__('Something went wrong while fetching requirements list.'));
        Sentry.captureException(e);
      },
    },
    requirementsCount: {
      query: projectRequirementsCount,
      variables() {
        return {
          projectPath: this.projectPath,
        };
      },
      update({ project = {} }) {
        const { opened = 0, archived = 0 } = project.requirementStatesCount;

        return {
          OPENED: opened,
          ARCHIVED: archived,
          ALL: opened + archived,
        };
      },
      error: e => {
        createFlash(__('Something went wrong while fetching requirements count.'));
        Sentry.captureException(e);
      },
    },
  },
  data() {
    return {
      filterBy: this.initialFilterBy,
      textSearch: this.initialTextSearch,
      authorUsernames: this.initialAuthorUsernames,
      sortBy: this.initialSortBy,
      showCreateForm: false,
      showEditForm: false,
      editedRequirement: null,
      createRequirementRequestActive: false,
      stateChangeRequestActiveFor: 0,
      currentPage: this.page,
      prevPageCursor: this.prev,
      nextPageCursor: this.next,
      requirements: {
        list: [],
        pageInfo: {},
      },
      requirementsCount: {
        OPENED: this.initialRequirementsCount[FilterState.opened],
        ARCHIVED: this.initialRequirementsCount[FilterState.archived],
        ALL: this.initialRequirementsCount[FilterState.all],
      },
    };
  },
  computed: {
    requirementsList() {
      return this.filterBy !== FilterState.all
        ? this.requirements.list.filter(({ state }) => state === this.filterBy)
        : this.requirements.list;
    },
    requirementsListLoading() {
      return this.$apollo.queries.requirements.loading;
    },
    requirementsListEmpty() {
      return (
        !this.$apollo.queries.requirements.loading &&
        !this.requirements.list.length &&
        this.requirementsCount[this.filterBy] === 0
      );
    },
    totalRequirementsForCurrentTab() {
      return this.requirementsCount[this.filterBy];
    },
    showEmptyState() {
      return this.requirementsListEmpty && !this.showCreateForm;
    },
    showPaginationControls() {
      const { hasPreviousPage, hasNextPage } = this.requirements.pageInfo;

      // This explicit check is necessary as both the variables
      // can also be `false` and we just want to ensure that they're present.
      if (hasPreviousPage !== undefined || hasNextPage !== undefined) {
        return Boolean(hasPreviousPage || hasNextPage);
      }
      return this.totalRequirementsForCurrentTab > DEFAULT_PAGE_SIZE && !this.requirementsListEmpty;
    },
    prevPage() {
      return Math.max(this.currentPage - 1, 0);
    },
    nextPage() {
      const nextPage = this.currentPage + 1;
      return nextPage > Math.ceil(this.totalRequirementsForCurrentTab / DEFAULT_PAGE_SIZE)
        ? null
        : nextPage;
    },
  },
  methods: {
    getFilteredSearchTokens() {
      return [
        {
          type: 'author_username',
          icon: 'user',
          title: __('Author'),
          unique: false,
          symbol: '@',
          token: AuthorToken,
          operators: [{ value: '=', description: __('is'), default: 'true' }],
          fetchPath: this.projectPath,
          fetchAuthors: Api.projectUsers.bind(Api),
        },
      ];
    },
    getFilteredSearchValue() {
      const value = this.authorUsernames.map(author => ({
        type: 'author_username',
        value: { data: author },
      }));

      if (this.textSearch) {
        value.push(this.textSearch);
      }

      return value;
    },
    /**
     * Update browser URL with updated query-param values
     * based on current page details.
     */
    updateUrl() {
      const { href, search } = window.location;
      const queryParams = urlParamsToObject(search);
      const {
        filterBy,
        currentPage,
        prevPageCursor,
        nextPageCursor,
        textSearch,
        authorUsernames,
        sortBy,
      } = this;

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

      if (filterBy) {
        queryParams.state = filterBy.toLowerCase();
      } else {
        delete queryParams.state;
      }

      if (textSearch) {
        queryParams.search = textSearch;
      } else {
        delete queryParams.search;
      }

      if (sortBy) {
        queryParams.sort = sortBy;
      } else {
        delete queryParams.sort;
      }

      delete queryParams.author_username;
      if (authorUsernames.length) {
        queryParams['author_username[]'] = authorUsernames;
      }

      // We want to replace the history state so that back button
      // correctly reloads the page with previous URL.
      updateHistory({
        url: setUrlParams(queryParams, href, true),
        title: document.title,
        replace: true,
      });
    },
    updateRequirement({ iid, title, state, errorFlashMessage }) {
      const updateRequirementInput = {
        projectPath: this.projectPath,
        iid,
      };

      if (title) {
        updateRequirementInput.title = title;
      }
      if (state) {
        updateRequirementInput.state = state;
      }

      return this.$apollo
        .mutate({
          mutation: updateRequirement,
          variables: {
            updateRequirementInput,
          },
        })
        .catch(e => {
          createFlash(errorFlashMessage);
          Sentry.captureException(e);
        });
    },
    handleTabClick({ filterBy }) {
      this.filterBy = filterBy;
      this.prevPageCursor = '';
      this.nextPageCursor = '';

      // Update browser URL
      updateHistory({
        url: setUrlParams({ state: filterBy.toLowerCase() }, window.location.href, true),
        title: document.title,
        replace: true,
      });

      // Wait for changes to propagate in component
      // and then fetch again.
      this.$nextTick(() => this.$apollo.queries.requirements.refetch());
    },
    handleNewRequirementClick() {
      this.showCreateForm = true;
    },
    handleEditRequirementClick(requirement) {
      this.showEditForm = true;
      this.editedRequirement = requirement;
    },
    handleNewRequirementSave(title) {
      this.createRequirementRequestActive = true;
      return this.$apollo
        .mutate({
          mutation: createRequirement,
          variables: {
            createRequirementInput: {
              projectPath: this.projectPath,
              title,
            },
          },
        })
        .then(({ data }) => {
          if (!data.createRequirement.errors.length) {
            this.$apollo.queries.requirementsCount.refetch();
            this.$apollo.queries.requirements.refetch();
            this.$toast.show(
              sprintf(__('Requirement %{reference} has been added'), {
                reference: `REQ-${data.createRequirement.requirement.iid}`,
              }),
            );
            this.showCreateForm = false;
          } else {
            throw new Error(`Error creating a requirement`);
          }
        })
        .catch(e => {
          createFlash(__('Something went wrong while creating a requirement.'));
          Sentry.captureException(e);
        })
        .finally(() => {
          this.createRequirementRequestActive = false;
        });
    },
    handleNewRequirementCancel() {
      this.showCreateForm = false;
    },
    handleUpdateRequirementSave(params) {
      this.createRequirementRequestActive = true;
      return this.updateRequirement({
        ...params,
        errorFlashMessage: __('Something went wrong while updating a requirement.'),
      })
        .then(({ data }) => {
          if (!data.updateRequirement.errors.length) {
            this.showEditForm = false;
            this.editedRequirement = null;
            this.$toast.show(
              sprintf(__('Requirement %{reference} has been updated'), {
                reference: `REQ-${data.updateRequirement.requirement.iid}`,
              }),
            );
          } else {
            throw new Error(`Error updating a requirement`);
          }
        })
        .finally(() => {
          this.createRequirementRequestActive = false;
        });
    },
    handleRequirementStateChange(params) {
      this.stateChangeRequestActiveFor = params.iid;
      return this.updateRequirement({
        ...params,
        errorFlashMessage:
          params.state === FilterState.opened
            ? __('Something went wrong while reopening a requirement.')
            : __('Something went wrong while archiving a requirement.'),
      }).then(({ data }) => {
        if (!data.updateRequirement.errors.length) {
          this.$apollo.queries.requirementsCount.refetch();
          this.stateChangeRequestActiveFor = 0;
          let toastMessage;
          if (params.state === FilterState.opened) {
            toastMessage = sprintf(__('Requirement %{reference} has been reopened'), {
              reference: `REQ-${data.updateRequirement.requirement.iid}`,
            });
          } else {
            toastMessage = sprintf(__('Requirement %{reference} has been archived'), {
              reference: `REQ-${data.updateRequirement.requirement.iid}`,
            });
          }
          this.$toast.show(toastMessage);
        } else {
          throw new Error(`Error archiving a requirement`);
        }
      });
    },
    handleUpdateRequirementCancel() {
      this.showEditForm = false;
      this.editedRequirement = null;
    },
    handleFilterRequirements(filters = []) {
      const authors = [];
      let textSearch = '';

      filters.forEach(filter => {
        if (typeof filter === 'string') {
          textSearch = filter;
        } else if (filter.value.data !== DEFAULT_LABEL_ANY.value) {
          authors.push(filter.value.data);
        }
      });

      this.authorUsernames = [...authors];
      this.textSearch = textSearch;
      this.currentPage = 1;
      this.prevPageCursor = '';
      this.nextPageCursor = '';

      this.updateUrl();
    },
    handleSortRequirements(sortBy) {
      this.sortBy = sortBy;

      this.currentPage = 1;
      this.prevPageCursor = '';
      this.nextPageCursor = '';
      this.updateUrl();
    },
    handlePageChange(page) {
      const { startCursor, endCursor } = this.requirements.pageInfo;

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
  },
};
</script>

<template>
  <div class="requirements-list-container">
    <requirements-tabs
      :filter-by="filterBy"
      :requirements-count="requirementsCount"
      :show-create-form="showCreateForm"
      :can-create-requirement="canCreateRequirement"
      @clickTab="handleTabClick"
      @clickNewRequirement="handleNewRequirementClick"
    />
    <filtered-search-bar
      :namespace="projectPath"
      :search-input-placeholder="__('Search requirements')"
      :tokens="getFilteredSearchTokens()"
      :sort-options="$options.AvailableSortOptions"
      :initial-filter-value="getFilteredSearchValue()"
      :initial-sort-by="sortBy"
      recent-searches-storage-key="requirements"
      class="row-content-block"
      @onFilter="handleFilterRequirements"
      @onSort="handleSortRequirements"
    />
    <requirement-create-form
      :drawer-open="showCreateForm"
      :requirement-request-active="createRequirementRequestActive"
      @save="handleNewRequirementSave"
      @cancel="handleNewRequirementCancel"
    />
    <requirement-edit-form
      :drawer-open="showEditForm"
      :requirement="editedRequirement"
      :requirement-request-active="createRequirementRequestActive"
      @save="handleUpdateRequirementSave"
      @cancel="handleUpdateRequirementCancel"
    />
    <requirements-empty-state
      v-if="showEmptyState"
      :filter-by="filterBy"
      :empty-state-path="emptyStatePath"
      :requirements-count="requirementsCount"
      :can-create-requirement="canCreateRequirement"
      @clickNewRequirement="handleNewRequirementClick"
    />
    <requirements-loading
      v-show="requirementsListLoading"
      :filter-by="filterBy"
      :current-page="currentPage"
      :requirements-count="requirementsCount"
    />
    <ul
      v-if="!requirementsListLoading && !requirementsListEmpty"
      class="content-list issuable-list issues-list requirements-list"
    >
      <requirement-item
        v-for="requirement in requirementsList"
        :key="requirement.iid"
        :requirement="requirement"
        :state-change-request-active="stateChangeRequestActiveFor === requirement.iid"
        @editClick="handleEditRequirementClick"
        @archiveClick="handleRequirementStateChange"
        @reopenClick="handleRequirementStateChange"
      />
    </ul>
    <gl-pagination
      v-if="showPaginationControls"
      :value="currentPage"
      :per-page="$options.DEFAULT_PAGE_SIZE"
      :prev-page="prevPage"
      :next-page="nextPage"
      align="center"
      class="gl-pagination gl-mt-3"
      @input="handlePageChange"
    />
  </div>
</template>
