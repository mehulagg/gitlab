<script>
import { GlDropdown, GlDropdownItem, GlFormGroup, GlButton } from '@gitlab/ui';
import ProjectSelector from '~/vue_shared/components/project_selector/project_selector.vue';

export default {
  name: 'JiraConnectNewBranch',
  components: {
    ProjectSelector,
    GlDropdown,
    GlDropdownItem,
    GlFormGroup,
    GlButton,
  },
  data() {
    return {
      searchQuery: '',
      projectSearchResults: [],
      selectedProjects: [],
      messages: {
        noResults: false,
        searchError: false,
        minimumQuery: false,
      },
      searchCount: 0,
      pageInfo: {
        endCursor: '',
        hasNextPage: true,
      },
    };
  },
  methods: {
    searched() {},
    toggleSelectedProject() {},
    fetchSearchResults() {},
  },
};
</script>

<template>
  <div>
    <gl-form-group
      class="row align-items-center"
      :invalid-feedback="__('Please select a project')"
      :label="__('Project')"
      label-cols-sm="10"
      label-for="project-select"
    >
      <project-selector
        id="project-select"
        :project-search-results="projectSearchResults"
        :selected-projects="selectedProjects"
        :show-no-results-message="messages.noResults"
        :show-loading-indicator="isSearchingProjects"
        :show-minimum-search-query-message="messages.minimumQuery"
        :show-search-error-message="messages.searchError"
        @searched="searched"
        @projectClicked="toggleSelectedProject"
        @bottomReached="fetchSearchResults"
      />
    </gl-form-group>

    <gl-form-group class="row align-items-center" :label="__('Branch name')" label-cols-sm="10">
      <gl-dropdown>
        <gl-form-input type="text" />
      </gl-dropdown>
    </gl-form-group>

    <gl-form-group
      class="row align-items-center"
      :invalid-feedback="__('Please select a source branch')"
      :label="__('Source branch')"
      label-cols-sm="10"
    >
      <gl-dropdown>
        <gl-dropdown-item v-for="branch in branches" :key="branch">{{ branches }}</gl-dropdown-item>
      </gl-dropdown>
    </gl-form-group>

    <div class="form-actions">
      <gl-button variant="confirm">{{ __('Create branch') }}</gl-button>
    </div>
  </div>
</template>
