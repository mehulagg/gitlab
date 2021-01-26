<script>
import { mapState, mapActions } from 'vuex';
import {
  GlButton,
  GlDropdown,
  GlDropdownItem,
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
    GlDropdown,
    GlDropdownItem,
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
        <gl-dropdown
          ref="dropdownButton"
          :text="dropdownToggleText"
          class="gl-w-full projects-dropdown"
          menu-class="gl-w-full! gl-overflow-hidden!"
          toggle-class="gl-display-flex gl-align-items-center gl-justify-content-between gl-text-truncate"
          @show="handleDropdownShow"
        >
          <gl-search-box-by-type
            ref="searchInputField"
            v-model="searchKey"
            class="gl-mx-3 gl-mb-2"
            :disabled="projectsFetchInProgress"
          />
          <gl-loading-icon
            v-show="projectsFetchInProgress"
            class="projects-fetch-loading gl-align-items-center gl-p-3"
            size="md"
          />
          <div v-if="!projectsFetchInProgress" class="dropdown-contents gl-overflow-auto gl-p-2">
            <span v-if="!projects.length" class="gl-display-block text-center gl-p-3">{{
              __('No matches found')
            }}</span>
            <gl-dropdown-item
              v-for="project in projects"
              :key="project.id"
              class="gl-w-full"
              :secondary-text="project.namespace.name"
              @click="selectedProject = project"
            >
              <project-avatar :project="project" :size="32" />
              {{ project.name }}
            </gl-dropdown-item>
          </div>
        </gl-dropdown>
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
