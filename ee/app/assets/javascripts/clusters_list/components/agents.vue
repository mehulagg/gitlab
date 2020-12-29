<script>
import { GlAlert, GlKeysetPagination, GlLoadingIcon } from '@gitlab/ui';
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
          ...this.cursor,
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
  data() {
    return {
      cursor: {
        first: MAX_LIST_COUNT,
        after: null,
        last: null,
        before: null,
      },
    };
  },
  computed: {
    agentList() {
      let list = this.agents?.project?.clusterAgents?.nodes;
      const configFolders = this.agents?.data?.project?.repository?.tree?.trees?.nodes;

      if (list && configFolders) {
        list = list.map((agent) => {
          const configFolder = configFolders.find(({ name }) => name === agent.name);
          return { ...agent, configFolder };
        });
      }

      return list;
    },
    isLoading() {
      return this.$apollo.queries.agents.loading;
    },
    pageInfo() {
      return this.agents?.project?.clusterAgents?.pageInfo || {};
    },
    showPagination() {
      return this.pageInfo.hasPreviousPage || this.pageInfo.hasNextPage;
    },
  },
  methods: {
    nextPage(item) {
      this.cursor = {
        first: MAX_LIST_COUNT,
        after: item,
        last: null,
        before: null,
      };
    },
    prevPage(item) {
      this.cursor = {
        first: null,
        after: null,
        last: MAX_LIST_COUNT,
        before: item,
      };
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
        <gl-keyset-pagination v-bind="pageInfo" @prev="prevPage" @next="nextPage" />
      </div>
    </div>

    <AgentEmptyState v-else :image="emptyStateImage" />
  </section>

  <gl-alert v-else variant="danger" :dismissible="false">
    {{ s__('ClusterAgents|An error occurred while loading your GitLab Agents') }}
  </gl-alert>
</template>
