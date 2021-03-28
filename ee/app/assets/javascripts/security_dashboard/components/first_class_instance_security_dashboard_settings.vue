<script>
import { GlAlert } from '@gitlab/ui';
import projectsQuery from 'ee/security_dashboard/graphql/queries/get_instance_security_dashboard_projects.query.graphql';
import { createProjectLoadingError } from '../helpers';
import ProjectManager from './first_class_project_manager/project_manager.vue';

export default {
  components: {
    ProjectManager,
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
  <gl-alert v-if="hasError" variant="danger">
    {{ errorMessage }}
  </gl-alert>
  <project-manager v-else :projects="projects" />
</template>
