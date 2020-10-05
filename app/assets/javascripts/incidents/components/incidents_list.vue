<script>
import {
  GlLoadingIcon,
  GlTable,
  GlAvatarsInline,
  GlAvatarLink,
  GlAvatar,
  GlTooltipDirective,
  GlButton,
  GlIcon,
  GlEmptyState,
} from '@gitlab/ui';
import TimeAgoTooltip from '~/vue_shared/components/time_ago_tooltip.vue';
import PageWrapper from '~/vue_shared/components/page_wrapper/page_wrapper.vue';
import {
  tdClass,
  thClass,
  bodyTrClass,
  initialPaginationState,
} from '~/vue_shared/components/page_wrapper/constants';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import { convertToSnakeCase } from '~/lib/utils/text_utility';
import { s__ } from '~/locale';
import { visitUrl, mergeUrlParams, joinPaths } from '~/lib/utils/url_utility';
import getIncidents from '../graphql/queries/get_incidents.query.graphql';
import getIncidentsCountByStatus from '../graphql/queries/get_count_by_status.query.graphql';
import SeverityToken from '~/sidebar/components/severity/severity.vue';
import { INCIDENT_SEVERITY } from '~/sidebar/components/severity/constants';
import {
  I18N,
  INCIDENT_STATUS_TABS,
  TH_CREATED_AT_TEST_ID,
  TH_SEVERITY_TEST_ID,
  TH_PUBLISHED_TEST_ID,
  INCIDENT_DETAILS_PATH,
  trackIncidentListViewsOptions,
} from '../constants';

