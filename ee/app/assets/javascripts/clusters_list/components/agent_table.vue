<script>
import { GlButton, GlLink, GlTable } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  components: {
    GlButton,
    GlLink,
    GlTable,
  },
  props: {
    agents: {
      required: true,
      type: Array,
    },
  },
  computed: {
    fields() {
      return [
        {
          key: 'name',
          label: s__('ClusterAgents|Name'),
        },
        {
          key: 'configuration',
          label: s__('ClusterAgents|Configuration'),
        },
      ];
    },
  },
};
</script>

<template>
  <div>
    <div class="gl-display-block gl-text-right gl-my-4">
      <gl-button
        category="primary"
        href="https://docs.gitlab.com/ee/user/clusters/agent/#installing-the-agent-server-via-helm"
        target="_blank"
        variant="success"
      >
        {{ s__('ClusterAgents|Connect your cluster with the GitLab Agent') }}
      </gl-button>
    </div>

    <gl-table
      :items="agents"
      :fields="fields"
      stacked="md"
      data-qa-selector="cluster_agent_list_table"
    >
      <template #cell(configuration)=" { item }">
        <gl-link v-if="item.configFolder" :href="item.configFolder.webPath">
          {{ item.configFolder.path }}
        </gl-link>

        <p v-else>
          <!-- eslint-disable @gitlab/vue-require-i18n-strings -->
          {{ `.gitlab/agents/${item.name}` }}
        </p>
      </template>
    </gl-table>
  </div>
</template>
