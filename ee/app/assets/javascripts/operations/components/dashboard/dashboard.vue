<script>
import {
  GlDashboardSkeleton,
  GlButton,
  GlEmptyState,
  GlLink,
  GlModal,
  GlModalDirective,
} from '@gitlab/ui';
import VueDraggable from 'vuedraggable';
import { mapState, mapActions } from 'vuex';
import ProjectSelector from '~/vue_shared/components/project_selector/project_selector.vue';
import DashboardProject from './project.vue';

export default {
  components: {
    DashboardProject,
    GlDashboardSkeleton,
    GlButton,
    GlEmptyState,
    GlLink,
    GlModal,
    ProjectSelector,
    VueDraggable,
  },
  directives: {
    'gl-modal': GlModalDirective,
  },
  props: {
    addPath: {
      type: String,
      required: true,
    },
    listPath: {
      type: String,
      required: true,
    },
    emptyDashboardSvgPath: {
      type: String,
      required: true,
    },
    emptyDashboardHelpPath: {
      type: String,
      required: true,
    },
  },
  modalId: 'add-projects-modal',
  computed: {
    ...mapState([
      'isLoadingProjects',
      'selectedProjects',
      'projectSearchResults',
      'searchCount',
      'messages',
      'pageInfo',
    ]),
    projects: {
      get() {
        return this.$store.state.projects;
      },
      set(projects) {
        this.setProjects(projects);
      },
    },
    isSearchingProjects() {
      return this.searchCount > 0;
    },
    okDisabled() {
      return Object.keys(this.selectedProjects).length === 0;
    },
  },
  created() {
    this.setProjectEndpoints({
      list: this.listPath,
      add: this.addPath,
    });
    this.fetchProjects();
  },
  methods: {
    ...mapActions([
      'fetchNextPage',
      'fetchSearchResults',
      'addProjectsToDashboard',
      'fetchProjects',
      'setProjectEndpoints',
      'clearSearchResults',
      'toggleSelectedProject',
      'setSearchQuery',
      'setProjects',
    ]),
    addProjects() {
      this.addProjectsToDashboard();
    },
    onCancel() {
      this.clearSearchResults();
    },
    onOk() {
      this.addProjectsToDashboard().then(this.clearSearchResults).catch(this.clearSearchResults);
    },
    searched(query) {
      this.setSearchQuery(query);
      this.fetchSearchResults();
    },
    projectClicked(project) {
      this.toggleSelectedProject(project);
    },
  },
};
</script>

<template>
  <div class="operations-dashboard">
    <gl-modal
      :modal-id="$options.modalId"
      :title="s__('OperationsDashboard|Add projects')"
      :ok-title="s__('OperationsDashboard|Add projects')"
      :ok-disabled="okDisabled"
      ok-variant="success"
      data-qa-selector="add_projects_modal"
      @cancel="onCancel"
      @ok="onOk"
    >
      <project-selector
        ref="projectSelector"
        :project-search-results="projectSearchResults"
        :selected-projects="selectedProjects"
        :show-no-results-message="messages.noResults"
        :show-loading-indicator="isSearchingProjects"
        :show-minimum-search-query-message="messages.minimumQuery"
        :show-search-error-message="messages.searchError"
        :total-results="pageInfo.totalResults"
        @searched="searched"
        @projectClicked="projectClicked"
        @bottomReached="fetchNextPage"
      />
    </gl-modal>

    <div class="page-title-holder flex-fill d-flex align-items-center">
      <h1 class="js-dashboard-title page-title text-nowrap flex-fill">
        {{ s__('OperationsDashboard|Operations Dashboard') }}
      </h1>
      <gl-button
        v-if="projects.length"
        v-gl-modal="$options.modalId"
        variant="success"
        category="primary"
        data-testid="add-projects-button"
        data-qa-selector="add_projects_button"
      >
        {{ s__('OperationsDashboard|Add projects') }}
      </gl-button>
    </div>
    <div class="gl-mt-3">
      <vue-draggable
        v-if="projects.length"
        v-model="projects"
        group="dashboard-projects"
        class="row gl-mt-3 dashboard-cards"
      >
        <div v-for="project in projects" :key="project.id" class="col-12 col-md-6 col-xl-4 px-2">
          <dashboard-project :project="project" />
        </div>
      </vue-draggable>

      <gl-dashboard-skeleton v-else-if="isLoadingProjects" />

      <gl-empty-state
        v-else
        :title="s__(`OperationsDashboard|Add a project to the dashboard`)"
        :svg-path="emptyDashboardSvgPath"
      >
        <template #description>
          {{
            s__(
              `OperationsDashboard|The operations dashboard provides a summary of each project's operational health, including pipeline and alert statuses.`,
            )
          }}
          <gl-link :href="emptyDashboardHelpPath" data-testid="documentation-link">{{
            s__('OperationsDashboard|More information')
          }}</gl-link
          >.
        </template>
        <template #actions>
          <gl-button
            v-gl-modal="$options.modalId"
            variant="success"
            data-testid="add-projects-button"
            data-qa-selector="add_projects_button"
          >
            {{ s__('OperationsDashboard|Add projects') }}
          </gl-button>
        </template>
      </gl-empty-state>
    </div>
  </div>
</template>
