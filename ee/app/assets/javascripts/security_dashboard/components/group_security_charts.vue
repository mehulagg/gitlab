<script>
import { GlLoadingIcon } from '@gitlab/ui';
import createFlash from '~/flash';
import { s__ } from '~/locale';
import vulnerabilityGradesQuery from '../graphql/queries/group_vulnerability_grades.query.graphql';
import vulnerabilityHistoryQuery from '../graphql/queries/group_vulnerability_history.query.graphql';
import vulnerableProjectsQuery from '../graphql/queries/vulnerable_projects.query.graphql';
import { createProjectLoadingError } from '../helpers';
import NoGroupProjects from './empty_states/no_group_projects.vue';
import VulnerabilityChart from './first_class_vulnerability_chart.vue';
import VulnerabilitySeverities from './first_class_vulnerability_severities.vue';
import SecurityChartsLayout from './security_charts_layout.vue';

export default {
  components: {
    GlLoadingIcon,
    NoGroupProjects,
    SecurityChartsLayout,
    VulnerabilitySeverities,
    VulnerabilityChart,
  },
  props: {
    groupFullPath: {
      type: String,
      required: true,
    },
  },
  apollo: {
    projects: {
      query: vulnerableProjectsQuery,
      variables() {
        return { fullPath: this.groupFullPath };
      },
      update(data) {
        return data?.group?.projects?.nodes ?? [];
      },
      error() {
        createFlash({ message: createProjectLoadingError() });
      },
    },
  },
  data() {
    return {
      projects: [],
      vulnerabilityHistoryQuery,
      vulnerabilityGradesQuery,
    };
  },
  computed: {
    isLoadingProjects() {
      return this.$apollo.queries.projects.loading;
    },
    shouldShowCharts() {
      return Boolean(!this.isLoadingProjects && this.projects.length);
    },
    shouldShowEmptyState() {
      return !this.isLoadingProjects && !this.projects.length;
    },
  },
  i18n: {
    noProjectsMessage: s__(
      'SecurityReports|The security dashboard displays the latest security findings for projects you wish to monitor. Add projects to your group to view their vulnerabilities here.',
    ),
  },
};
</script>

<template>
  <security-charts-layout>
    <template v-if="shouldShowEmptyState" #empty-state>
      <no-group-projects :message="$options.i18n.noProjectsMessage" />
    </template>
    <template v-else-if="shouldShowCharts" #default>
      <vulnerability-chart :query="vulnerabilityHistoryQuery" :group-full-path="groupFullPath" />
      <vulnerability-severities
        :query="vulnerabilityGradesQuery"
        :group-full-path="groupFullPath"
      />
    </template>
    <template v-else #loading>
      <gl-loading-icon size="lg" class="gl-mt-6" />
    </template>
  </security-charts-layout>
</template>
