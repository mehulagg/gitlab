<script>
import { __ } from '~/locale';
import {
  fromYaml,
  humanizeNetworkPolicy,
  removeUnnecessaryDashes,
} from '../policy_editor/network_policy/lib';
import PolicyPreview from '../policy_editor/policy_preview.vue';

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
    initialTab() {
      return this.policy ? 0 : 1;
    },
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
      if (this.policy) {
        return this.policy.isEnabled ? __('Enabled') : __('Disabled');
      }
      return null;
    },
  },
};
</script>

<template>
  <div>
    <h5 class="gl-mt-3">{{ __('Type') }}</h5>
    <p>{{ s__('NetworkPolicies|Network policy') }}</p>

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
      :initial-tab="initialTab"
      :policy-yaml="policyYaml"
      :policy-description="humanizedPolicy"
    />
  </div>
</template>
