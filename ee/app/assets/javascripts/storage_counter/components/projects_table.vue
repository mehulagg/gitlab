<script>
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import Project from './project.vue';
import ProjectWithExcessStorage from './project_with_excess_storage.vue';

export default {
  components: {
    Project,
    ProjectWithExcessStorage,
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    projects: {
      type: Array,
      required: true,
    },
  },
  computed: {
    isAdditionalStorageFlagEnabled() {
      return this.glFeatures.additionalRepoStorageByNamespace;
    },
  },
};
</script>

<template>
  <div class="ci-table" role="grid">
    <div
      class="gl-responsive-table-row table-row-header gl-pl-5 gl-border-t-solid gl-border-t-1 gl-border-gray-100 gl-mt-5 gl-line-height-normal gl-text-black-normal gl-font-base"
      role="row"
    >
      <template v-if="isAdditionalStorageFlagEnabled">
        <div class="table-section section-50 gl-font-weight-bold" role="columnheader">
          {{ __('Project') }}
        </div>
        <div class="table-section section-25 gl-font-weight-bold" role="columnheader">
          {{ __('Usage') }}
        </div>
        <div class="table-section section-25 gl-font-weight-bold" role="columnheader">
          {{ __('Excess storage') }}
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

    <template v-if="isAdditionalStorageFlagEnabled">
      <project-with-excess-storage
        v-for="project in projects"
        :key="project.id"
        :project="project"
      />
    </template>
    <project v-for="project in projects" v-else :key="project.id" :project="project" />
  </div>
</template>
