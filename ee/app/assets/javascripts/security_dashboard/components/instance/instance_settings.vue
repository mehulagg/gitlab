<script>
import { GlAlert } from '@gitlab/ui';
import VulnerabilityReportLayout from 'ee/security_dashboard/components/shared/vulnerability_report_layout.vue';
import projectsQuery from 'ee/security_dashboard/graphql/queries/get_instance_security_dashboard_projects.query.graphql';
import { createProjectLoadingError } from '../../helpers';
import ProjectManager from './instance_settings_project_manager.vue';

export default {
  components: {
    ProjectManager,
    VulnerabilityReportLayout,
    GlAlert,
  },
  apollo: {
    projects: {
      query: projectsQuery,
      update(data) {
        return data.instanceSecurityDashboard.projects.nodes;
      },
      error() {
        this.hasError = true;
      },
    },
  },
  data() {
    return {
      projects: [],
      hasError: false,
    };
  },
  computed: {
    errorMessage() {
      return createProjectLoadingError();
    },
  },
};
</script>

<template>
  <vulnerability-report-layout>
    <gl-alert v-if="hasError" variant="danger">
      {{ errorMessage }}
    </gl-alert>
    <div v-else class="gl-display-flex gl-justify-content-center">
      <project-manager :projects="projects" />
    </div>
  </vulnerability-report-layout>
</template>
