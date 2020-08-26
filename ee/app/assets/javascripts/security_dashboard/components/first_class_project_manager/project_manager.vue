<script>
import { GlButton } from '@gitlab/ui';
import getProjects from 'ee/security_dashboard/graphql/get_projects.query.graphql';
import projectsQuery from 'ee/security_dashboard/graphql/get_instance_security_dashboard_projects.query.graphql';
import addProjectToSecurityDashboard from 'ee/security_dashboard/graphql/add_project_to_security_dashboard.mutation.graphql';
import deleteProjectFromSecurityDashboard from 'ee/security_dashboard/graphql/delete_project_from_security_dashboard.mutation.graphql';
import { createInvalidProjectMessage } from 'ee/security_dashboard/utils/first_class_project_manager_utils';
import ProjectList from './project_list.vue';
import ProjectSelector from '~/vue_shared/components/project_selector/project_selector.vue';
import { __, s__, sprintf } from '~/locale';
import { deprecatedCreateFlash as createFlash } from '~/flash';

export default {
  MINIMUM_QUERY_LENGTH: 3,
  PROJECTS_PER_PAGE: 20,
  components: {
    GlButton,
    ProjectList,
    ProjectSelector,
  },
  props: {
    isManipulatingProjects: {
      type: Boolean,
      required: false,
      default: false,
    },
    projects: {
      type: Array,
      required: true,
    },
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
  computed: {
    canAddProjects() {
      return !this.isManipulatingProjects && this.selectedProjects.length > 0;
    },
    isSearchingProjects() {
      return this.searchCount > 0;
    },
  },
  methods: {
    toggleSelectedProject(project) {
      const isProjectSelected = this.selectedProjects.some(({ id }) => id === project.id);

      if (isProjectSelected) {
        this.selectedProjects = this.selectedProjects.filter(p => p.id !== project.id);
      } else {
        this.selectedProjects.push(project);
      }
    },
    addProjects() {
      this.$emit('handleProjectManipulation', true);

      const addProjectsPromises = this.selectedProjects.map(project => {
        return this.$apollo
          .mutate({
            mutation: addProjectToSecurityDashboard,
            variables: { id: project.id },
            update(store, { data: results }) {
              const data = store.readQuery({ query: projectsQuery });
              const newProject = results.addProjectToSecurityDashboard.project;
              data.instanceSecurityDashboard.projects.nodes.push({
                ...newProject,
                vulnerabilitySeveritiesCount: newProject.vulnerabilitySeveritiesCount || null, // This is required to surpress missing field warning in GraphQL.
              });
              store.writeQuery({ query: projectsQuery, data });
            },
          })
          .catch(() => {
            return { error: true, project };
          });
      });

      return Promise.all(addProjectsPromises)
        .then(response => {
          const invalidProjects = response.filter(value => value.error).map(value => value.project);
          this.$emit('handleProjectManipulation', false);

          if (invalidProjects.length) {
            const invalidProjectsMessage = createInvalidProjectMessage(invalidProjects);
            createFlash(
              sprintf(s__('SecurityReports|Unable to add %{invalidProjectsMessage}'), {
                invalidProjectsMessage,
              }),
            );
          }
        })
        .finally(() => {
          this.projectSearchResults = [];
          this.selectedProjects = [];
        });
    },
    removeProject(project) {
      const { id } = project;
      this.$emit('handleProjectManipulation', true);

      this.$apollo
        .mutate({
          mutation: deleteProjectFromSecurityDashboard,
          variables: { id },
          update(store) {
            const data = store.readQuery({
              query: projectsQuery,
            });
            data.instanceSecurityDashboard.projects.nodes = data.instanceSecurityDashboard.projects.nodes.filter(
              curr => curr.id !== id,
            );
            store.writeQuery({ query: projectsQuery, data });
          },
        })
        .then(() => {
          this.$emit('handleProjectManipulation', false);
        })
        .catch(() => createFlash(__('Something went wrong, unable to delete project')));
    },
    searched(query) {
      this.searchQuery = query;
      this.pageInfo = { endCursor: '', hasNextPage: true };
      this.messages.minimumQuery = false;
      this.searchCount += 1;
      this.fetchSearchResults(true);
    },
    fetchSearchResults(isFirstSearch) {
      if (!this.pageInfo.hasNextPage) {
        return Promise.resolve();
      }

      if (!this.searchQuery || this.searchQuery.length < this.$options.MINIMUM_QUERY_LENGTH) {
        return this.cancelSearch();
      }

      return this.searchProjects(this.searchQuery, this.pageInfo)
        .then(payload => {
          const {
            data: {
              projects: { nodes, pageInfo },
            },
          } = payload;

          if (isFirstSearch) {
            this.projectSearchResults = nodes;
            this.updateMessagesData(this.projectSearchResults.length === 0, false, false);
            this.searchCount = Math.max(0, this.searchCount - 1);
          } else {
            this.projectSearchResults = this.projectSearchResults.concat(nodes);
          }
          this.pageInfo = pageInfo;
        })
        .catch(this.fetchSearchResultsError);
    },
    cancelSearch() {
      this.projectSearchResults = [];
      this.pageInfo = {
        endCursor: '',
        hasNextPage: true,
      };
      this.updateMessagesData(false, false, true);
      this.searchCount = Math.max(0, this.searchCount - 1);
    },
    searchProjects(searchQuery, pageInfo) {
      return this.$apollo.query({
        query: getProjects,
        variables: {
          search: searchQuery,
          first: this.$options.PROJECTS_PER_PAGE,
          after: pageInfo.endCursor,
        },
      });
    },
    fetchSearchResultsError() {
      this.projectSearchResults = [];
      this.updateMessagesData(false, true, false);
      this.searchCount = Math.max(0, this.searchCount - 1);
    },
    updateMessagesData(noResults, searchError, minimumQuery) {
      this.messages = {
        noResults,
        searchError,
        minimumQuery,
      };
    },
  },

  emits: ['handleProjectManipulation'],
};
</script>

<template>
  <section class="container">
    <div class="row justify-content-center mt-md-4">
      <div class="col col-lg-7">
        <h3 class="text-3 font-weight-bold border-bottom mb-4 pb-3">
          {{ s__('SecurityReports|Add or remove projects from your dashboard') }}
        </h3>
        <div class="d-flex flex-column flex-md-row">
          <project-selector
            class="flex-grow mr-md-2"
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
          <div class="mb-3">
            <gl-button
              :disabled="!canAddProjects"
              variant="success"
              category="primary"
              @click="addProjects"
            >
              {{ s__('SecurityReports|Add projects') }}
            </gl-button>
          </div>
        </div>
      </div>
    </div>
    <div class="row justify-content-center mt-md-3">
      <project-list
        :projects="projects"
        :show-loading-indicator="isManipulatingProjects"
        class="col col-lg-7"
        @projectRemoved="removeProject"
      />
    </div>
  </section>
</template>
