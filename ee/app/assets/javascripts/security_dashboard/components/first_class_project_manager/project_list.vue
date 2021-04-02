<script>
import { GlBadge, GlButton, GlLoadingIcon, GlTooltipDirective } from '@gitlab/ui';
import { PROJECT_LOADING_ERROR_MESSAGE } from 'ee/security_dashboard/helpers';
import createFlash from '~/flash';
import ProjectAvatar from '~/vue_shared/components/project_avatar/default.vue';
import projectsQuery from '../../graphql/queries/instance_projects.query.graphql';

export default {
  components: {
    GlBadge,
    GlButton,
    GlLoadingIcon,
    ProjectAvatar,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  apollo: {
    projects: {
      query: projectsQuery,
      update(data) {
        return data.instanceSecurityDashboard.projects.nodes;
      },
      error() {
        createFlash({ message: PROJECT_LOADING_ERROR_MESSAGE });
      },
    },
  },
  data: () => ({
    projects: [],
  }),
  computed: {
    isLoadingProjects() {
      return this.$apollo.queries.projects.loading;
    },
  },
  methods: {
    projectRemoved(project) {
      this.$emit('projectRemoved', project);
    },
  },
};
</script>

<template>
  <section>
    <h4 class="h5 font-weight-bold text-secondary border-bottom mb-3 pb-2">
      {{ s__('SecurityReports|Projects added') }}
      <gl-badge class="gl-font-weight-bold">{{ projects.length }}</gl-badge>
      <gl-loading-icon v-if="isLoadingProjects" size="sm" class="float-right" />
    </h4>
    <ul v-if="projects.length" class="list-unstyled">
      <li
        v-for="project in projects"
        :key="project.id"
        class="d-flex align-items-center py-1 js-projects-list-project-item"
      >
        <project-avatar class="flex-shrink-0" :project="project" :size="32" />
        {{ project.nameWithNamespace }}
        <gl-button
          v-gl-tooltip
          icon="remove"
          class="gl-ml-auto js-projects-list-project-remove"
          :title="s__('SecurityReports|Remove project from dashboard')"
          @click="projectRemoved(project)"
        />
      </li>
    </ul>
    <p v-else class="text-secondary js-projects-list-empty-message">
      {{ s__('SecurityReports|Select a project to add by using the project search field above.') }}
    </p>
  </section>
</template>
