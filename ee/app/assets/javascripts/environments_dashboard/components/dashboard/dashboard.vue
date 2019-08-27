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
import { s__ } from '~/locale';
import ProjectSelector from '~/vue_shared/components/project_selector/project_selector.vue';
import ProjectHeader from './project_header.vue';
import Environment from './environment.vue';

export default {
  addProjectsModalHeader: s__('EnvironmentsDashboard|Add projects'),
  addProjectsModalSubmit: s__('EnvironmentsDashboard|Add projects'),

  dashboardHeader: s__('EnvironmentsDashboard|Environments Dashboard'),

  addProjectsButton: s__('EnvironmentsDashboard|Add projects'),

  emptyDashboardHeader: s__('EnvironmentsDashboard|Add a project to the dashboard'),

  emptyDashboardDocs: s__(
    "EnvironmentsDashboard|The environments dashboard provides a summary of each project's environments' status, including pipeline and alert statuses.",
  ),

  viewDocumentationButton: s__('View documentation'),

  components: {
    GlModal,
    GlDashboardSkeleton,
    GlLoadingIcon,
    GlButton,
    ProjectSelector,
    Environment,
    ProjectHeader,
  },
  directives: {
    'gl-modal': GlModalDirective,
  },
  modalId: 'add-projects-modal',
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
      'removeProject',
    ]),
    addProjects() {
      this.addProjectsToDashboard();
    },
    onModalHidden() {
      this.clearSearchResults();
    },
    onOk() {
      this.addProjectsToDashboard();
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
      :title="$options.addProjectsModalHeader"
      :ok-title="$options.addProjectsModalSubmit"
      :ok-disabled="okDisabled"
      ok-variant="success"
      @hidden="onModalHidden"
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
        {{ $options.dashboardHeader }}
      </h1>
      <gl-button v-gl-modal="$options.modalId" class="js-add-projects-button btn btn-success">
        {{ $options.addProjectsButton }}
      </gl-button>
    </div>
    <div class="prepend-top-default">
      <div v-if="projects.length" class="dashboard-cards">
        <div v-for="project in projects" :key="project.id" class="column prepend-top-default">
          <project-header :project="project" @remove="removeProject" />
          <div class="row">
            <environment
              v-for="environment in project.environments"
              :key="environment.id"
              :environment="environment"
              class="col-12 col-md-6 col-xl-4 px-2 prepend-top-default"
            />
          </div>
        </div>
      </div>
      <div v-else-if="!isLoadingProjects" class="row prepend-top-20 text-center">
        <div class="col-12 d-flex justify-content-center svg-content">
          <img :src="emptyDashboardSvgPath" class="js-empty-state-svg col-12 prepend-top-20" />
        </div>
        <h4 class="js-title col-12 prepend-top-20">
          {{ $options.emptyDashboardHeader }}
        </h4>
        <div class="col-12 d-flex justify-content-center">
          <span class="js-sub-title mw-460 text-tertiary text-left">
            {{ $options.emptyDashboardDocs }}
          </span>
        </div>
        <div class="col-12">
          <a
            :href="emptyDashboardHelpPath"
            class="js-documentation-link btn btn-primary prepend-top-default append-bottom-default"
          >
            {{ $options.viewDocumentationButton }}
          </a>
        </div>
      </div>
      <gl-dashboard-skeleton v-else />
    </div>
  </div>
</template>
