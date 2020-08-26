<script>
import { GlLoadingIcon, GlButton } from '@gitlab/ui';
import SecurityDashboardLayout from 'ee/security_dashboard/components/security_dashboard_layout.vue';
import VulnerabilitySeverities from 'ee/security_dashboard/components/first_class_vulnerability_severities.vue';
import VulnerabilityChart from 'ee/security_dashboard/components/first_class_vulnerability_chart.vue';
import Filters from 'ee/security_dashboard/components/first_class_vulnerability_filters.vue';
import projectsQuery from 'ee/security_dashboard/graphql/get_instance_security_dashboard_projects.query.graphql';
import InstanceSecurityVulnerabilities from './first_class_instance_security_dashboard_vulnerabilities.vue';
import { __, s__ } from '~/locale';
import { deprecatedCreateFlash as createFlash } from '~/flash';
import ProjectManager from './first_class_project_manager/project_manager.vue';
import CsvExportButton from './csv_export_button.vue';
import vulnerabilityHistoryQuery from '../graphql/instance_vulnerability_history.query.graphql';
import vulnerabilityGradesQuery from '../graphql/instance_vulnerability_grades.query.graphql';
import DashboardNotConfigured from './empty_states/instance_dashboard_not_configured.vue';

export default {
  components: {
    ProjectManager,
    CsvExportButton,
    SecurityDashboardLayout,
    InstanceSecurityVulnerabilities,
    VulnerabilitySeverities,
    VulnerabilityChart,
    Filters,
    GlLoadingIcon,
    GlButton,
    DashboardNotConfigured,
  },
  props: {
    vulnerabilitiesExportEndpoint: {
      type: String,
      required: true,
    },
  },
  apollo: {
    projects: {
      query: projectsQuery,
      update(data) {
        return data.instanceSecurityDashboard.projects.nodes;
      },
      error() {
        createFlash(__('Something went wrong, unable to get projects'));
      },
    },
  },
  data() {
    return {
      filters: {},
      showProjectSelector: false,
      vulnerabilityHistoryQuery,
      vulnerabilityGradesQuery,
      projects: [],
      isManipulatingProjects: false,
    };
  },
  computed: {
    isLoadingProjects() {
      return this.$apollo.queries.projects.loading;
    },
    isUpdatingProjects() {
      return this.isLoadingProjects || this.isManipulatingProjects;
    },
    hasProjectsData() {
      return !this.isUpdatingProjects && this.projects.length > 0;
    },
    shouldShowDashboard() {
      return this.hasProjectsData && !this.showProjectSelector;
    },
    shouldShowEmptyState() {
      return !this.hasProjectsData && !this.showProjectSelector && !this.isUpdatingProjects;
    },
    toggleButtonProps() {
      return this.showProjectSelector
        ? {
            text: s__('SecurityReports|Return to dashboard'),
          }
        : {
            text: s__('SecurityReports|Edit dashboard'),
          };
    },
  },
  methods: {
    handleFilterChange(filters) {
      this.filters = filters;
    },
    toggleProjectSelector() {
      this.showProjectSelector = !this.showProjectSelector;
    },
    handleProjectManipulation(value) {
      this.isManipulatingProjects = value;
    },
  },

  emits: [],
};
</script>

<template>
  <security-dashboard-layout>
    <template #header>
      <header class="page-title-holder flex-fill d-flex align-items-center">
        <h2 class="page-title flex-grow">{{ s__('SecurityReports|Security Dashboard') }}</h2>
        <csv-export-button
          v-if="shouldShowDashboard"
          :vulnerabilities-export-endpoint="vulnerabilitiesExportEndpoint"
        />
        <gl-button
          class="page-title-controls ml-2"
          :variant="toggleButtonProps.variant"
          @click="toggleProjectSelector"
          >{{ toggleButtonProps.text }}</gl-button
        >
      </header>
    </template>
    <template #sticky>
      <filters v-if="shouldShowDashboard" :projects="projects" @filterChange="handleFilterChange" />
    </template>
    <instance-security-vulnerabilities
      v-if="shouldShowDashboard"
      :projects="projects"
      :filters="filters"
    />
    <dashboard-not-configured
      v-else-if="shouldShowEmptyState"
      @handleAddProjectsClick="toggleProjectSelector"
    />
    <div v-else class="d-flex justify-content-center">
      <project-manager
        v-if="showProjectSelector"
        :projects="projects"
        :is-manipulating-projects="isManipulatingProjects"
        @handle-project-manipulation="handleProjectManipulation"
      />
      <gl-loading-icon v-else size="lg" class="mt-4" />
    </div>
    <template #aside>
      <template v-if="shouldShowDashboard">
        <vulnerability-chart :query="vulnerabilityHistoryQuery" class="mb-4" />
        <vulnerability-severities :query="vulnerabilityGradesQuery" />
      </template>
    </template>
  </security-dashboard-layout>
</template>
