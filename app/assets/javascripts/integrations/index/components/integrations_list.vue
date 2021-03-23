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
      // TODO filter
      return this.integrations;
    },
  },
};
</script>

<template>
  <div>
    <integrations-table :integrations="activeIntegrations" />
    <div>{{ integrations }}</div>
  </div>
</template>
