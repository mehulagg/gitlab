<script>
import { GlLoadingIcon } from '@gitlab/ui';
import createFlash from '~/flash';
import groupProjectsSearch from '../graphql/queries/group_projects_search.query.graphql';
import vulnerabilityGradesQuery from '../graphql/queries/group_vulnerability_grades.query.graphql';
import vulnerabilityHistoryQuery from '../graphql/queries/group_vulnerability_history.query.graphql';
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
      query: groupProjectsSearch,
      variables() {
        return {
          fullPath: this.groupFullPath,
          pageSize: 1,
        };
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
  },
};
</script>

<template>
  <security-charts-layout>
    <template v-if="isLoadingProjects" #loading>
      <gl-loading-icon size="lg" class="gl-mt-6" />
    </template>
    <template v-else-if="!projects.length" #empty-state>
      <no-group-projects />
    </template>
    <template v-else #default>
      <vulnerability-chart :query="vulnerabilityHistoryQuery" :group-full-path="groupFullPath" />
      <vulnerability-severities
        :query="vulnerabilityGradesQuery"
        :group-full-path="groupFullPath"
      />
    </template>
  </security-charts-layout>
</template>
