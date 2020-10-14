<script>
import { GlLoadingIcon, GlPagination } from '@gitlab/ui';
import AgentEmptyState from './agent_empty_state.vue';
import AgentTable from './agent_table.vue';
import getAgentsQuery from '../graphql/queries/get_agents.query.graphql';

export default {
  apollo: {
    agents: {
      query: getAgentsQuery,
      variables() {
        return {
          defaultBranchName: this.defaultBranchName,
          projectPath: this.projectPath,
        };
      },
      update: data => {
        const configFolders = data.project.repository.tree?.trees?.nodes;
        let list = data.project.clusterAgents.nodes;

        if (configFolders) {
          list = list.map(agent => {
            const configFolder = configFolders.find(({ name }) => name === agent.name);
            return { ...agent, configFolder };
          });
        }

        return {
          list,
          pageInfo: data.project.clusterAgents.pageInfo,
        };
      },
    },
  },
  components: {
    AgentEmptyState,
    AgentTable,
    GlLoadingIcon,
    GlPagination,
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
};
</script>

<template>
  <section v-if="agents" class="gl-mt-3">
    <AgentTable v-if="agents.list.length" :agents="agents.list" />

    <AgentEmptyState v-else :image="emptyStateImage" />

    <gl-pagination :prev-page="0" :next-page="1" prev-text="Prev" next-text="Next" align="center" />
  </section>

  <gl-loading-icon v-else size="md" class="gl-mt-3" />
</template>
