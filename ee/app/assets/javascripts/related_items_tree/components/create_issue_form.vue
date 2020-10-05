<script>
import { mapState, mapActions } from 'vuex';
import {
  GlButton,
  GlDeprecatedDropdown,
  GlDeprecatedDropdownItem,
  GlFormInput,
  GlSearchBoxByType,
  GlLoadingIcon,
} from '@gitlab/ui';
import { debounce } from 'lodash';

import { __ } from '~/locale';
import ProjectAvatar from '~/vue_shared/components/project_avatar/default.vue';
import { SEARCH_DEBOUNCE } from '../constants';

export default {
  components: {
    GlButton,
    GlDeprecatedDropdown,
    GlDeprecatedDropdownItem,
    GlFormInput,
    GlSearchBoxByType,
    GlLoadingIcon,
    ProjectAvatar,
  },
  data() {
    return {
      selectedProject: null,
      searchKey: '',
      title: '',
      preventDropdownClose: false,
    };
  },
  computed: {
    ...mapState(['projectsFetchInProgress', 'itemCreateInProgress', 'projects', 'parentItem']),
    dropdownToggleText() {
      if (this.selectedProject) {
        return this.selectedProject.name_with_namespace;
      }

      return __('Select a project');
    },
  },
  watch: {
    /**
     * We're using `debounce` here as `GlSearchBoxByType` doesn't
     * support `lazy` or `debounce` props as per https://bootstrap-vue.js.org/docs/components/form-input/.
     * This is a known GitLab UI issue https://gitlab.com/gitlab-org/gitlab-ui/-/issues/631
     */
    searchKey: debounce(function debounceSearch() {
      this.fetchProjects(this.searchKey);
    }, SEARCH_DEBOUNCE),
    /**
     * As Issue Create Form already has `autofocus` set for
     * Issue title field, we cannot leverage `autofocus` prop
     * again for search input field, so we manually set
     * focus only when dropdown is opened and content is loaded.
     */
    projectsFetchInProgress(value) {
      if (!value) {
        this.$nextTick(() => {
          this.$refs.searchInputField.focusInput();
        });
      }
    },
  },
  methods: {
    ...mapActions(['fetchProjects']),
    cancel() {
      this.$emit('cancel');
    },
    createIssue() {
      if (!this.selectedProject) {
        return;
      }

      const { selectedProject, title } = this;
      const { issues: issuesEndpoint } = selectedProject._links;
      this.$emit('submit', { issuesEndpoint, title });
    },
    handleDropdownShow() {
      this.searchKey = '';
      this.fetchProjects();
    },
    handleDropdownHide(e) {
      // Check if dropdown closure is to be prevented.
      if (this.preventDropdownClose) {
        e.preventDefault();
        this.preventDropdownClose = false;
      }
    },
    /**
     * As GlDropdown can get closed if any item within
     * it is clicked, we have to work around that behaviour
     * by preventing dropdown close if user has clicked
     * clear button on search input field. This hack
     * won't be required once we add support for
     * `BDropdownForm` https://bootstrap-vue.js.org/docs/components/dropdown#b-dropdown-form
     * within GitLab UI.
     */
    handleSearchInputContainerClick({ target }) {
      // Check if clicked target was an icon.
      if (
        target?.classList.contains('gl-icon') ||
        target?.getAttribute('href')?.includes('clear')
      ) {
        // Enable flag to prevent dropdown close.
        this.preventDropdownClose = true;
      }
    },
  },
};
</script>

<template>
  <div>
    <div class="row mb-3">
      <div class="col-sm">
        <label class="label-bold">{{ s__('Issue|Title') }}</label>
        <gl-form-input
          ref="titleInput"
          v-model.trim="title"
          :placeholder="
            parentItem.confidential ? __('New confidential issue title') : __('New issue title')
          "
          autofocus
        />
      </div>
      <div class="col-sm">
        <label class="label-bold">{{ __('Project') }}</label>
        <gl-deprecated-dropdown
          ref="dropdownButton"
          :text="dropdownToggleText"
          class="w-100 projects-dropdown"
          menu-class="w-100 overflow-hidden"
          toggle-class="d-flex align-items-center justify-content-between text-truncate"
          @show="handleDropdownShow"
          @hide="handleDropdownHide"
        >
          <div class="mx-2 mb-1" @click="handleSearchInputContainerClick">
            <gl-search-box-by-type
              ref="searchInputField"
              v-model="searchKey"
              :disabled="projectsFetchInProgress"
            />
          </div>
          <gl-loading-icon
            v-show="projectsFetchInProgress"
            class="projects-fetch-loading align-items-center p-2"
            size="md"
          />
          <div v-if="!projectsFetchInProgress" class="dropdown-contents overflow-auto p-1">
            <span v-if="!projects.length" class="d-block text-center p-2">{{
              __('No matches found')
            }}</span>
            <gl-deprecated-dropdown-item
              v-for="project in projects"
              :key="project.id"
              class="w-100"
              @click="selectedProject = project"
            >
              <project-avatar :project="project" :size="32" />
              {{ project.name }}
              <div class="text-secondary">{{ project.namespace.name }}</div>
            </gl-deprecated-dropdown-item>
          </div>
        </gl-deprecated-dropdown>
      </div>
    </div>

    <div class="row my-1">
      <div class="col-sm flex-sm-grow-0 mb-2 mb-sm-0">
        <gl-button
          class="w-100"
          variant="success"
          category="primary"
          :disabled="!selectedProject || itemCreateInProgress"
          :loading="itemCreateInProgress"
          @click="createIssue"
          >{{ __('Create issue') }}</gl-button
        >
      </div>
      <div class="col-sm flex-sm-grow-0 ml-auto">
        <gl-button class="w-100" @click="cancel">{{ __('Cancel') }}</gl-button>
      </div>
    </div>
  </div>
</template>
