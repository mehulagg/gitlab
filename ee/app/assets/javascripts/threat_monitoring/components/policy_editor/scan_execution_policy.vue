<script>
import { GlLink } from '@gitlab/ui';
import BasePolicy from './base_policy.vue';
import PolicyInfoRow from './policy_info_row.vue';

export default {
  components: {
    GlLink,
    BasePolicy,
    PolicyInfoRow,
  },
};
</script>

<template>
  <base-policy v-bind="$attrs">
    <template #type>{{ s__('NetworkPolicies|Scan execution') }}</template>

    <template #default="{ policy, enforcementStatusLabel }">
      <div v-if="policy">
        <policy-info-row
          v-if="policy.description"
          data-testid="description"
          :label="s__('NetworkPolicies|Description')"
          >{{ policy.description }}</policy-info-row
        >

        <policy-info-row v-if="policy.rule" :label="s__('NetworkPolicies|Rule')">{{
          policy.rule
        }}</policy-info-row>

        <policy-info-row v-if="policy.action" :label="s__('NetworkPolicies|Action')">{{
          policy.action
        }}</policy-info-row>

        <policy-info-row :label="s__('NetworkPolicies|Enforcement status')">{{
          enforcementStatusLabel
        }}</policy-info-row>

        <policy-info-row v-if="policy.latestScan" :label="s__('NetworkPolicies|Latest scan')"
          >{{ policy.latestScan.date }}
          <gl-link :href="policy.latestScan.pipelineUrl">{{
            s__('NetworkPolicies|view results')
          }}</gl-link></policy-info-row
        >
      </div>
    </template>
  </base-policy>
</template>
