<script>
import { GlFormTextarea } from '@gitlab/ui';
import fromYaml from './lib/from_yaml';
import humanizeNetworkPolicy from './lib/humanize';
import toYaml from './lib/to_yaml';
import PolicyPreview from './policy_preview.vue';

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
    canHumanizePolicy() {
      console.log('to/from', toYaml(fromYaml(this.value)));
      console.log('original', this.value);
      return this.value.includes(toYaml(fromYaml(this.value)));
    },
    initialTab() {
      return this.canHumanizePolicy ? 1 : 0;
    },
    policy() {
      return this.canHumanizePolicy ? fromYaml(this.value) : null;
    },
    humanizedPolicy() {
      return this.canHumanizePolicy ? humanizeNetworkPolicy(this.policy) : null;
    },
    policyYaml() {
      return this.value;
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

    <div v-if="canHumanizePolicy">
      <h5 class="gl-mt-6">{{ s__('NetworkPolicies|Description') }}</h5>
      <gl-form-textarea :value="policy.description" @input="updateManifest" />
    </div>

    <policy-preview
      class="gl-mt-4"
      :initial-tab="initialTab"
      :policy-yaml="policyYaml"
      :policy-description="humanizedPolicy"
    />
  </div>
</template>
