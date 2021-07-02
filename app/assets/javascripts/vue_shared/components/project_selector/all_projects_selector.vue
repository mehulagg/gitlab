<script>
import getUsersProjects from '~/graphql_shared/queries/get_users_projects.query.graphql';
import ProjectSelector from './project_selector.vue';

export default {
  MINIMUM_QUERY_LENGTH: 3,
  PROJECTS_PER_PAGE: 20,
  components: {
    ProjectSelector,
  },
  props: {
    selectedProjects: {
      type: Array,
      required: false,
      default: () => [],
    },
    maxListHeight: {
      type: Number,
      required: false,
      default: 402,
    },
    projectQuery: {
      type: Object,
      required: false,
      default: () => getUsersProjects,
    },
  },
  data() {
    return {
      projectSearchResults: [],
      searchQuery: '',
      minimumQuery: false,
      noResults: false,
      searchError: false,
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
    cancelSearch() {
      this.projectSearchResults = [];
      this.pageInfo = {
        endCursor: '',
        hasNextPage: true,
      };
      this.updateMessagesData(false, false, true);
      this.searchCount = Math.max(0, this.searchCount - 1);
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
    searched(query) {
      this.searchQuery = query;
      this.pageInfo = { endCursor: '', hasNextPage: true };
      this.minimumQuery = false;
      this.searchCount += 1;
      this.fetchSearchResults(true);
    },
    searchProjects(searchQuery, pageInfo) {
      return this.$apollo.query({
        query: this.projectQuery,
        variables: {
          search: searchQuery,
          first: this.$options.PROJECTS_PER_PAGE,
          after: pageInfo.endCursor,
          searchNamespaces: true,
          sort: 'similarity',
        },
      });
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
  <project-selector
    class="gl-w-full"
    :max-list-height="maxListHeight"
    :project-search-results="projectSearchResults"
    :selected-projects="selectedProjects"
    :show-no-results-message="noResults"
    :show-loading-indicator="isSearchingProjects"
    :show-minimum-search-query-message="minimumQuery"
    :show-search-error-message="searchError"
    @searched="searched"
    @projectClicked="(selectedProject) => $emit('projectClicked', selectedProject)"
    @bottomReached="fetchSearchResults"
  />
</template>
