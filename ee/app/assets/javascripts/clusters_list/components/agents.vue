<script>
import { GlAlert, GlKeysetPagination, GlLoadingIcon } from '@gitlab/ui';
import AgentEmptyState from './agent_empty_state.vue';
import AgentTable from './agent_table.vue';
import getAgentsQuery from '../graphql/queries/get_agents.query.graphql';
import { MAX_LIST_COUNT } from '../constants';

export default {
  apollo: {
    agents: {
      query: getAgentsQuery,
      variables() {
        return {
          defaultBranchName: this.defaultBranchName,
          projectPath: this.projectPath,
          first: MAX_LIST_COUNT,
          last: null,
        };
      },
      update: (data) => data,
    },
  },
  components: {
    AgentEmptyState,
    AgentTable,
    GlAlert,
    GlKeysetPagination,
    GlLoadingIcon,
  },
  props: {
    emptyStateImage: {
      required: true,
      type: String,
    },
    defaultBranchName: {
      default: '.noBranch',
      required: false,
      type: String,
    },
    projectPath: {
      required: true,
      type: String,
    },
  },
  computed: {
    agentList() {
      let list = this.agents?.project?.clusterAgents?.nodes;
      const configFolders = this.agents?.project?.repository?.tree?.trees?.nodes;

      if (list && configFolders) {
        list = list.map((agent) => {
          const configFolder = configFolders.find(({ name }) => name === agent.name);
          return { ...agent, configFolder };
        });
      }

      return list;
    },
    agentPageInfo() {
      return this.agents?.project?.clusterAgents?.pageInfo || {};
    },
    branchPageInfo() {
      return this.agents?.project?.repository?.tree?.trees?.pageInfo || {};
    },
    isLoading() {
      return this.$apollo.queries.agents.loading;
    },
    showPagination() {
      return this.agentPageInfo.hasPreviousPage || this.agentPageInfo.hasNextPage;
    },
  },
  methods: {
    nextPage() {
      this.fetchMoreAgents({
        first: MAX_LIST_COUNT,
        last: null,
        afterAgent: this.agentPageInfo.endCursor,
        afterTree: this.branchPageInfo.endCursor,
      });
    },
    prevPage() {
      this.fetchMoreAgents({
        first: null,
        last: MAX_LIST_COUNT,
        beforeAgent: this.agentPageInfo.startCursor,
        beforeTree: this.branchPageInfo.startCursor,
      });
    },
    fetchMoreAgents(queryVariables) {
      this.$apollo.queries.agents
        .fetchMore({
          variables: {
            defaultBranchName: this.defaultBranchName,
            projectPath: this.projectPath,
            ...queryVariables,
          },
          updateQuery: (previousResult, { fetchMoreResult }) => {
            // eslint-disable-next-line no-param-reassign
            fetchMoreResult.project.repository.tree.trees.nodes = [
              ...previousResult.project.repository.tree.trees.nodes,
              ...fetchMoreResult.project.repository.tree.trees.nodes,
            ];

            return fetchMoreResult;
          },
        })
        .catch(() => {
          this.agents = null;
        });
    },
  },
};
</script>

<template>
  <gl-loading-icon v-if="isLoading" size="md" class="gl-mt-3" />

  <section v-else-if="agentList" class="gl-mt-3">
    <div v-if="agentList.length">
      <AgentTable :agents="agentList" />

      <div v-if="showPagination" class="gl-display-flex gl-justify-content-center gl-mt-5">
        <gl-keyset-pagination v-bind="agentPageInfo" @prev="prevPage" @next="nextPage" />
      </div>
    </div>

    <AgentEmptyState v-else :image="emptyStateImage" />
  </section>

  <gl-alert v-else variant="danger" :dismissible="false">
    {{ s__('ClusterAgents|An error occurred while loading your GitLab Agents') }}
  </gl-alert>
</template>
