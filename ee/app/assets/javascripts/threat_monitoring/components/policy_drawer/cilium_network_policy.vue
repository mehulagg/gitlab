<script>
import {
  fromYaml,
  humanizeNetworkPolicy,
  removeUnnecessaryDashes,
} from '../policy_editor/network_policy/lib';
import PolicyPreview from '../policy_editor/policy_preview.vue';
import BasePolicy from './base_policy.vue';
import PolicyInfoRow from './policy_info_row.vue';

export default {
  components: {
    BasePolicy,
    PolicyPreview,
    PolicyInfoRow,
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
  },
};
</script>

<template>
  <base-policy :policy="policy">
    <template #type>{{ s__('NetworkPolicies|Network policy') }}</template>

    <template #default="{ enforcementStatusLabel }">
      <div v-if="policy">
        <policy-info-row
          v-if="policy.description"
          data-testid="description"
          :label="s__('NetworkPolicies|Description')"
          >{{ policy.description }}</policy-info-row
        >

        <policy-info-row :label="s__('NetworkPolicies|Enforcement status')">{{
          enforcementStatusLabel
        }}</policy-info-row>
      </div>

      <policy-preview
        class="gl-mt-4"
        :initial-tab="initialTab"
        :policy-yaml="policyYaml"
        :policy-description="humanizedPolicy"
      />
    </template>
  </base-policy>
</template>
