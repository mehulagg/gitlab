<script>
import { GlAlert, GlLoadingIcon, GlIntersectionObserver } from '@gitlab/ui';
import axios from 'axios';
import produce from 'immer';
import { last } from 'lodash';
import { __ } from '~/locale';
import securityScannersQuery from '../graphql/queries/project_security_scanners.query.graphql';
import vulnerabilitiesQuery from '../graphql/queries/project_vulnerabilities.query.graphql';
import { preparePageInfo } from '../helpers';
import { VULNERABILITIES_PER_PAGE } from '../store/constants';
import VulnerabilityList from './vulnerability_list.vue';

export default {
  name: 'ProjectVulnerabilitiesApp',
  components: {
    GlAlert,
    GlLoadingIcon,
    GlIntersectionObserver,
    VulnerabilityList,
  },
  inject: {
    projectFullPath: {
      default: '',
    },
    hasJiraVulnerabilitiesIntegrationEnabled: {
      default: false,
    },
  },
  props: {
    filters: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  data() {
    return {
      pageInfo: {},
      vulnerabilities: [],
      securityScanners: {},
      errorLoadingVulnerabilities: false,
      sortBy: 'severity',
      sortDirection: 'desc',
    };
  },
  apollo: {
    vulnerabilities: {
      query: vulnerabilitiesQuery,
      variables() {
        return {
          fullPath: this.projectFullPath,
          first: VULNERABILITIES_PER_PAGE,
          sort: this.sort,
          includeExternalIssueLinks: this.hasJiraVulnerabilitiesIntegrationEnabled,
          ...this.filters,
        };
      },
      update({ project }) {
        return project?.vulnerabilities.nodes || [];
      },
      async result({ data }) {
        const {
          project: {
            webUrl,
            vulnerabilities: { nodes: vulnerabilities },
          },
        } = data;
        const getVulnerabilityId = (vulnerability) => last(vulnerability.id.split('/'));

        const vulnerabilityIds = vulnerabilities.map(getVulnerabilityId);
        const jiraIssuesEndpoint = `${webUrl}/-/integrations/jira/issues`;
        const issuesQuery = vulnerabilityIds.map((id) => `vulnerability_ids[]=${id}`).join('&');
        const url = `${jiraIssuesEndpoint}?${issuesQuery}`;

        const res = await axios.get(url);

        const client = this.$apollo.getClient();

        res.data.forEach((jiraIssue) => {
          const newData = produce(data, (draftData) => {
            const vulnerability = draftData.project.vulnerabilities.nodes.find((v) => {
              return getVulnerabilityId(v) === jiraIssue.vulnerability_ids;
            });
            // eslint-disable-next-line no-param-reassign
            vulnerability.externalIssueLinks.nodes.push([
              {
                __typename: 'VulnerabilityExternalIssueLink',
                id: '1',
                issue: {
                  __typename: 'ExternalIssue',
                  externalTracker: 'jira',
                  webUrl: 'https://mparuszewski-gitlab.atlassian.net/browse/GV-11',
                  title: 'jira',
                  iid: 'JIRA-1',
                },
              },
            ]);
          });
          client.writeQuery({
            query: vulnerabilitiesQuery,
            data: newData,
            variables: {
              includeExternalIssueLinks: true,
            },
          });
        });

        this.pageInfo = preparePageInfo(data?.project?.vulnerabilities?.pageInfo);
      },
      error() {
        this.errorLoadingVulnerabilities = true;
      },
    },
    securityScanners: {
      query: securityScannersQuery,
      variables() {
        return {
          fullPath: this.projectFullPath,
        };
      },
      error() {
        this.securityScanners = {};
      },
      update({ project = {} }) {
        const { available = [], enabled = [], pipelineRun = [] } = project?.securityScanners || {};
        const translateScannerName = (scannerName) =>
          this.$options.i18n[scannerName] || scannerName;

        return {
          available: available.map(translateScannerName),
          enabled: enabled.map(translateScannerName),
          pipelineRun: pipelineRun.map(translateScannerName),
        };
      },
    },
  },
  computed: {
    isLoadingVulnerabilities() {
      return this.$apollo.queries.vulnerabilities.loading;
    },
    isLoadingFirstVulnerabilities() {
      return this.isLoadingVulnerabilities && this.vulnerabilities.length === 0;
    },
    sort() {
      return `${this.sortBy}_${this.sortDirection}`;
    },
  },
  watch: {
    filters() {
      // Clear out the existing vulnerabilities so that the skeleton loader is shown.
      this.vulnerabilities = [];
    },
    sort() {
      // Clear out the existing vulnerabilities so that the skeleton loader is shown.
      this.vulnerabilities = [];
    },
  },
  methods: {
    fetchJiraIssuesForVulnerabilities() {},
    fetchNextPage() {
      if (this.pageInfo.hasNextPage) {
        this.$apollo.queries.vulnerabilities.fetchMore({
          variables: { after: this.pageInfo.endCursor },
          updateQuery: (previousResult, { fetchMoreResult }) => {
            return produce(fetchMoreResult, (draftData) => {
              // eslint-disable-next-line no-param-reassign
              draftData.project.vulnerabilities.nodes = [
                ...previousResult.project.vulnerabilities.nodes,
                ...draftData.project.vulnerabilities.nodes,
              ];
            });
          },
        });
      }
    },
    handleSortChange({ sortBy, sortDesc }) {
      this.sortDirection = sortDesc ? 'desc' : 'asc';
      this.sortBy = sortBy;
    },
  },
  i18n: {
    API_FUZZING: __('API Fuzzing'),
    CONTAINER_SCANNING: __('Container Scanning'),
    COVERAGE_FUZZING: __('Coverage Fuzzing'),
    SECRET_DETECTION: __('Secret Detection'),
    DEPENDENCY_SCANNING: __('Dependency Scanning'),
  },
};
</script>

<template>
  <div>
    <gl-alert v-if="errorLoadingVulnerabilities" :dismissible="false" variant="danger">
      {{
        s__(
          'SecurityReports|Error fetching the vulnerability list. Please check your network connection and try again.',
        )
      }}
    </gl-alert>
    <vulnerability-list
      v-else
      :is-loading="isLoadingFirstVulnerabilities"
      :filters="filters"
      :vulnerabilities="vulnerabilities"
      :security-scanners="securityScanners"
      @sort-changed="handleSortChange"
    />
    <gl-intersection-observer
      v-if="pageInfo.hasNextPage"
      class="text-center"
      @appear="fetchNextPage"
    >
      <gl-loading-icon v-if="isLoadingVulnerabilities" size="md" />
      <span v-else>&nbsp;</span>
    </gl-intersection-observer>
  </div>
</template>
