<script>
import { GlAlert } from '@gitlab/ui';
import SecurityDashboardLayout from 'ee/security_dashboard/components/security_dashboard_layout.vue';
import projectsQuery from 'ee/security_dashboard/graphql/queries/get_instance_security_dashboard_projects.query.graphql';
import { createProjectLoadingError } from '../helpers';
import ProjectManager from './first_class_project_manager/project_manager.vue';

export default {
  components: {
    ProjectManager,
    SecurityDashboardLayout,
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
  <security-dashboard-layout>
    <gl-alert v-if="hasError" variant="danger">
      {{ errorMessage }}
    </gl-alert>
    <div v-else class="gl-display-flex gl-justify-content-center">
      <project-manager :projects="projects" />
    </div>
  </security-dashboard-layout>
</template>
