<script>
import _ from 'lodash-es';
import { mapState, mapActions } from 'vuex';
import {
  GlLoadingIcon,
  GlModal,
  GlModalDirective,
  GlButton,
  GlDashboardSkeleton,
} from '@gitlab/ui';
import ProjectSelector from '~/vue_shared/components/project_selector/project_selector.vue';
import DashboardProject from './project.vue';

export default {
  components: {
    DashboardProject,
    GlModal,
    GlDashboardSkeleton,
    GlLoadingIcon,
    GlButton,
    ProjectSelector,
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
      'projects',
      'projectTokens',
      'isLoadingProjects',
      'selectedProjects',
      'projectSearchResults',
      'searchCount',
      'searchQuery',
      'messages',
    ]),
    isSearchingProjects() {
      return this.searchCount > 0;
    },
    okDisabled() {
      return _.isEmpty(this.selectedProjects);
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
      'fetchSearchResults',
      'addProjectsToDashboard',
      'fetchProjects',
      'setProjectEndpoints',
      'clearSearchResults',
      'toggleSelectedProject',
      'setSearchQuery',
    ]),
    addProjects() {
      this.addProjectsToDashboard();
    },
    onCancel() {
      this.clearSearchResults();
    },
    onOk() {
      this.addProjectsToDashboard()
        .then(this.clearSearchResults)
        .catch(this.clearSearchResults);
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
        @searched="searched"
        @projectClicked="projectClicked"
      />
    </gl-modal>

    <div class="page-title-holder flex-fill d-flex align-items-center">
      <h1 class="js-dashboard-title page-title text-nowrap flex-fill">
        {{ s__('OperationsDashboard|Operations Dashboard') }}
      </h1>
      <gl-button
        v-if="projects.length"
        v-gl-modal="$options.modalId"
        class="js-add-projects-button btn btn-success"
      >
        {{ s__('OperationsDashboard|Add projects') }}
      </gl-button>
    </div>
    <div class="prepend-top-default">
      <div v-if="projects.length" class="row prepend-top-default dashboard-cards">
        <div v-for="project in projects" :key="project.id" class="col-12 col-md-6 col-xl-4 px-2">
          <dashboard-project :project="project" />
        </div>
      </div>
      <div v-else-if="!isLoadingProjects" class="row prepend-top-20 text-center">
        <div class="col-12 d-flex justify-content-center svg-content">
          <img :src="emptyDashboardSvgPath" class="js-empty-state-svg col-12 prepend-top-20" />
        </div>
        <h4 class="js-title col-12 prepend-top-20">
          {{ s__('OperationsDashboard|Add a project to the dashboard') }}
        </h4>
        <div class="col-12 d-flex justify-content-center">
          <span class="js-sub-title mw-460 text-tertiary text-left">
            {{
              s__(`OperationsDashboard|The operations dashboard provides a summary of each project's
              operational health, including pipeline and alert statuses.`)
            }}
            <a :href="emptyDashboardHelpPath" class="js-documentation-link">
              {{ s__('OperationsDashboard|More information') }}
            </a>
          </span>
        </div>
        <div class="col-12">
          <gl-button
            v-gl-modal="$options.modalId"
            class="js-add-projects-button btn btn-success prepend-top-default append-bottom-default"
          >
            {{ s__('OperationsDashboard|Add projects') }}
          </gl-button>
        </div>
      </div>
      <gl-dashboard-skeleton v-else />
    </div>
  </div>
</template>
