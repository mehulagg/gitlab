<script>
import { GlBadge, GlButton, GlLoadingIcon, GlTooltipDirective } from '@gitlab/ui';
import { s__ } from '~/locale';
import ProjectAvatar from '~/vue_shared/components/project_avatar/default.vue';

export default {
  i18n: {
    removeLabel: s__('SecurityReports|Remove project from dashboard'),
  },
  components: {
    GlBadge,
    GlButton,
    GlLoadingIcon,
    ProjectAvatar,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    projects: {
      type: Array,
      required: true,
    },
    showLoadingIndicator: {
      type: Boolean,
      required: true,
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
    <div>
      <h4 class="h5 font-weight-bold text-secondary border-bottom mb-3 pb-2">
        {{ s__('SecurityReports|Projects added') }}
        <gl-badge class="gl-font-weight-bold">{{ projects.length }}</gl-badge>
        <gl-loading-icon v-if="showLoadingIndicator" size="sm" class="float-right" />
      </h4>
      <ul v-if="projects.length" class="list-unstyled">
        <li
          v-for="project in projects"
          :key="project.id"
          class="d-flex align-items-center py-1 js-projects-list-project-item"
        >
          <project-avatar class="flex-shrink-0" :project="project" :size="32" />
          <span>
            {{ project.name_with_namespace || project.nameWithNamespace }}
          </span>
          <gl-button
            v-gl-tooltip
            icon="remove"
            class="gl-ml-auto js-projects-list-project-remove"
            :title="$options.i18n.removeLabel"
            :aria-label="$options.i18n.removeLabel"
            @click="projectRemoved(project)"
          />
        </li>
      </ul>
      <p v-else class="text-secondary js-projects-list-empty-message">
        {{
          s__('SecurityReports|Select a project to add by using the project search field above.')
        }}
      </p>
    </div>
  </section>
</template>
