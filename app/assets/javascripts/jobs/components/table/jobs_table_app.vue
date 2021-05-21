<script>
import { GlAlert, GlPagination, GlSkeletonLoader } from '@gitlab/ui';
import { __ } from '~/locale';
import { GRAPHQL_PAGE_SIZE } from './constants';
import GetJobs from './graphql/queries/get_jobs.query.graphql';
import JobsTable from './jobs_table.vue';
import JobsTableEmptyState from './jobs_table_empty_state.vue';
import JobsTableTabs from './jobs_table_tabs.vue';

const initialPaginationState = {
  currentPage: 1,
  prevPageCursor: '',
  nextPageCursor: '',
  first: GRAPHQL_PAGE_SIZE,
  last: null,
};

export default {
  i18n: {
    errorMsg: __('There was an error fetching the jobs for your project.'),
  },
  components: {
    GlAlert,
    GlPagination,
    GlSkeletonLoader,
    JobsTable,
    JobsTableEmptyState,
    JobsTableTabs,
  },
  inject: {
    fullPath: {
      default: '',
    },
  },
  apollo: {
    jobs: {
      query: GetJobs,
      variables() {
        return {
          fullPath: this.fullPath,
          first: this.pagination.first,
          last: this.pagination.last,
          after: this.pagination.nextPageCursor,
          before: this.pagination.prevPageCursor,
        };
      },
      update(data) {
        const { jobs: { nodes: list = [], pageInfo = {} } = {} } = data.project || {};
        return {
          list,
          pageInfo,
        };
      },
      error() {
        this.hasError = true;
      },
    },
  },
  data() {
    return {
      jobs: {},
      hasError: false,
      isAlertDismissed: false,
      scope: null,
      pagination: initialPaginationState,
    };
  },
  computed: {
    shouldShowAlert() {
      return this.hasError && !this.isAlertDismissed;
    },
    showEmptyState() {
      return this.jobs.list.length === 0 && !this.scope;
    },
    prevPage() {
      return Math.max(this.pagination.currentPage - 1, 0);
    },
    nextPage() {
      return this.jobs.pageInfo?.hasNextPage ? this.pagination.currentPage + 1 : null;
    },
    showPaginationControls() {
      return Boolean(this.prevPage || this.nextPage);
    },
  },
  methods: {
    fetchJobsByStatus(scope) {
      this.scope = scope;

      this.$apollo.queries.jobs.refetch({ statuses: scope });
    },
    handlePageChange(page) {
      const { startCursor, endCursor } = this.jobs.pageInfo;

      if (page > this.pagination.currentPage) {
        this.pagination = {
          ...initialPaginationState,
          nextPageCursor: endCursor,
          currentPage: page,
        };
      } else {
        this.pagination = {
          lastPageSize: GRAPHQL_PAGE_SIZE,
          firstPageSize: null,
          prevPageCursor: startCursor,
          currentPage: page,
        };
      }
    },
  },
};
</script>

<template>
  <div>
    <gl-alert
      v-if="shouldShowAlert"
      class="gl-mt-2"
      variant="danger"
      dismissible
      @dismiss="isAlertDismissed = true"
    >
      {{ $options.i18n.errorMsg }}
    </gl-alert>

    <jobs-table-tabs @fetchJobsByStatus="fetchJobsByStatus" />

    <div v-if="$apollo.loading" class="gl-mt-5">
      <gl-skeleton-loader
        preserve-aspect-ratio="none"
        equal-width-lines
        :lines="5"
        :width="600"
        :height="66"
      />
    </div>

    <jobs-table-empty-state v-else-if="showEmptyState" />

    <jobs-table v-else :jobs="jobs.list" />

    <gl-pagination
      v-if="showPaginationControls"
      :value="pagination.currentPage"
      :prev-page="prevPage"
      :next-page="nextPage"
      align="center"
      class="gl-mt-3"
      @input="handlePageChange"
    />
  </div>
</template>
