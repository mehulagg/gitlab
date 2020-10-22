<script>
import { GlSearchBoxByType } from '@gitlab/ui';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import Project from './project.vue';
import ProjectWithExcessStorage from './project_with_excess_storage.vue';

export default {
  components: {
    Project,
    ProjectWithExcessStorage,
    GlSearchBoxByType,
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    projects: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      projectFilter: '',
    }
  },
  computed: {
    isAdditionalStorageFlagEnabled() {
      return this.glFeatures.additionalRepoStorageByNamespace;
    },
    projectRowComponent() {
      if (this.isAdditionalStorageFlagEnabled) {
        return ProjectWithExcessStorage;
      }
      return Project;
    },
    filteredProjects () {
      if (this.projectFilter) {
        const regex = new RegExp(`.*(${this.projectFilter}).*`, 'i');
        return this.projects.filter((project) => regex.test(project.name));
      }
      return this.projects;
    }
  },
};
</script>

<template>
  <div>
    <div
      class="gl-responsive-table-row table-row-header gl-border-t-solid gl-border-t-1 gl-border-gray-100 gl-mt-5 gl-line-height-normal gl-text-black-normal gl-font-base"
      role="row"
    >
      <template v-if="isAdditionalStorageFlagEnabled">
        <div class="table-section section-50 gl-font-weight-bold  gl-pl-5" role="columnheader">
          {{ __('Project') }}
        </div>
        <div class="table-section section-15 gl-font-weight-bold" role="columnheader">
          {{ __('Usage') }}
        </div>
        <div class="table-section section-15 gl-font-weight-bold" role="columnheader">
          {{ __('Excess storage') }}
        </div>
        <div class="table-section section-20 gl-font-weight-bold gl-pl-6" role="columnheader">
          <gl-search-box-by-type v-model="projectFilter" />
        </div>
      </template>
      <template v-else>
        <div class="table-section section-70 gl-font-weight-bold" role="columnheader">
          {{ __('Project') }}
        </div>
        <div class="table-section section-30 gl-font-weight-bold" role="columnheader">
          {{ __('Usage') }}
        </div>
      </template>
    </div>

    <component
      :is="projectRowComponent"
      v-for="project in filteredProjects"
      :key="project.id"
      :project="project"
    />
  </div>
</template>
