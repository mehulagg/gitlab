<script>
import IntegrationsTable from './integrations_table.vue';

export default {
  name: 'IntegrationsList',
  components: {
    IntegrationsTable,
  },
  props: {
    integrations: {
      type: Array,
      required: true,
    },
  },
  computed: {
    activeIntegrations() {
      return this.integrations.filter((integration) => integration.active);
    },
    inactiveIntegrations() {
      return this.integrations.filter((integration) => !integration.active);
    },
  },
};
</script>

<template>
  <div>
    <integrations-table :active="true" :integrations="activeIntegrations" />
    <h5>{{ s__('Integrations|Add an integration') }}</h5>
    <integrations-table :active="false" :integrations="inactiveIntegrations" />
  </div>
</template>
