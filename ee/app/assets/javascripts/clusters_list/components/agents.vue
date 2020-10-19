<script>
import { GlLoadingIcon } from '@gitlab/ui';
import { sortBy } from 'lodash';
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
        let agentList = data.project.clusterAgents.nodes;
        const configFolders = data.project.repository.tree?.trees?.nodes;

        if (configFolders) {
          agentList = agentList.map(agent => {
            const configFolder = configFolders.find(({ name }) => name === agent.name);
            return { ...agent, configFolder };
          });
        }

        return sortBy(agentList, 'name');
      },
    },
  },
  components: {
    AgentEmptyState,
    AgentTable,
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
};
</script>

<template>
  <section v-if="agents" class="gl-mt-3">
    <AgentTable v-if="agents.length" :agents="agents" />

    <AgentEmptyState v-else :image="emptyStateImage" />
  </section>

  <gl-loading-icon v-else size="md" class="gl-mt-3" />
</template>
