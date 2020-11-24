<script>
import { GlAlert, GlLoadingIcon, GlTable, GlLink, GlSprintf, GlTooltipDirective } from '@gitlab/ui';
import { s__ } from '~/locale';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';
import { convertToSnakeCase } from '~/lib/utils/text_utility';
// TODO once backend is settled, update by either abstracting this out to app/assets/javascripts/graphql_shared or create new, modified query in #287757
import getAlerts from '~/alert_management/graphql/queries/get_alerts.query.graphql';

export default {
  i18n: {
    noAlertsMsg: s__(
      'ThreatMonitoring|No alerts available to display. See %{linkStart}enabling alert management%{linkEnd} for more information on adding alerts to the list.',
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
      thClass: `w-15p`,
      tdClass: `sortable-cell`,
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
      thClass: `w-15p`,
      tdClass: `sortable-cell`,
      sortable: true,
    },
  ],
  components: {
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
  inject: ['projectPath'],
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
      isErrorAlertDismissed: false,
      pageInfo: {},
      serverErrorMessage: '',
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
        !this.errored && !this.loading && this.alertsCount?.all === 0 && !this.isErrorAlertDismissed
      );
    },
  },
  methods: {
    errorAlertDismissed() {
      this.errored = false;
      this.serverErrorMessage = '';
      this.isErrorAlertDismissed = true;
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
    <gl-alert v-if="showNoAlertsMsg" @dismiss="errorAlertDismissed">
      <gl-sprintf :message="$options.i18n.noAlertsMsg">
        <template #link="{ content }">
          <gl-link class="gl-display-inline-block" :href="populatingAlertsHelpUrl" target="_blank">
            {{ content }}
          </gl-link>
        </template>
      </gl-sprintf>
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
        <time-ago v-if="item.startedAt" :time="item.startedAt" />
      </template>

      <template #cell(alertLabel)="{ item }">
        <div
          class="gl-max-w-full text-truncate"
          :title="`${item.iid} - ${item.title}`"
          data-testid="idField"
        >
          {{ item.title }}
        </div>
      </template>

      <template #cell(status)="{ item }">
        {{ $options.statuses[item.status] }}
      </template>

      <template #empty>
        {{ s__('ThreatMonitoring|No alerts to display.') }}
      </template>

      <template #table-busy>
        <gl-loading-icon size="lg" color="dark" class="mt-3" />
      </template>
    </gl-table>
  </div>
</template>
