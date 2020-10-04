<script>
/* eslint-disable vue/no-v-html */
import {
  GlLoadingIcon,
  GlTable,
  GlAvatarsInline,
  GlAvatarLink,
  GlAvatar,
  GlIcon,
  GlLink,
  GlSprintf,
  GlTooltipDirective,
} from '@gitlab/ui';
import { __, s__ } from '~/locale';
import { joinPaths, visitUrl } from '~/lib/utils/url_utility';
import OperationsPageWrapper from '~/vue_shared/components/operations/operations_page_wrapper/operations_page_wrapper.vue';
import {
  tdClass,
  thClass,
  bodyTrClass,
  initialPaginationState,
} from '~/vue_shared/components/operations/operations_page_wrapper/constants';
import TimeAgo from '~/vue_shared/components/time_ago_tooltip.vue';
import { convertToSnakeCase } from '~/lib/utils/text_utility';
import getAlerts from '../graphql/queries/get_alerts.query.graphql';
import getAlertsCountByStatus from '../graphql/queries/get_count_by_status.query.graphql';
import {
  ALERTS_STATUS_TABS,
  ALERTS_SEVERITY_LABELS,
  trackAlertListViewsOptions,
} from '../constants';
import AlertStatus from './alert_status.vue';

const TH_TEST_ID = { 'data-testid': 'alert-management-severity-sort' };

const TWELVE_HOURS_IN_MS = 12 * 60 * 60 * 1000;