export default {
  trackIncidentListViewsOptions,
  i18n: I18N,
  statusTabs: INCIDENT_STATUS_TABS,
  fields: [
    {
      key: 'severity',
      label: s__('IncidentManagement|Severity'),
      thClass,
      tdClass: `${tdClass} sortable-cell`,
      sortable: true,
      thAttr: TH_SEVERITY_TEST_ID,
    },
    {
      key: 'title',
      label: s__('IncidentManagement|Incident'),
      thClass: `gl-pointer-events-none gl-w-half`,
      tdClass,
    },
    {
      key: 'createdAt',
      label: s__('IncidentManagement|Date created'),
      thClass,
      tdClass: `${tdClass} sortable-cell`,
      sortable: true,
      thAttr: TH_CREATED_AT_TEST_ID,
    },
    {
      key: 'assignees',
      label: s__('IncidentManagement|Assignees'),
      thClass: 'gl-pointer-events-none',
      tdClass,
    },
  ],
  components: {
    GlLoadingIcon,
    GlTable,
    GlAvatarsInline,
    GlAvatarLink,
    GlAvatar,
    GlButton,
    TimeAgoTooltip,
    GlIcon,
    PublishedCell: () => import('ee_component/incidents/components/published_cell.vue'),
    GlEmptyState,
    SeverityToken,
    PageWrapper,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  mixins: [glFeatureFlagsMixin()],
  inject: [
    'projectPath',
    'newIssuePath',
    'incidentTemplateName',
    'incidentType',
    'issuePath',
    'publishedAvailable',
    'emptyListSvgPath',
    'textQuery',
    'authorUsernamesQuery',
    'assigneeUsernamesQuery',
  ],
  apollo: {
    incidents: {
      query: getIncidents,
      variables() {
        return {
          searchTerm: this.searchTerm,
          authorUsername: this.authorUsername,
          assigneeUsernames: this.assigneeUsernames,
          projectPath: this.projectPath,
          status: this.statusFilter,
          issueTypes: ['INCIDENT'],
          sort: this.sort,
          firstPageSize: this.pagination.firstPageSize,
          lastPageSize: this.pagination.lastPageSize,
          prevPageCursor: this.pagination.prevPageCursor,
          nextPageCursor: this.pagination.nextPageCursor,
        };
      },
      update({ project: { issues: { nodes = [], pageInfo = {} } = {} } = {} }) {
        return {
          list: nodes,
          pageInfo,
        };
      },
      error() {
        this.errored = true;
      },
    },
    incidentsCount: {
      query: getIncidentsCountByStatus,
      variables() {
        return {
          searchTerm: this.searchTerm,
          authorUsername: this.authorUsername,
          assigneeUsernames: this.assigneeUsernames,
          projectPath: this.projectPath,
          issueTypes: ['INCIDENT'],
        };
      },
      update(data) {
        return data.project?.issueStatusCounts;
      },
    },
  },
  data() {
    return {
      errored: false,
      isErrorAlertDismissed: false,
      redirecting: false,
      incidents: {},
      incidentsCount: {},
      sort: 'created_desc',
      sortBy: 'createdAt',
      sortDesc: true,
      statusFilter: '',
      filteredByStatus: '',
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
      return this.$apollo.queries.incidents.loading;
    },
    isEmpty() {
      return !this.incidents?.list?.length;
    },
    showList() {
      return !this.isEmpty || this.errored || this.loading;
    },
    tbodyTrClass() {
      return {
        [bodyTrClass]: !this.loading && !this.isEmpty,
      };
    },
    newIncidentPath() {
      return mergeUrlParams(
        {
          issuable_template: this.incidentTemplateName,
          'issue[issue_type]': this.incidentType,
        },
        this.newIssuePath,
      );
    },
    availableFields() {
      return this.publishedAvailable
        ? [
            ...this.$options.fields,
            ...[
              {
                key: 'published',
                label: s__('IncidentManagement|Published'),
                thClass,
                tdClass: `${tdClass} sortable-cell`,
                sortable: true,
                thAttr: TH_PUBLISHED_TEST_ID,
              },
            ],
          ]
        : this.$options.fields;
    },
    activeClosedTabHasNoIncidents() {
      const { all, closed } = this.incidentsCount || {};
      const isClosedTabActive = this.statusFilter === this.$options.statusTabs[1].filters;

      return isClosedTabActive && all && !closed;
    },
    emptyStateData() {
      const {
        emptyState: { title, emptyClosedTabTitle, description },
        createIncidentBtnLabel,
      } = this.$options.i18n;

      if (this.activeClosedTabHasNoIncidents) {
        return { title: emptyClosedTabTitle };
      }
      return {
        title,
        description,
        btnLink: this.newIncidentPath,
        btnText: createIncidentBtnLabel,
      };
    },
  },
  methods: {
    hasAssignees(assignees) {
      return Boolean(assignees.nodes?.length);
    },
    navigateToIncidentDetails({ iid }) {
      const path = this.glFeatures.issuesIncidentDetails
        ? joinPaths(this.issuePath, INCIDENT_DETAILS_PATH)
        : this.issuePath;
      return visitUrl(joinPaths(path, iid));
    },
    fetchSortedData({ sortBy, sortDesc }) {
      const sortingDirection = sortDesc ? 'DESC' : 'ASC';
      const sortingColumn = convertToSnakeCase(sortBy)
        .replace(/_.*/, '')
        .toUpperCase();

      this.pagination = initialPaginationState;
      this.sort = `${sortingColumn}_${sortingDirection}`;
    },
    getSeverity(severity) {
      return INCIDENT_SEVERITY[severity];
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
    <page-wrapper
      :loading="loading"
      :show-items="showList"
      :show-error-msg="showErrorMsg"
      :i18n="$options.i18n"
      :items="incidents.list || []"
      :page-info="incidents.pageInfo"
      :items-count="incidentsCount"
      :status-tabs="$options.statusTabs"
      :track-views-options="trackIncidentListViewsOptions"
      filter-search-key="incidents"
      @page-changed="pageChanged"
      @status-changed="statusChanged"
      @filters-changed="filtersChanged"
      @error-alert-dismissed="errorAlertDismissed"
    >
      <template #header-actions>
        <gl-button
          v-if="!isEmpty || activeClosedTabHasNoIncidents"
          class="gl-my-3 gl-mr-5 create-incident-button"
          data-testid="createIncidentBtn"
          data-qa-selector="create_incident_button"
          :loading="redirecting"
          :disabled="redirecting"
          category="primary"
          variant="success"
          :href="newIncidentPath"
          @click="redirecting = true"
        >
          {{ $options.i18n.createIncidentBtnLabel }}
        </gl-button>
      </template>

      <template #title>
        {{ s__('IncidentManagement|Incidents') }}
      </template>

      <template #table>
        <gl-table
          :items="incidents.list || []"
          :fields="availableFields"
          :show-empty="true"
          :busy="loading"
          stacked="md"
          :tbody-tr-class="tbodyTrClass"
          :no-local-sorting="true"
          :sort-direction="'desc'"
          :sort-desc.sync="sortDesc"
          :sort-by.sync="sortBy"
          sort-icon-left
          fixed
          @row-clicked="navigateToIncidentDetails"
          @sort-changed="fetchSortedData"
        >
          <template #cell(severity)="{ item }">
            <severity-token :severity="getSeverity(item.severity)" />
          </template>

          <template #cell(title)="{ item }">
            <div :class="{ 'gl-display-flex gl-align-items-center': item.state === 'closed' }">
              <div class="gl-max-w-full text-truncate" :title="item.title">{{ item.title }}</div>
              <gl-icon
                v-if="item.state === 'closed'"
                name="issue-close"
                class="gl-mx-1 gl-fill-blue-500 gl-flex-shrink-0"
                :size="16"
                data-testid="incident-closed"
              />
            </div>
          </template>

          <template #cell(createdAt)="{ item }">
            <time-ago-tooltip :time="item.createdAt" />
          </template>

          <template #cell(assignees)="{ item }">
            <div data-testid="incident-assignees">
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

          <template v-if="publishedAvailable" #cell(published)="{ item }">
            <published-cell
              :status-page-published-incident="item.statusPagePublishedIncident"
              :un-published="$options.i18n.unPublished"
            />
          </template>
          <template #table-busy>
            <gl-loading-icon size="lg" color="dark" class="mt-3" />
          </template>

          <template v-if="errored" #empty>
            {{ $options.i18n.noIncidents }}
          </template>
        </gl-table>
      </template>
      <template #emtpy-state>
        <gl-empty-state
          :title="emptyStateData.title"
          :svg-path="emptyListSvgPath"
          :description="emptyStateData.description"
          :primary-button-link="emptyStateData.btnLink"
          :primary-button-text="emptyStateData.btnText"
        />
      </template>
    </page-wrapper>
  </div>
</template>
