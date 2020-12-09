<script>
import { GlAlert, GlLoadingIcon, GlTable, GlLink, GlSprintf, GlTooltipDirective } from '@gitlab/ui';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';
import { convertToSnakeCase } from '~/lib/utils/text_utility';
// TODO once backend is settled, update by either abstracting this out to app/assets/javascripts/graphql_shared or create new, modified query in #287757
import getAlerts from '~/alert_management/graphql/queries/get_alerts.query.graphql';
import { FIELDS, MESSAGES, STATUSES } from './constants';

export default {
  i18n: {
    FIELDS,
    MESSAGES,
    STATUSES,
  },
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
      isErrorAlertDismissed: false,
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
      return this.isEmpty && !this.loading && !this.errored && !this.isErrorAlertDismissed;
    },
  },
  methods: {
    errorAlertDismissed() {
      this.errored = false;
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
      {{ $options.i18n.MESSAGES.ERROR }}
    </gl-alert>

    <gl-table
      class="alert-management-table"
      :items="alerts ? alerts.list : []"
      :fields="$options.i18n.FIELDS"
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
        <div data-testid="threat-alerts-status">
          {{ $options.i18n.STATUSES[item.status] }}
        </div>
      </template>

      <template #empty>
        <div data-testid="threat-alerts-empty-state">
          {{ $options.i18n.MESSAGES.NO_ALERTS }}
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
