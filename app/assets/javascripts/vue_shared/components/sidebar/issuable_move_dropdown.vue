<script>
import {
  GlIcon,
  GlLoadingIcon,
  GlDropdown,
  GlDropdownForm,
  GlDropdownItem,
  GlSearchBoxByType,
  GlButton,
  GlTooltipDirective as GlTooltip,
} from '@gitlab/ui';

import axios from '~/lib/utils/axios_utils';

export default {
  components: {
    GlIcon,
    GlLoadingIcon,
    GlDropdown,
    GlDropdownForm,
    GlDropdownItem,
    GlSearchBoxByType,
    GlButton,
  },
  directives: {
    GlTooltip,
  },
  props: {
    projectsFetchPath: {
      type: String,
      required: true,
    },
    dropdownButtonTitle: {
      type: String,
      required: true,
    },
    dropdownHeaderTitle: {
      type: String,
      required: true,
    },
    moveInProgress: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      projectsListLoading: false,
      projectsListLoadFailed: false,
      searchKey: '',
      projects: [],
      selectedProject: null,
      projectItemClick: false,
    };
  },
  watch: {
    searchKey(value = '') {
      this.fetchProjects(value);
    },
  },
  methods: {
    fetchProjects(search = '') {
      this.projectsListLoading = true;
      this.projectsListLoadFailed = false;
      return axios
        .get(this.projectsFetchPath, {
          params: {
            search,
          },
        })
        .then(({ data }) => {
          this.projects = data;
          this.$refs.searchInput.focusInput();
        })
        .catch(() => {
          this.projectsListLoadFailed = true;
        })
        .finally(() => {
          this.projectsListLoading = false;
        });
    },
    isSelectedProject(project) {
      if (this.selectedProject) {
        return this.selectedProject.id === project.id;
      }
      return false;
    },
    handleDropdownHide(e) {
      if (this.projectItemClick) {
        e.preventDefault();
        this.projectItemClick = false;
      }
      this.$emit('dropdown-close');
    },
    handleDropdownCloseClick() {
      this.$refs.dropdown.hide();
    },
    handleProjectSelect(project) {
      this.selectedProject = !this.selectedProject ? project : null;
      this.projectItemClick = true;
    },
    handleMoveClick() {
      this.$refs.dropdown.hide();
      this.$emit('move-issuable', this.selectedProject);
    },
  },
};
</script>

<template>
  <div class="block js-issuable-move-block issuable-move-dropdown sidebar-move-issue-dropdown">
    <div
      v-gl-tooltip.left.viewport
      :title="dropdownButtonTitle"
      class="sidebar-collapsed-icon"
      @click="$emit('toggle-collapse')"
    >
      <gl-icon name="arrow-right" />
    </div>
    <gl-dropdown
      ref="dropdown"
      :block="true"
      :disabled="moveInProgress"
      class="hide-collapsed"
      toggle-class="js-sidebar-dropdown-toggle"
      @shown="fetchProjects"
      @hide="handleDropdownHide"
    >
      <template #button-content
        ><gl-loading-icon v-if="moveInProgress" class="gl-mr-3" />{{
          dropdownButtonTitle
        }}</template
      >
      <gl-dropdown-form class="gl-pt-0">
        <div class="gl-display-flex gl-pb-3 gl-border-1 gl-border-b-solid gl-border-gray-100">
          <span class="gl-flex-grow-1 gl-text-center gl-font-weight-bold gl-py-1">{{
            dropdownHeaderTitle
          }}</span>
          <button class="gl-mr-2 gl-w-auto! gl-p-2!" @click.prevent="handleDropdownCloseClick">
            <gl-icon name="close" />
          </button>
        </div>
        <gl-search-box-by-type
          ref="searchInput"
          v-model.trim="searchKey"
          :placeholder="__('Search project')"
          :debounce="300"
        />
        <div class="dropdown-content">
          <gl-loading-icon v-if="projectsListLoading" size="md" class="gl-p-5" />
          <ul v-else>
            <gl-dropdown-item
              v-for="project in projects"
              :key="project.id"
              :is-check-item="true"
              :is-checked="isSelectedProject(project)"
              @click.stop.prevent="handleProjectSelect(project)"
              >{{ project.name_with_namespace }}</gl-dropdown-item
            >
          </ul>
          <div v-if="!projectsListLoading && !projects.length" class="gl-text-center gl-p-3">
            {{ __('No matching results') }}
          </div>
          <div v-if="!projectsListLoading && projectsListLoadFailed" class="gl-text-center gl-p-3">
            {{ __('Failed to load projects!') }}
          </div>
        </div>
        <div class="gl-pt-3 gl-px-3 gl-border-1 gl-border-t-solid gl-border-gray-100">
          <gl-button
            category="primary"
            variant="success"
            :disabled="!Boolean(selectedProject)"
            class="gl-text-center! issuable-move-button"
            @click="handleMoveClick"
            >{{ __('Move') }}</gl-button
          >
        </div>
      </gl-dropdown-form>
    </gl-dropdown>
  </div>
</template>
