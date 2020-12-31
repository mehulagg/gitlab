<script>
import { GlAlert, GlKeysetPagination, GlLoadingIcon } from '@gitlab/ui';
import produce from 'immer';
import AgentEmptyState from './agent_empty_state.vue';
import AgentTable from './agent_table.vue';
import getAgentsQuery from '../graphql/queries/get_agents.query.graphql';

const MAX_LIST_COUNT = 3;

export default {
  apollo: {
    agents: {
      query: getAgentsQuery,
      variables() {
        return {
          defaultBranchName: this.defaultBranchName,
          projectPath: this.projectPath,
          first: MAX_LIST_COUNT,
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
    isLoading() {
      return this.$apollo.queries.agents.loading;
    },
    showPagination() {
      return this.agentPageInfo.hasPreviousPage || this.agentPageInfo.hasNextPage;
    },
  },
  methods: {
    nextPage() {
      this.$apollo.queries.agents
        .fetchMore({
          variables: {
            defaultBranchName: this.defaultBranchName,
            projectPath: this.projectPath,
            first: MAX_LIST_COUNT,
            afterAgent: this.agentPageInfo.endCursor,
          },
          updateQuery: (previousResult, { fetchMoreResult }) => {
            return produce(fetchMoreResult, (newAgents) => {
              // eslint-disable-next-line no-param-reassign
              newAgents.project.repository.tree.trees.nodes = [
                ...previousResult.project.repository.tree.trees.nodes,
                ...newAgents.project.repository.tree.trees.nodes,
              ];
            });
          },
        })
        .catch(() => {
          this.agents = null;
        });
    },
    prevPage() {
      /*
      this.cursor = {
        first: null,
        after: null,
        last: MAX_LIST_COUNT,
        before: item,
      };
      */
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
