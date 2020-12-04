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
import { s__ } from '~/locale';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';
import { convertToSnakeCase } from '~/lib/utils/text_utility';
// TODO once backend is settled, update by either abstracting this out to app/assets/javascripts/graphql_shared or create new, modified query in #287757
import getAlerts from '~/alert_management/graphql/queries/get_alerts.query.graphql';

export default {
  alertsPerPage: 20,
  i18n: {
    noAlertsMsg: s__(
      'ThreatMonitoring|No alerts available to display. See %{linkStart}enabling threat alerts%{linkEnd} for more information on adding alerts to the list.',
    ),
    errorMsg: s__(
      "ThreatMonitoring|There was an error displaying the alerts. Confirm your endpoint's configuration details to ensure alerts appear.",
    ),
  },
  statuses: {
    TRIGGERED: s__('ThreatMonitoring|Unreviewed'),
    ACKNOWLEDGED: s__('ThreatMonitoring|In review'),
    RESOLVED: s__('ThreatMonitoring|Resolved'),
    IGNORED: s__('ThreatMonitoring|Dismissed'),
  },
  fields: [
    {
      key: 'startedAt',
      label: s__('ThreatMonitoring|Date and time'),
      thClass: `gl-bg-white! w-15p`,
      tdClass: `gl-pl-6!`,
      sortable: true,
    },
    {
      key: 'alertLabel',
      label: s__('ThreatMonitoring|Name'),
      thClass: `gl-bg-white! gl-pointer-events-none`,
    },
    {
      key: 'status',
      label: s__('ThreatMonitoring|Status'),
      thAttr: { 'data-testid': 'threat-alerts-status-header' },
      thClass: `gl-bg-white! w-15p`,
      tdClass: `gl-pl-6!`,
      sortable: true,
    },
  ],
  components: {
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
          firstPageSize: this.$options.alertsPerPage,
          projectPath: this.projectPath,
          sort: this.sort,
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
      isErrorAlertDismissed: false,
      pageInfo: {},
      sort: 'STARTED_AT_DESC',
      sortBy: 'startedAt',
      sortDesc: true,
      sortDirection: 'desc',
    };
  },
  computed: {
    isLoadingAlerts() {
      return this.$apollo.queries.alerts.loading;
    },
    isLoadingFirstAlerts() {
      return this.isLoadingAlerts && this.alerts.length === 0;
    },
    showNoAlertsMsg() {
      return (
        this.alerts.length === 0 &&
        !this.isLoadingAlerts &&
        !this.errored &&
        !this.isErrorAlertDismissed
      );
    },
  },
  methods: {
    errorAlertDismissed() {
      this.errored = false;
      this.isErrorAlertDismissed = true;
    },
    fetchNextPage() {
      if (this.pageInfo.hasNextPage) {
        this.$apollo.queries.alerts.fetchMore({
          variables: { nextPageCursor: this.pageInfo.endCursor },
          updateQuery: (previousResult, { fetchMoreResult }) => {
            const results = produce(fetchMoreResult, draftData => {
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
  },
};
</script>
<template>
  <div>
    <gl-alert v-if="showNoAlertsMsg" data-testid="threat-alerts-unconfigured" :dismissible="false">
      <gl-sprintf :message="$options.i18n.noAlertsMsg">
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
      {{ $options.i18n.errorMsg }}
    </gl-alert>

    <gl-table
      class="alert-management-table"
      :busy="isLoadingFirstAlerts"
      :items="alerts"
      :fields="$options.fields"
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
        <div data-testid="threat-alerts-status">
          {{ $options.statuses[item.status] }}
        </div>
      </template>

      <template #table-busy>
        <gl-skeleton-loading
          v-for="n in $options.alertsPerPage"
          :key="n"
          class="gl-m-3 js-skeleton-loader"
          :lines="1"
          data-testid="threat-alerts-busy-state"
        />
      </template>

      <template #empty>
        <div data-testid="threat-alerts-empty-state">
          {{ s__('ThreatMonitoring|No alerts to display.') }}
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
