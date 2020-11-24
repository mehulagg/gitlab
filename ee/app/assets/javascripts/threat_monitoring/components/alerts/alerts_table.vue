<script>
import { GlAlert, GlLoadingIcon, GlTable, GlLink, GlSprintf, GlTooltipDirective } from '@gitlab/ui';
import { s__ } from '~/locale';
import {
  bodyTrClass,
  initialPaginationState,
} from '~/vue_shared/components/paginated_table_with_search_and_tabs/constants';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';
import { convertToSnakeCase } from '~/lib/utils/text_utility';
import getAlerts from '~/alert_management/graphql/queries/get_alerts.query.graphql';
import AlertStatus from './alert_status.vue';

const TWELVE_HOURS_IN_MS = 12 * 60 * 60 * 1000;

export default {
  i18n: {
    noAlertsMsg: s__(
      'ThreatMonitoring|No alerts available to display. See %{linkStart}enabling alert management%{linkEnd} for more information on adding alerts to the list.',
    ),
    errorMsg: s__(
      "ThreatMonitoring|There was an error displaying the alerts. Confirm your endpoint's configuration details to ensure alerts appear.",
    ),
  },
  fields: [
    {
      key: 'startedAt',
      label: s__('ThreatMonitoring|Date and time'),
      thClass: `js-started-at w-15p`,
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
      tdClass: `rounded-bottom sortable-cell`,
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
    AlertStatus,
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
          firstPageSize: this.pagination.firstPageSize,
          lastPageSize: this.pagination.lastPageSize,
          prevPageCursor: this.pagination.prevPageCursor,
          nextPageCursor: this.pagination.nextPageCursor,
        };
      },
      update(data) {
        const { alertManagementAlerts: { nodes: list = [], pageInfo = {} } = {} } =
          data.project || {};
        const now = new Date();

        const listWithData = list.map(alert => {
          const then = new Date(alert.startedAt);
          const diff = now - then;

          return {
            ...alert,
            isNew: diff < TWELVE_HOURS_IN_MS,
          };
        });

        return {
          list: listWithData,
          pageInfo,
        };
      },
      error() {
        this.errored = true;
      },
    },
  },
  data() {
    return {
      errored: false,
      serverErrorMessage: '',
      isErrorAlertDismissed: false,
      sort: 'STARTED_AT_DESC',
      alerts: {},
      sortBy: 'startedAt',
      sortDesc: true,
      sortDirection: 'desc',
      pagination: initialPaginationState,
    };
  },
  computed: {
    isEmpty() {
      return !this.alerts?.list?.length;
    },
    loading() {
      return this.$apollo.queries.alerts.loading;
    },
    showErrorMsg() {
      return this.errored && !this.isErrorAlertDismissed;
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

      this.pagination = initialPaginationState;
      this.sort = `${sortingColumn}_${sortingDirection}`;
    },
    handleAlertError(errorMessage) {
      this.errored = true;
      this.serverErrorMessage = errorMessage;
    },
    handleStatusUpdate() {
      this.$apollo.queries.alerts.refetch();
    },
    pageChanged(pagination) {
      this.pagination = pagination;
    },
    showAlertDetails() {
      // TODO show drawer
    },
    tbodyTrClass(item) {
      return {
        [bodyTrClass]: !this.loading && !this.isEmpty,
        'new-alert': item?.isNew,
      };
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
      :tbody-tr-class="tbodyTrClass"
      :no-local-sorting="true"
      :sort-direction="sortDirection"
      :sort-desc.sync="sortDesc"
      :sort-by.sync="sortBy"
      sort-icon-left
      fixed
      @row-clicked="showAlertDetails"
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
        <alert-status
          :alert="item"
          :project-path="projectPath"
          :is-sidebar="false"
          @alert-error="handleAlertError"
          @hide-dropdown="handleStatusUpdate"
        />
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
