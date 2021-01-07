<script>
import {
  GlAlert,
  GlIntersectionObserver,
  GlLoadingIcon,
  GlTable,
  GlLink,
  GlSkeletonLoading,
  GlSprintf,
  GlTooltipDirective,
} from '@gitlab/ui';
import produce from 'immer';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';
import { convertToSnakeCase } from '~/lib/utils/text_utility';
import getAlerts from '~/graphql_shared/queries/get_alerts.query.graphql';
import { DEFAULT_FILTERS, FIELDS, MESSAGES, PAGE_SIZE, STATUSES } from './constants';
import AlertFilters from './alert_filters.vue';
import AlertStatus from './alert_status.vue';

export default {
  PAGE_SIZE,
  i18n: {
    FIELDS,
    MESSAGES,
    STATUSES,
  },
  components: {
    AlertStatus,
    AlertFilters,
    GlAlert,
    GlIntersectionObserver,
    GlLink,
    GlLoadingIcon,
    GlSkeletonLoading,
    GlSprintf,
    GlTable,
    TimeAgo,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  inject: ['documentationPath', 'projectPath'],
  apollo: {
    alerts: {
      query: getAlerts,
      variables() {
        return {
          firstPageSize: this.$options.PAGE_SIZE,
          projectPath: this.projectPath,
          sort: this.sort,
          ...this.filters,
        };
      },
      update: ({ project }) => project?.alertManagementAlerts.nodes || [],
      result({ data }) {
        this.pageInfo = data?.project?.alertManagementAlerts?.pageInfo;
      },
      error() {
        this.errored = true;
      },
    },
  },
  data() {
    return {
      alerts: [],
      errored: false,
      errorMsg: '',
      filters: DEFAULT_FILTERS,
      isErrorAlertDismissed: false,
      pageInfo: {},
      sort: 'STARTED_AT_DESC',
      sortBy: 'startedAt',
      sortDesc: true,
      sortDirection: 'desc',
    };
  },
  computed: {
    isEmpty() {
      return !this.alerts.length;
    },
    isLoadingAlerts() {
      return this.$apollo.queries.alerts.loading;
    },
    isLoadingFirstAlerts() {
      return this.isLoadingAlerts && this.isEmpty;
    },
    showNoAlertsMsg() {
      return this.isEmpty && !this.isLoadingAlerts && !this.errored && !this.isErrorAlertDismissed;
    },
  },
  methods: {
    errorAlertDismissed() {
      this.errored = false;
      this.errorMsg = '';
      this.isErrorAlertDismissed = true;
    },
    fetchNextPage() {
      if (this.pageInfo.hasNextPage) {
        this.$apollo.queries.alerts.fetchMore({
          variables: { nextPageCursor: this.pageInfo.endCursor },
          updateQuery: (previousResult, { fetchMoreResult }) => {
            const results = produce(fetchMoreResult, (draftData) => {
              // eslint-disable-next-line no-param-reassign
              draftData.project.alertManagementAlerts.nodes = [
                ...previousResult.project.alertManagementAlerts.nodes,
                ...draftData.project.alertManagementAlerts.nodes,
              ];
            });
            return results;
          },
        });
      }
    },
    fetchSortedData({ sortBy, sortDesc }) {
      const sortingDirection = sortDesc ? 'DESC' : 'ASC';
      const sortingColumn = convertToSnakeCase(sortBy).toUpperCase();

      this.sort = `${sortingColumn}_${sortingDirection}`;
    },
    handleAlertError(msg) {
      this.errored = true;
      this.errorMsg = msg;
    },
    handleFilterChange(newFilters) {
      this.filters = newFilters;
    },
    handleStatusUpdate() {
      this.$apollo.queries.alerts.refetch();
    },
  },
};
</script>
<template>
  <div>
    <alert-filters @filter-change="handleFilterChange" />
    <gl-alert v-if="showNoAlertsMsg" data-testid="threat-alerts-unconfigured" :dismissible="false">
      <gl-sprintf :message="$options.i18n.MESSAGES.CONFIGURE">
        <template #link="{ content }">
          <gl-link class="gl-display-inline-block" :href="documentationPath" target="_blank">
            {{ content }}
          </gl-link>
        </template>
      </gl-sprintf>
    </gl-alert>

    <gl-alert
      v-if="errored"
      variant="danger"
      data-testid="threat-alerts-error"
      @dismiss="errorAlertDismissed"
    >
      {{ errorMsg || $options.i18n.MESSAGES.ERROR }}
    </gl-alert>

    <gl-table
      class="alert-management-table"
      :busy="isLoadingFirstAlerts"
      :items="alerts"
      :fields="$options.i18n.FIELDS"
      stacked="md"
      :no-local-sorting="true"
      :sort-direction="sortDirection"
      :sort-desc.sync="sortDesc"
      :sort-by.sync="sortBy"
      thead-class="gl-border-b-solid gl-border-b-1 gl-border-b-gray-100"
      sort-icon-left
      responsive
      show-empty
      @sort-changed="fetchSortedData"
    >
      <template #cell(startedAt)="{ item }">
        <time-ago
          v-if="item.startedAt"
          :time="item.startedAt"
          data-testid="threat-alerts-started-at"
        />
      </template>

      <template #cell(alertLabel)="{ item }">
        <div
          class="gl-word-break-all"
          :title="`${item.iid} - ${item.title}`"
          data-testid="threat-alerts-id"
        >
          {{ item.title }}
        </div>
      </template>

      <template #cell(status)="{ item }">
        <alert-status
          :alert="item"
          :project-path="projectPath"
          @alert-error="handleAlertError"
          @alert-update="handleStatusUpdate"
        />
      </template>

      <template #table-busy>
        <gl-skeleton-loading
          v-for="n in $options.PAGE_SIZE"
          :key="n"
          class="gl-m-3 js-skeleton-loader"
          :lines="1"
          data-testid="threat-alerts-busy-state"
        />
      </template>

      <template #empty>
        <div data-testid="threat-alerts-empty-state">
          {{ $options.i18n.MESSAGES.NO_ALERTS }}
        </div>
      </template>
    </gl-table>

    <gl-intersection-observer
      v-if="pageInfo.hasNextPage"
      class="text-center"
      @appear="fetchNextPage"
    >
      <gl-loading-icon v-if="isLoadingAlerts" size="md" />
      <span v-else>&nbsp;</span>
    </gl-intersection-observer>
  </div>
</template>
