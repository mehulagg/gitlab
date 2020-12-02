<script>
import { GlAlert, GlLoadingIcon, GlTable, GlLink, GlSprintf, GlTooltipDirective } from '@gitlab/ui';
import { s__ } from '~/locale';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';
import { convertToSnakeCase } from '~/lib/utils/text_utility';
// TODO once backend is settled, update by either abstracting this out to app/assets/javascripts/graphql_shared or create new, modified query in #287757
import getAlerts from '~/alert_management/graphql/queries/get_alerts.query.graphql';
import AlertStatus from './alert_status.vue';

export default {
  i18n: {
    noAlertsMsg: s__(
      'ThreatMonitoring|No alerts available to display. See %{linkStart}enabling threat alerts%{linkEnd} for more information on adding alerts to the list.',
    ),
    errorMsg: s__(
      "ThreatMonitoring|There was an error displaying the alerts. Confirm your endpoint's configuration details to ensure alerts appear.",
    ),
  },
  fields: [
    {
      key: 'startedAt',
      label: s__('ThreatMonitoring|Date and time'),
      thClass: `w-15p`,
      tdClass: `gl-pl-6!`,
      sortable: true,
    },
    {
      key: 'alertLabel',
      label: s__('ThreatMonitoring|Name'),
      thClass: `gl-pointer-events-none`,
    },
    {
      key: 'status',
      label: s__('ThreatMonitoring|Status'),
      thAttr: { 'data-testid': 'threat-alerts-status-header' },
      thClass: `w-15p`,
      sortable: true,
    },
  ],
  components: {
    AlertStatus,
    GlAlert,
    GlLoadingIcon,
    GlTable,
    TimeAgo,
    GlLink,
    GlSprintf,
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
          projectPath: this.projectPath,
          sort: this.sort,
        };
      },
      update: ({ project }) => ({
        list: project?.alertManagementAlerts.nodes || [],
        pageInfo: project?.alertManagementAlerts.pageInfo || {},
      }),
      error() {
        this.errored = true;
      },
    },
  },
  data() {
    return {
      alerts: {},
      errored: false,
      errorMsg: '',
      isErrorAlertDismissed: false,
      // TODO implement infinite scrolling in #290705
      pageInfo: {},
      sort: 'STARTED_AT_DESC',
      sortBy: 'startedAt',
      sortDesc: true,
      sortDirection: 'desc',
    };
  },
  computed: {
    isEmpty() {
      return !this.alerts?.list?.length;
    },
    loading() {
      return this.$apollo.queries.alerts.loading;
    },
    showNoAlertsMsg() {
      return (
        this.alerts.list?.length === 0 &&
        !this.loading &&
        !this.errored &&
        !this.isErrorAlertDismissed
      );
    },
  },
  methods: {
    errorAlertDismissed() {
      this.errored = false;
      this.errorMsg = '';
      this.isErrorAlertDismissed = true;
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
    handleStatusUpdate() {
      this.$apollo.queries.alerts.refetch();
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
      {{ errorMsg || $options.i18n.errorMsg }}
    </gl-alert>

    <gl-table
      class="alert-management-table"
      :items="alerts ? alerts.list : []"
      :fields="$options.fields"
      :show-empty="true"
      :busy="loading"
      stacked="md"
      :no-local-sorting="true"
      :sort-direction="sortDirection"
      :sort-desc.sync="sortDesc"
      :sort-by.sync="sortBy"
      sort-icon-left
      responsive
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
          @hide-dropdown="handleStatusUpdate"
        />
      </template>

      <template #empty>
        <div data-testid="threat-alerts-empty-state">
          {{ s__('ThreatMonitoring|No alerts to display.') }}
        </div>
      </template>

      <template #table-busy>
        <gl-loading-icon
          size="lg"
          color="dark"
          class="gl-mt-3"
          data-testid="threat-alerts-busy-state"
        />
      </template>
    </gl-table>
  </div>
</template>
