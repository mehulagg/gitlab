<script>
import { GlDropdown, GlDropdownItem, GlTooltipDirective, GlLink, GlIcon } from '@gitlab/ui';
import { s__ } from '~/locale';
import ProjectAvatar from '~/vue_shared/components/project_avatar/default.vue';

export default {
  components: {
    GlDropdown,
    GlDropdownItem,
    GlIcon,
    ProjectAvatar,
    GlLink,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    project: {
      type: Object,
      required: true,
    },
  },
  methods: {
    onRemove() {
      this.$emit('remove', this.project.remove_path);
    },
  },

  removeProjectText: s__('EnvironmentsDashboard|Remove'),
  moreActionsText: s__('EnvironmentsDashboard|More actions'),
};
</script>

<template>
  <div
    class="gl-display-flex align-items-center page-title-holder text-secondary gl-justify-content-between pb-2 mb-3"
  >
    <div class="gl-display-flex align-items-center">
      <project-avatar :project="project.namespace" :size="20" class="flex-shrink-0" />
      <gl-link class="js-namespace-link text-secondary" :href="`/${project.namespace.full_path}`">
        <span class="js-namespace gl-mr-3"> {{ project.namespace.name }} </span>
      </gl-link>
      <span class="gl-mr-3">&gt;</span>
      <project-avatar :project="project" :size="20" class="flex-shrink-0" />
      <gl-link class="js-project-link text-secondary" :href="project.web_url">
        <span class="js-name gl-mr-3"> {{ project.name }} </span>
      </gl-link>
    </div>
    <div class="dropdown js-more-actions">
      <gl-dropdown
        toggle-class="js-more-actions-toggle gl-display-flex align-items-center ml-2 gl-bg-transparent"
      >
        <template #button-content>
          <span v-gl-tooltip data-toggle="dropdown" :title="$options.moreActionsText">
            <gl-icon name="ellipsis_v" class="text-secondary" />
          </span>
        </template>
        <gl-dropdown-item class="js-remove-button" variant="link" @click="onRemove()">
          <span class="text-danger"> {{ $options.removeProjectText }} </span>
        </gl-dropdown-item>
      </gl-dropdown>
    </div>
  </div>
</template>
