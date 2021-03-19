<script>
import { GlSearchBoxByType } from '@gitlab/ui';
import { SEARCH_DEBOUNCE_MS } from '~/ref/constants';
import glFeatureFlagsMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import Project from './project.vue';
import ProjectWithExcessStorage from './project_with_excess_storage.vue';
import ProjectsSkeletonLoader from './projects_skeleton_loader.vue';

export default {
  components: {
    Project,
    ProjectsSkeletonLoader,
    ProjectWithExcessStorage,
    GlSearchBoxByType,
  },
  mixins: [glFeatureFlagsMixin()],
  props: {
    projects: {
      type: Array,
      required: true,
    },
    additionalPurchasedStorageSize: {
      type: Number,
      required: true,
    },
    isLoading: {
      type: Boolean,
      required: false,
      default: false,
    },
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
  },
  searchDebounceValue: SEARCH_DEBOUNCE_MS,
};
</script>

<template>
  <div>
    <div
      class="gl-responsive-table-row table-row-header gl-border-t-solid gl-border-t-1 gl-border-gray-100 gl-mt-5 gl-line-height-normal gl-text-black-normal gl-font-base"
      role="row"
    >
      <template v-if="isAdditionalStorageFlagEnabled">
        <div class="table-section section-50 gl-font-weight-bold gl-pl-5" role="columnheader">
          {{ __('Project') }}
        </div>
        <div class="table-section section-15 gl-font-weight-bold" role="columnheader">
          {{ __('Usage') }}
        </div>
        <div class="table-section section-15 gl-font-weight-bold" role="columnheader">
          {{ __('Excess storage') }}
        </div>
        <div class="table-section section-20 gl-font-weight-bold gl-pl-6" role="columnheader">
          <gl-search-box-by-type
            :placeholder="__('Search by name')"
            :debounce="$options.searchDebounceValue"
            @input="(input) => this.$emit('search', input)"
          />
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
    <projects-skeleton-loader v-if="isAdditionalStorageFlagEnabled && isLoading" />
    <template v-else>
      <component
        :is="projectRowComponent"
        v-for="project in projects"
        :key="project.id"
        :project="project"
        :additional-purchased-storage-size="additionalPurchasedStorageSize"
      />
    </template>
  </div>
</template>
