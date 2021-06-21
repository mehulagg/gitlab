<script>
import { GlButton, GlDropdown, GlSprintf } from '@gitlab/ui';
import getUsersProjects from '~/graphql_shared/queries/get_users_projects.query.graphql';
import axios from '~/lib/utils/axios_utils';
import { s__ } from '~/locale';
import ProjectSelector from '~/vue_shared/components/project_selector/project_selector.vue';

export default {
  MINIMUM_QUERY_LENGTH: 3,
  PROJECTS_PER_PAGE: 20,
  i18n: {
    securityProject: s__(
      'SecurityOrchestration|A security policy project can be used enforce policies for a given project, group, or instance. It allows you to specify security policies that are important to you  and enforce them with every commit. %{linkStart}More information%{linkEnd}',
    ),
  },
  components: {
    GlButton,
    GlDropdown,
    GlSprintf,
    ProjectSelector,
  },
  inject: ['documentationPath', 'selectProjectPath'],
  props: {
    assignedPolicyProject: {
      type: Object,
      required: false,
      default: () => ({}),
    },
  },
  data() {
    return {
      searchQuery: this.assignedPolicyProject.name,
      projectSearchResults: [],
      selectedProjects: [this.assignedPolicyProject],
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
    isSearchingProjects() {
      return this.searchCount > 0;
    },
  },
  methods: {
    async saveChanges() {
      const { id } = this.selectedProjects[0];
      try {
        const resp = await axios.post(this.selectProjectPath, {
          orchestration: { policy_project_id: id },
        });
        const { data } = resp;
        return data;
      } catch (e) {
        return e;
      }
    },
    toggleSelectedProject(data) {
      this.selectedProjects = [data];
      this.$refs.dropdown.hide(true);
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
};
</script>

<template>
  <section>
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
      </gl-dropdown>
      <div class="gl-pb-5">
        <gl-sprintf class="text-muted" :message="$options.i18n.securityProject">
          <template #link="{ content }">
            <gl-button class="gl-pb-1!" variant="link" :href="documentationPath" target="_blank">
              {{ content }}
            </gl-button>
          </template>
        </gl-sprintf>
      </div>
      <gl-button class="gl-display-block" variant="success" @click="saveChanges">
        {{ __('Save changes') }}
      </gl-button>
    </div>
  </section>
</template>
