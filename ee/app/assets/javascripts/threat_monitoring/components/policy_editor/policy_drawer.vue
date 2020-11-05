<script>
import { GlFormTextarea } from '@gitlab/ui';
import PolicyPreview from './policy_preview.vue';
import fromYaml from './lib/from_yaml';
import toYaml from './lib/to_yaml';
import humanizeNetworkPolicy from './lib/humanize';

export default {
  components: {
    GlFormTextarea,
    PolicyPreview,
  },
  props: {
    value: {
      type: String,
      required: true,
    },
  },
  computed: {
    policy() {
      return fromYaml(this.value);
    },
    humanizedPolicy() {
      return humanizeNetworkPolicy(this.policy);
    },
    policyYaml() {
      return toYaml(this.policy);
    },
  },
  methods: {
    updateManifest(description) {
      const manifest = toYaml({ ...this.policy, description });
      this.$emit('input', manifest);
    },
  },
};
</script>

<template>
  <div>
    <h4>{{ s__('NetworkPolicies|Policy description') }}</h4>

    <h5 class="gl-mt-6">{{ s__('NetworkPolicies|Policy type') }}</h5>
    <p>{{ s__('NetworkPolicies|Network Policy') }}</p>

    <h5 class="gl-mt-6">{{ s__('NetworkPolicies|Description') }}</h5>
    <gl-form-textarea :value="policy.description" @input="updateManifest" />

    <policy-preview
      class="gl-mt-4"
      :initial-tab="1"
      :policy-yaml="policyYaml"
      :policy-description="humanizedPolicy"
    />
  </div>
</template>
