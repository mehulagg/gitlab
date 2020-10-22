<script>
import { GlAlert, GlLoadingIcon } from '@gitlab/ui';
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
        return {
          list: data?.project?.clusterAgents?.nodes,
          folders: data?.project?.repository?.tree?.trees?.nodes,
        };
      },
    },
  },
  components: {
    AgentEmptyState,
    AgentTable,
    GlAlert,
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
    isLoading() {
      return this.$apollo.queries.agents.loading;
    },
    agentList() {
      let list = this.agents?.list;
      const configFolders = this.agents?.folders;

      if (list && configFolders) {
        list = list.map(agent => {
          const configFolder = configFolders.find(({ name }) => name === agent.name);
          return { ...agent, configFolder };
        });
      }

      return list;
    },
  },
};
</script>

<template>
  <gl-loading-icon v-if="isLoading" size="md" class="gl-mt-3" />

  <section v-else-if="agentList" class="gl-mt-3">
    <AgentTable v-if="agentList.length" :agents="agentList" />

    <AgentEmptyState v-else :image="emptyStateImage" />
  </section>

  <gl-alert v-else variant="danger" :dismissible="false">
    {{ s__('ClusterAgents|An error occurred while loading your GitLab Agents') }}
  </gl-alert>
</template>