export default {
  trackAlertListViewsOptions,
  i18n: {
    noAlertsMsg: s__(
      'AlertManagement|No alerts available to display. See %{linkStart}enabling alert management%{linkEnd} for more information on adding alerts to the list.',
    ),
    errorMsg: s__(
      "AlertManagement|There was an error displaying the alerts. Confirm your endpoint's configuration details to ensure alerts appear.",
    ),
    searchPlaceholder: __('Search or filter results...'),
    unassigned: __('Unassigned'),
  },
  fields: [
    {
      key: 'severity',
      label: s__('AlertManagement|Severity'),
      thClass: `${thClass} gl-w-eighth`,
      thAttr: TH_TEST_ID,
      tdClass: `${tdClass} rounded-top text-capitalize sortable-cell`,
      sortable: true,
    },
    {
      key: 'startedAt',
      label: s__('AlertManagement|Start time'),
      thClass: `${thClass} js-started-at w-15p`,
      tdClass: `${tdClass} sortable-cell`,
      sortable: true,
    },
    {
      key: 'alertLabel',
      label: s__('AlertManagement|Alert'),
      thClass: `gl-pointer-events-none`,
      tdClass,
    },
    {
      key: 'eventCount',
      label: s__('AlertManagement|Events'),
      thClass: `${thClass} text-right gl-w-12`,
      tdClass: `${tdClass} text-md-right sortable-cell`,
      sortable: true,
    },
    {
      key: 'issue',
      label: s__('AlertManagement|Issue'),
      thClass: 'gl-w-12 gl-pointer-events-none',
      tdClass,
    },
    {
      key: 'assignees',
      label: s__('AlertManagement|Assignees'),
      thClass: 'gl-w-eighth gl-pointer-events-none',
      tdClass,
    },
    {
      key: 'status',
      label: s__('AlertManagement|Status'),
      thClass: `${thClass} w-15p`,
      tdClass: `${tdClass} rounded-bottom sortable-cell`,
      sortable: true,
    },
  ],
  severityLabels: ALERTS_SEVERITY_LABELS,
  statusTabs: ALERTS_STATUS_TABS,
  components: {
    GlLoadingIcon,
    GlTable,
    GlAvatarsInline,
    GlAvatarLink,
    GlAvatar,
    TimeAgo,
    GlIcon,
    GlLink,
    GlSprintf,
    AlertStatus,
    OperationsPageWrapper,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  inject: ['projectPath', 'textQuery', 'authorUsernamesQuery', 'assigneeUsernamesQuery'],
  props: {
    populatingAlertsHelpUrl: {
      type: String,
      required: true,
    },
  },
  apollo: {
    alerts: {
      query: getAlerts,
      variables() {
        return {
          searchTerm: this.searchTerm,
          authorUsername: this.authorUsername,
          assigneeUsernames: this.assigneeUsernames,
          projectPath: this.projectPath,
          statuses: this.statusFilter,
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
    alertsCount: {
      query: getAlertsCountByStatus,
      variables() {
        return {
          searchTerm: this.searchTerm,
          authorUsername: this.authorUsername,
          assigneeUsernames: this.assigneeUsernames,
          projectPath: this.projectPath,
        };
      },
      update(data) {
        return data.project?.alertManagementAlertStatusCounts;
      },
    },
  },
  data() {
    return {
      errored: false,
      errorMessage: '',
      isErrorAlertDismissed: false,
      sort: 'STARTED_AT_DESC',
      statusFilter: [],
      filteredByStatus: '',
      alerts: {},
      alertsCount: {},
      sortBy: 'startedAt',
      sortDesc: true,
      sortDirection: 'desc',
      searchTerm: this.textQuery,
      authorUsername: this.authorUsernamesQuery,
      assigneeUsernames: this.assigneeUsernamesQuery,
      pagination: initialPaginationState,
    };
  },
  computed: {
    showErrorMsg() {
      return this.errored && !this.isErrorAlertDismissed;
    },
    loading() {
      return this.$apollo.queries.alerts.loading;
    },
    isEmpty() {
      return !this.alerts?.list?.length;
    },
    showList() {
      return !this.isEmpty || this.errored || this.loading;
    },
  },
  methods: {
    fetchSortedData({ sortBy, sortDesc }) {
      const sortingDirection = sortDesc ? 'DESC' : 'ASC';
      const sortingColumn = convertToSnakeCase(sortBy).toUpperCase();

      this.pagination = initialPaginationState;
      this.sort = `${sortingColumn}_${sortingDirection}`;
    },
    navigateToAlertDetails({ iid }, index, { metaKey }) {
      return visitUrl(joinPaths(window.location.pathname, iid, 'details'), metaKey);
    },
    hasAssignees(assignees) {
      return Boolean(assignees.nodes?.length);
    },
    getIssueLink(item) {
      return joinPaths('/', this.projectPath, '-', 'issues', item.issueIid);
    },
    tbodyTrClass(item) {
      return {
        [bodyTrClass]: !this.loading && !this.isEmpty,
        'new-alert': item?.isNew,
      };
    },
    handleAlertError(errorMessage) {
      this.hasError = true;
      this.errorMessage = errorMessage;
    },
    dismissError() {
      this.hasError = false;
      this.errorMessage = '';
    },
    pageChanged(pagination) {
      this.pagination = pagination;
    },
    statusChanged({ filters, status }) {
      this.statusFilter = filters;
      this.filteredByStatus = status;
    },
    filtersChanged({ searchTerm, authorUsername, assigneeUsernames }) {
      this.searchTerm = searchTerm;
      this.authorUsername = authorUsername;
      this.assigneeUsernames = assigneeUsernames;
    },
    errorAlertDismissed() {
      this.isErrorAlertDismissed = true;
    },
  },
};
</script>
<template>
  <div class="incident-management-list">
    <operations-page-wrapper
      :loading="loading"
      :show-items="showList"
      :show-error-msg="showErrorMsg"
      :i18n="$options.i18n"
      :items="alerts.list || []"
      :page-info="alerts.pageInfo"
      :items-count="alertsCount"
      :status-tabs="$options.statusTabs"
      :track-views-options="$options.trackAlertListViewsOptions"
      @page-changed="pageChanged"
      @status-changed="statusChanged"
      @filters-changed="filtersChanged"
      @error-alert-dismissed="errorAlertDismissed"
    >
      <template #header-actions></template>

      <template #title>
        {{ s__('AlertManagement|Alerts') }}
      </template>

      <template #table>
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
          @row-clicked="navigateToAlertDetails"
          @sort-changed="fetchSortedData"
        >
          <template #cell(severity)="{ item }">
            <div
              class="d-inline-flex align-items-center justify-content-between"
              data-testid="severityField"
            >
              <gl-icon
                class="mr-2"
                :size="12"
                :name="`severity-${item.severity.toLowerCase()}`"
                :class="`icon-${item.severity.toLowerCase()}`"
              />
              {{ $options.severityLabels[item.severity] }}
            </div>
          </template>

          <template #cell(startedAt)="{ item }">
            <time-ago v-if="item.startedAt" :time="item.startedAt" />
          </template>

          <template #cell(eventCount)="{ item }">
            {{ item.eventCount }}
          </template>

          <template #cell(alertLabel)="{ item }">
            <div
              class="gl-max-w-full text-truncate"
              :title="`${item.iid} - ${item.title}`"
              data-testid="idField"
            >
              #{{ item.iid }} {{ item.title }}
            </div>
          </template>

          <template #cell(issue)="{ item }">
            <gl-link v-if="item.issueIid" data-testid="issueField" :href="getIssueLink(item)">
              #{{ item.issueIid }}
            </gl-link>
            <div v-else data-testid="issueField">{{ s__('AlertManagement|None') }}</div>
          </template>

          <template #cell(assignees)="{ item }">
            <div data-testid="assigneesField">
              <template v-if="hasAssignees(item.assignees)">
                <gl-avatars-inline
                  :avatars="item.assignees.nodes"
                  :collapsed="true"
                  :max-visible="4"
                  :avatar-size="24"
                  badge-tooltip-prop="name"
                  :badge-tooltip-max-chars="100"
                >
                  <template #avatar="{ avatar }">
                    <gl-avatar-link
                      :key="avatar.username"
                      v-gl-tooltip
                      target="_blank"
                      :href="avatar.webUrl"
                      :title="avatar.name"
                    >
                      <gl-avatar :src="avatar.avatarUrl" :label="avatar.name" :size="24" />
                    </gl-avatar-link>
                  </template>
                </gl-avatars-inline>
              </template>
              <template v-else>
                {{ $options.i18n.unassigned }}
              </template>
            </div>
          </template>

          <template #cell(status)="{ item }">
            <alert-status
              :alert="item"
              :project-path="projectPath"
              :is-sidebar="false"
              @alert-error="handleAlertError"
            />
          </template>

          <template #empty>
            {{ s__('AlertManagement|No alerts to display.') }}
          </template>

          <template #table-busy>
            <gl-loading-icon size="lg" color="dark" class="mt-3" />
          </template>
        </gl-table>
      </template>
      <template #emtpy-state>
        <!-- <gl-empty-state
          :title="emptyStateData.title"
          :svg-path="emptyListSvgPath"
          :description="emptyStateData.description"
          :primary-button-link="emptyStateData.btnLink"
          :primary-button-text="emptyStateData.btnText"
        /> -->
      </template>
    </operations-page-wrapper>
    <!-- <gl-alert v-if="showNoAlertsMsg" @dismiss="isAlertDismissed = true">
      <gl-sprintf :message="$options.i18n.noAlertsMsg">
        <template #link="{ content }">
          <gl-link
            class="gl-display-inline-block"
            :href="populatingAlertsHelpUrl"
            target="_blank"
          >
            {{ content }}
          </gl-link>
        </template>
      </gl-sprintf>
    </gl-alert>
    <gl-alert v-if="hasError" variant="danger" data-testid="alert-error" @dismiss="dismissError">
      <p v-html="errorMessage || $options.i18n.errorMsg"></p>
    </gl-alert> -->
  </div>
</template>
