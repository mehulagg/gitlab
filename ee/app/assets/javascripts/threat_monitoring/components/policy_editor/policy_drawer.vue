<script>
import { __ } from '~/locale';
import fromYaml, { removeUnnecessaryDashes } from './lib/from_yaml';
import humanizeNetworkPolicy from './lib/humanize';
import PolicyPreview from './policy_preview.vue';

export default {
  components: {
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
      const policy = fromYaml(this.value);
      return policy.error ? null : policy;
    },
    humanizedPolicy() {
      return this.policy ? humanizeNetworkPolicy(this.policy) : this.policy;
    },
    policyYaml() {
      return removeUnnecessaryDashes(this.value);
    },
    enforcementStatusLabel() {
      return this.policy.isEnabled ? __('Enabled') : __('Disabled');
    },
  },
};
</script>

<template>
  <div>
    <h5 class="gl-mt-3">{{ __('Type') }}</h5>
    <p>{{ s__('NetworkPolicies|Container runtime') }}</p>

    <div v-if="policy">
      <template v-if="policy.description">
        <h5 class="gl-mt-6">{{ s__('NetworkPolicies|Description') }}</h5>
        <p data-testid="description">{{ policy.description }}</p>
      </template>

      <h5 class="gl-mt-6">{{ s__('NetworkPolicies|Enforcement status') }}</h5>
      <p>{{ enforcementStatusLabel }}</p>
    </div>

    <policy-preview
      class="gl-mt-4"
      :policy-yaml="policyYaml"
      :policy-description="humanizedPolicy"
    />
  </div>
</template>
