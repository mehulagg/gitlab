<script>
import { GlDropdown, GlDropdownItem } from '@gitlab/ui';
import { I18N_AVAILABLE_AGENTS_DROPDOWN } from '../constants';
import agentConfigurations from '../graphql/queries/agent_configurations.query.graphql';

export default {
  name: 'AvailableAgentsDropdown',
  i18n: I18N_AVAILABLE_AGENTS_DROPDOWN,
  apollo: {
    agents: {
      query: agentConfigurations,
      variables() {
        return {
          projectPath: this.projectPath,
        };
      },
      update(data) {
        this.populateConfiguredAgents(data);
        this.loading = false;
      },
    },
  },
  components: {
    GlDropdown,
    GlDropdownItem,
  },
  props: {
    projectPath: {
      required: true,
      type: String,
    },
    registeringAgent: {
      required: true,
      type: Boolean,
    },
  },
  data() {
    return {
      loading: true,
      configuredAgents: [],
      selectedAgent: null,
    };
  },
  computed: {
    dropdownText() {
      if (this.selectedAgent === null) {
        return this.$options.i18n.selectAgent;
      } else if (this.registeringAgent) {
        return this.$options.i18n.registeringAgent;
      } else {
        return this.selectedAgent;
      }
    },
  },
  methods: {
    selectAgent(agent) {
      this.$emit('agentSelected', agent);
      this.selectedAgent = agent;
    },
    isSelected(agent) {
      return this.selectedAgent === agent;
    },
    populateConfiguredAgents(data) {
      const configurations = data?.project?.agentConfigurations?.nodes;

      this.configuredAgents = configurations.map((config) => config.agentName);
    },
  },
};
</script>
<template>
  <gl-dropdown :text="dropdownText" :loading="loading || registeringAgent">
    <gl-dropdown-item
      v-for="agent in configuredAgents"
      :key="agent"
      :is-checked="isSelected(agent)"
      is-check-item
      @click="selectAgent(agent)"
    >
      {{ agent }}
    </gl-dropdown-item>
  </gl-dropdown>
</template>
