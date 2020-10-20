<script>
import {
  GlDropdown,
  GlDropdownItem,
  GlDropdownDivider,
  GlSearchBoxByType,
  GlButton,
  GlLoadingIcon,
  GlIcon,
  GlSkeletonLoader,
  GlTooltipDirective,
} from '@gitlab/ui';
import { mapState, mapActions } from 'vuex';
import { isEmpty } from 'lodash';
import { visitUrl, setUrlParams } from '~/lib/utils/url_utility';
import { ANY, PROJECT_QUERY_PARAM } from '../constants';

export default {
  name: 'ProjectFilter',
  components: {
    GlDropdown,
    GlDropdownItem,
    GlDropdownDivider,
    GlSearchBoxByType,
    GlButton,
    GlLoadingIcon,
    GlIcon,
    GlSkeletonLoader,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    initialProject: {
      type: Object,
      required: false,
      default: () => {
        return {};
      },
    },
  },
  data() {
    return {
      projectSearch: '',
    };
  },
  computed: {
    ...mapState(['projects', 'fetchingProjects']),
    selectedProject: {
      get() {
        return isEmpty(this.initialProject) ? ANY : this.initialProject;
      },
      set(project) {
        visitUrl(setUrlParams({ [PROJECT_QUERY_PARAM]: project.id }));
      },
    },
  },
  methods: {
    ...mapActions(['fetchProjects']),
    isProjectSelected(project) {
      return project.id === this.selectedProject.id;
    },
    handleProjectChange(project) {
      this.selectedProject = project;
    },
    hideDropdown() {
      this.$refs.projectFilter.hide(true);
    },
  },
  ANY,
};
</script>

<template>
  <gl-dropdown
    ref="projectFilter"
    class="gl-w-full"
    menu-class="gl-w-full!"
    toggle-class="gl-text-truncate"
    @show="fetchProjects(projectSearch)"
  >
    <template #button-content>
      <span class="dropdown-toggle-text gl-flex-grow-1 gl-text-truncate">
        {{ selectedProject.name_with_namespace }}
      </span>
      <gl-loading-icon v-if="fetchingProjects" inline class="mr-2" />
      <gl-icon
        v-if="selectedProject.id !== $options.ANY.id"
        v-gl-tooltip
        name="clear"
        :title="__('Clear')"
        class="gl-text-gray-200! gl-hover-text-blue-800!"
        @click.stop="handleProjectChange($options.ANY)"
      />
      <gl-icon name="chevron-down" />
    </template>
    <div class="gl-sticky gl-top-0 gl-z-index-1 gl-bg-white">
      <div
        class="gl-display-flex gl-align-items-center gl-justify-content-center gl-relative gl-mb-3"
      >
        <header class="gl-font-weight-bold">{{ __('Filter results by project') }}</header>
        <gl-button
          icon="close"
          category="tertiary"
          class="gl-absolute gl-right-1"
          @click="hideDropdown"
        />
      </div>
      <gl-dropdown-divider />
      <gl-search-box-by-type
        v-model="projectSearch"
        class="m-2"
        :debounce="500"
        @input="fetchProjects"
      />
      <gl-dropdown-item
        class="gl-border-b-solid gl-border-b-gray-100 gl-border-b-1 gl-pb-2! gl-mb-2"
        :is-check-item="true"
        :is-checked="isProjectSelected($options.ANY)"
        @click="handleProjectChange($options.ANY)"
      >
        {{ $options.ANY.name }}
      </gl-dropdown-item>
    </div>
    <div v-if="!fetchingProjects">
      <gl-dropdown-item
        v-for="project in projects"
        :key="project.id"
        :is-check-item="true"
        :is-checked="isProjectSelected(project)"
        @click="handleProjectChange(project)"
      >
        {{ project.name_with_namespace }}
      </gl-dropdown-item>
    </div>
    <div v-if="fetchingProjects" class="mx-3 mt-2">
      <gl-skeleton-loader :height="100">
        <rect y="0" width="90%" height="20" rx="4" />
        <rect y="40" width="70%" height="20" rx="4" />
        <rect y="80" width="80%" height="20" rx="4" />
      </gl-skeleton-loader>
    </div>
  </gl-dropdown>
</template>
