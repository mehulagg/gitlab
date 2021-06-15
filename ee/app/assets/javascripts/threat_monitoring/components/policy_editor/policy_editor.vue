<script>
import { GlFormGroup, GlFormSelect } from '@gitlab/ui';
import { mapActions } from 'vuex';
import EnvironmentPicker from '../environment_picker.vue';
import { POLICY_TYPES } from './constants';
import NetworkPolicyEditor from './network_policy/network_policy_editor.vue';

export default {
  components: {
    GlFormGroup,
    GlFormSelect,
    EnvironmentPicker,
    NetworkPolicyEditor,
  },
  props: {
    threatMonitoringPath: {
      type: String,
      required: true,
    },
    existingPolicy: {
      type: Object,
      required: false,
      default: null,
    },
    projectId: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      policyType: POLICY_TYPES.networkPolicy.value,
    };
  },
  computed: {
    policyComponent() {
      return POLICY_TYPES[this.policyType].component;
    },
  },
  created() {
    this.fetchEnvironments();
  },
  methods: {
    ...mapActions('threatMonitoring', ['fetchEnvironments']),
    updatePolicyType(type) {
      this.policyType = type;
    },
  },
  policyTypes: Object.values(POLICY_TYPES),
};
</script>

<template>
  <section class="policy-editor">
    <header class="gl-pb-5">
      <h3>{{ s__('NetworkPolicies|Policy description') }}</h3>
    </header>
    <div class="gl-display-flex">
      <gl-form-group :label="s__('NetworkPolicies|Policy type')" label-for="policyType">
        <gl-form-select
          id="policyType"
          :value="policyType"
          :options="$options.policyTypes"
          disabled
          @change="updatePolicyType"
        />
      </gl-form-group>
      <environment-picker />
    </div>
    <component
      :is="policyComponent"
      :threat-monitoring-path="threatMonitoringPath"
      :existing-policy="existingPolicy"
      :project-id="projectId"
    />
  </section>
</template>
