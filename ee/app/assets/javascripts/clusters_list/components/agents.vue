<script>
import { GlLoadingIcon } from '@gitlab/ui';
import AgentEmptyState from './agent_empty_state.vue';
import AgentTable from './agent_table.vue';
import getAgents from '../graphql/queries/get_agents.query.graphql';

export default {
  apollo: {
    agents: {
      query: getAgents,
      variables() {
        return {
          defaultBranchName: this.defaultBranchName || '.noBranch',
          projectPath: this.projectPath,
        };
      },
      update: data => {
        let agentList = data.project.clusterAgents.nodes;
        const configFolders = data.project.repository.tree?.trees?.nodes;

        if (configFolders) {
          agentList = agentList.map(agent => {
            const item = { ...agent };
            item.configFolder = configFolders.find(folder => folder.name === agent.name);
            return item;
          });
        }

        return agentList.sort((a, b) => (a.name > b.name ? 1 : -1));
      },
    },
  },
  inject: {
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
  components: {
    AgentEmptyState,
    AgentTable,
    GlLoadingIcon,
  },
};
</script>

<template>
  <section v-if="agents" class="gl-mt-3">
    <AgentTable v-if="agents.length" :agents="agents" />

    <AgentEmptyState v-else :image="emptyStateImage" />
  </section>

  <gl-loading-icon v-else size="md" class="gl-mt-3" />
</template>
