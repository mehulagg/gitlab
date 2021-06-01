<script>
import BasePolicy from './base_policy.vue';
import PolicyInfoRow from './policy_info_row.vue';
import PolicyPreview from './policy_preview.vue';

export default {
  components: {
    BasePolicy,
    PolicyPreview,
    PolicyInfoRow,
  },
};
</script>

<template>
  <base-policy v-bind="$attrs">
    <template #type>{{ s__('NetworkPolicies|Container runtime') }}</template>

    <template #default="{ policy, humanizedPolicy, policyYaml, enforcementStatusLabel }">
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
        :initial-tab="policy ? 0 : 1"
        :policy-yaml="policyYaml"
        :policy-description="humanizedPolicy"
      />
    </template>
  </base-policy>
</template>
