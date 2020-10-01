<script>
import { GlAlert, GlLoadingIcon } from '@gitlab/ui';
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
      update(data) {
        try {
          this.finishLoading();
          this.dismissError();

          let agentList = data.project.clusterAgents.nodes;
          const configFolders = data.project.repository.tree?.trees?.nodes;

          if (configFolders) {
            agentList = agentList.map(agent => {
              const configFolder = configFolders.find(({ name }) => name === agent.name);
              return { ...agent, configFolder };
            });
          }

          return sortBy(agentList, 'name');
        } catch {
          this.addError();
          return null;
        }
      },
      error() {
        this.addError();
        return null;
      },
    },
  },
  components: {
    GlAlert,
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
  data() {
    return {
      errored: false,
      loading: true,
    };
  },
  methods: {
    finishLoading() {
      this.loading = false;
    },
    addError() {
      this.errored = true;
    },
    dismissError() {
      this.errored = false;
    },
  },
};
</script>

<template>
  <gl-alert v-if="errored" variant="danger" @dismiss="dismissError">
    {{ s__('ClusterAgents|An error occurred while loading your GitLab Agents') }}
  </gl-alert>

  <gl-loading-icon v-else-if="loading" size="md" class="gl-mt-3" />

  <section v-else-if="agents" class="gl-mt-3">
    <AgentTable v-if="agents.length" :agents="agents" />

    <AgentEmptyState v-else :image="emptyStateImage" />
  </section>
</template>
