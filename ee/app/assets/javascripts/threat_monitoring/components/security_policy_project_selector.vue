<script>
import { GlAlert, GlButton, GlDropdown, GlSprintf } from '@gitlab/ui';
import getUsersProjects from '~/graphql_shared/queries/get_users_projects.query.graphql';
import { s__ } from '~/locale';
import ProjectSelector from '~/vue_shared/components/project_selector/project_selector.vue';
import assignSecurityPolicyProject from '../graphql/mutations/assign_security_policy_project.mutation.graphql';

export default {
  PROJECT_SELECTOR_HEIGHT: 204,
  MINIMUM_QUERY_LENGTH: 3,
  PROJECTS_PER_PAGE: 20,
  i18n: {
    assignError: s__(
      'SecurityOrchestration|An error has occured when assigning your security policy project',
    ),
    assignSuccess: s__('SecurityOrchestration|A security policy project was successfully linked'),
    securityProject: s__(
      'SecurityOrchestration|A security policy project can be used enforce policies for a given project, group, or instance. It allows you to specify security policies that are important to you  and enforce them with every commit. %{linkStart}More information%{linkEnd}',
    ),
  },
  components: {
    GlAlert,
    GlButton,
    GlDropdown,
    GlSprintf,
    ProjectSelector,
  },
  inject: ['documentationPath', 'projectPath', 'selectProjectPath'],
  props: {
    assignedPolicyProject: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  data() {
    return {
      currentProjectId: this.assignedPolicyProject.id,
      searchQuery: '',
      projectSearchResults: [],
      selectedProjects: [this.assignedPolicyProject],
      isAssigningProject: false,
      assignError: false,
      minimumQuery: false,
      noResults: false,
      searchError: false,
      showAssignSuccess: false,
      searchCount: 0,
      pageInfo: {
        endCursor: '',
        hasNextPage: true,
      },
    };
  },
  computed: {
    isNewProject() {
      return this.currentProjectId !== this.selectedProjects[0].id;
    },
    isSearchingProjects() {
      return this.searchCount > 0;
    },
  },
  methods: {
    cancelSearch() {
      this.projectSearchResults = [];
      this.pageInfo = {
        endCursor: '',
        hasNextPage: true,
      };
      this.updateMessagesData(false, false, true);
      this.searchCount = Math.max(0, this.searchCount - 1);
    },
    dismissAlert(type) {
      this[type] = false;
    },
    fetchSearchResults(isFirstSearch) {
      if (!this.pageInfo.hasNextPage) {
        return Promise.resolve();
      }

      if (!this.searchQuery || this.searchQuery.length < this.$options.MINIMUM_QUERY_LENGTH) {
        return this.cancelSearch();
      }

      return this.searchProjects(this.searchQuery, this.pageInfo)
        .then((payload) => {
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
    fetchSearchResultsError() {
      this.projectSearchResults = [];
      this.updateMessagesData(false, true, false);
      this.searchCount = Math.max(0, this.searchCount - 1);
    },
    async saveChanges() {
      this.isAssigningProject = true;
      const { id } = this.selectedProjects[0];
      try {
        const { data } = await this.$apollo.mutate({
          mutation: assignSecurityPolicyProject,
          variables: {
            projectPath: this.projectPath,
            securityPolicyProjectId: id,
          },
        });
        if (data.securityPolicyProjectAssign.errors.length) {
          this.assignError = true;
        } else {
          this.showAssignSuccess = true;
          this.currentProjectId = id;
        }
      } catch (e) {
        this.assignError = true;
      } finally {
        this.isAssigningProject = false;
      }
    },
    searched(query) {
      this.searchQuery = query;
      this.pageInfo = { endCursor: '', hasNextPage: true };
      this.minimumQuery = false;
      this.searchCount += 1;
      this.fetchSearchResults(true);
    },
    searchProjects(searchQuery, pageInfo) {
      return this.$apollo.query({
        query: getUsersProjects,
        variables: {
          search: searchQuery,
          first: this.$options.PROJECTS_PER_PAGE,
          after: pageInfo.endCursor,
          searchNamespaces: true,
          sort: 'similarity',
        },
      });
    },
    toggleSelectedProject(data) {
      this.selectedProjects = [data];
      this.$refs.dropdown.hide(true);
    },
    updateMessagesData(noResults, searchError, minimumQuery) {
      this.minimumQuery = minimumQuery;
      this.noResults = noResults;
      this.searchError = searchError;
    },
  },
};
</script>

<template>
  <section>
    <gl-alert
      v-if="assignError"
      class="gl-mt-3"
      variant="danger"
      :dismissible="true"
      @dismiss="dismissAlert('assignError')"
    >
      {{ $options.i18n.assignError }}
    </gl-alert>
    <gl-alert
      v-else-if="showAssignSuccess"
      class="gl-mt-3"
      variant="success"
      :dismissible="true"
      @dismiss="dismissAlert('showAssignSuccess')"
    >
      {{ $options.i18n.assignSuccess }}
    </gl-alert>
    <h2 class="gl-mb-8">
      {{ s__('SecurityOrchestration|Create a policy') }}
    </h2>
    <div class="gl-w-half">
      <h4>
        {{ s__('SecurityOrchestration|Security policy project') }}
      </h4>
      <gl-dropdown
        ref="dropdown"
        class="gl-w-full gl-pb-5 security-policy-dropdown"
        :text="selectedProjects[0].name"
      >
        <project-selector
          class="gl-w-full"
          :max-list-height="$options.PROJECT_SELECTOR_HEIGHT"
          :project-search-results="projectSearchResults"
          :selected-projects="selectedProjects"
          :show-no-results-message="noResults"
          :show-loading-indicator="isSearchingProjects"
          :show-minimum-search-query-message="minimumQuery"
          :show-search-error-message="searchError"
          @searched="searched"
          @projectClicked="toggleSelectedProject"
          @bottomReached="fetchSearchResults"
        />
      </gl-dropdown>
      <div class="gl-pb-5">
        <gl-sprintf :message="$options.i18n.securityProject">
          <template #link="{ content }">
            <gl-button class="gl-pb-1!" variant="link" :href="documentationPath" target="_blank">
              {{ content }}
            </gl-button>
          </template>
        </gl-sprintf>
      </div>
      <gl-button
        class="gl-display-block"
        variant="success"
        :disabled="!isNewProject"
        :loading="isAssigningProject"
        @click="saveChanges"
      >
        {{ __('Save changes') }}
      </gl-button>
    </div>
  </section>
</template>
