<script>
import { GlFormGroup, GlFormSelect } from '@gitlab/ui';
import { mapActions } from 'vuex';
import glFeatureFlagMixin from '~/vue_shared/mixins/gl_feature_flags_mixin';
import EnvironmentPicker from '../environment_picker.vue';
import { POLICY_KIND_OPTIONS } from './constants';
import NetworkPolicyEditor from './network_policy/network_policy_editor.vue';
import ScanExecutionPolicyEditor from './scan_execution_policy/scan_execution_policy_editor.vue';

export default {
  components: {
    GlFormGroup,
    GlFormSelect,
    EnvironmentPicker,
    NetworkPolicyEditor,
    ScanExecutionPolicyEditor,
  },
  mixins: [glFeatureFlagMixin()],
  props: {
    existingPolicy: {
      type: Object,
      required: false,
      default: null,
    },
  },
  data() {
    return {
      policyType: POLICY_KIND_OPTIONS.network.value,
    };
  },
  computed: {
    policyComponent() {
      return POLICY_KIND_OPTIONS[this.policyType].component;
    },
    shouldAllowPolicyTypeSelection() {
      return !this.existingPolicy && this.glFeatures.scanExecutionPolicyUi;
    },
    shouldShowEnvironmentPicker() {
      return POLICY_KIND_OPTIONS[this.policyType].shouldShowEnvironmentPicker;
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
  policyTypes: Object.values(POLICY_KIND_OPTIONS),
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
          :disabled="!shouldAllowPolicyTypeSelection"
          @change="updatePolicyType"
        />
      </gl-form-group>
      <environment-picker v-if="shouldShowEnvironmentPicker" />
    </div>
    <component :is="policyComponent" :existing-policy="existingPolicy" />
  </section>
</template>
