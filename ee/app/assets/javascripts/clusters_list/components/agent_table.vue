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
        href="https://docs.gitlab.com/ee/user/clusters/agent/#get-started-with-gitops-and-the-gitlab-agent"
        target="_blank"
        variant="success"
      >
        {{ s__('ClusterAgents|Connect your cluster with the GitLab Agent') }}
      </gl-button>
    </div>

    <gl-table :items="agents" :fields="fields" stacked="md" data-testid="cluster-agent-list-table">
      <template #cell(configuration)=" { item }">
        <!-- eslint-disable @gitlab/vue-require-i18n-strings -->
        <gl-link v-if="item.configFolder" :href="item.configFolder.webPath">
          .gitlab/agents/{{ item.name }}
        </gl-link>

        <p v-else>.gitlab/agents/{{ item.name }}</p>
      </template>
    </gl-table>
  </div>
</template>
