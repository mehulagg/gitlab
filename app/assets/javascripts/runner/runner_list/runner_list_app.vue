<script>
import { GlPagination } from '@gitlab/ui';
import * as Sentry from '@sentry/browser';
import { updateHistory } from '~/lib/utils/url_utility';
import RunnerFilteredSearchBar from '../components/runner_filtered_search_bar.vue';
import RunnerList from '../components/runner_list.vue';
import RunnerManualSetupHelp from '../components/runner_manual_setup_help.vue';
import RunnerTypeHelp from '../components/runner_type_help.vue';
import getRunnersQuery from '../graphql/get_runners.query.graphql';
import {
  fromUrlQueryToSearch,
  fromSearchToUrl,
  fromSearchToVariables,
} from './filtered_search_utils';

const RUNNER_PAGE_SIZE = 20;

export default {
  components: {
    GlPagination,
    RunnerFilteredSearchBar,
    RunnerList,
    RunnerManualSetupHelp,
    RunnerTypeHelp,
  },
  props: {
    activeRunnersCount: {
      type: Number,
      required: true,
    },
    registrationToken: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      search: fromUrlQueryToSearch(),
      runners: [],

      pageInfo: {},
      pagination: {
        page: 1,
      },
    };
  },
  apollo: {
    runners: {
      query: getRunnersQuery,
      variables() {
        return this.variables;
      },
      update(data) {
        const { runners } = data;
        this.pageInfo = runners?.pageInfo;
        return runners?.nodes || [];
      },
      error(err) {
        this.captureException(err);
      },
    },
  },
  computed: {
    variables() {
      const vars = {};

      if (this.pagination.before) {
        vars.before = this.pagination.before;
        vars.last = RUNNER_PAGE_SIZE;
      } else {
        vars.after = this.pagination.after;
        vars.first = RUNNER_PAGE_SIZE;
      }

      return {
        ...vars,
        ...fromSearchToVariables(this.search),
      };
    },
    runnersLoading() {
      return this.$apollo.queries.runners.loading;
    },
    noRunnersFound() {
      return !this.runnersLoading && !this.runners.length;
    },

    prevPage() {
      return Number(this.pageInfo.hasPreviousPage);
    },
    nextPage() {
      return Number(this.pageInfo.hasNextPage);
    },
  },
  watch: {
    search() {
      // TODO Implement back button reponse using onpopstate

      updateHistory({
        url: fromSearchToUrl(this.search),
        title: document.title,
      });
    },
  },
  errorCaptured(err) {
    this.captureException(err);
  },
  methods: {
    captureException(err) {
      Sentry.withScope((scope) => {
        scope.setTag('component', 'runner_list_app');
        Sentry.captureException(err);
      });
    },
    handlePageChange(page) {
      const { startCursor, endCursor } = this.pageInfo;

      if (page > this.pagination.page) {
        this.pagination = {
          after: endCursor,
          page,
        };
      } else {
        this.pagination = {
          before: startCursor,
          page,
        };
      }
    },
  },
};
</script>
<template>
  <div>
    <pre>{{ pageInfo }}</pre>
    <pre>{{ pagination }}</pre>
    <div class="row">
      <div class="col-sm-6">
        <runner-type-help />
      </div>
      <div class="col-sm-6">
        <runner-manual-setup-help :registration-token="registrationToken" />
      </div>
    </div>

    <runner-filtered-search-bar v-model="search" namespace="admin_runners" />

    <div v-if="noRunnersFound" class="gl-text-center gl-p-5">
      {{ __('No runners found') }}
    </div>
    <template v-else>
      <runner-list
        :runners="runners"
        :loading="runnersLoading"
        :active-runners-count="activeRunnersCount"
      />
      <gl-pagination
        :value="pagination.page"
        :prev-page="prevPage"
        :next-page="nextPage"
        align="center"
        class="gl-pagination gl-mt-3"
        @input="handlePageChange"
      />
    </template>
  </div>
</template>
