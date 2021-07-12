<script>
import { GlLink, GlTable } from '@gitlab/ui';
import { s__ } from '~/locale';

export default {
  components: {
    GlLink,
    GlTable,
  },
  inject: ['integrationDocsUrl'],
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
    <div class="gl-display-block gl-text-right gl-my-3">
      <gl-link :href="integrationDocsUrl" target="_blank">
        {{ s__('ClusterAgents|Learn more about installing the GitLab Agent') }}
      </gl-link>
    </div>

    <gl-table :items="agents" :fields="fields" stacked="md" data-testid="cluster-agent-list-table">
      <template #cell(name)="{ item }">
        <gl-link :href="item.webPath">
          {{ item.name }}
        </gl-link>
      </template>

      <template #cell(configuration)="{ item }">
        <!-- eslint-disable @gitlab/vue-require-i18n-strings -->
        <gl-link v-if="item.configFolder" :href="item.configFolder.webPath">
          .gitlab/agents/{{ item.name }}
        </gl-link>

        <p v-else>.gitlab/agents/{{ item.name }}</p>
      </template>
    </gl-table>
  </div>
</template>
