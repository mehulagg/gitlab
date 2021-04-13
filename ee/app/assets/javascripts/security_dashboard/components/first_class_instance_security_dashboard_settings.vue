<script>
import { GlAlert } from '@gitlab/ui';
import SecurityDashboardLayout from 'ee/security_dashboard/components/security_dashboard_layout.vue';
import instanceProjectsQuery from 'ee/security_dashboard/graphql/queries/instance_projects.query.graphql';
import { PROJECT_LOADING_ERROR_MESSAGE } from '../helpers';
import ProjectManager from './first_class_project_manager/project_manager.vue';

export default {
  components: {
    ProjectManager,
    SecurityDashboardLayout,
    GlAlert,
  },
  apollo: {
    projects: {
      query: instanceProjectsQuery,
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
  PROJECT_LOADING_ERROR_MESSAGE,
};
</script>

<template>
  <security-dashboard-layout>
    <gl-alert v-if="hasError" variant="danger">
      {{ $options.PROJECT_LOADING_ERROR_MESSAGE }}
    </gl-alert>
    <div v-else class="gl-display-flex gl-justify-content-center">
      <project-manager :projects="projects" />
    </div>
  </security-dashboard-layout>
</template>
