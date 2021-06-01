<script>
import { __ } from '~/locale';
import fromYaml, { removeUnnecessaryDashes } from './lib/from_yaml';
import humanizeNetworkPolicy from './lib/humanize';

export default {
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
      return this.policy?.isEnabled ? __('Enabled') : __('Disabled');
    },
  },
};
</script>

<template>
  <div>
    <h5 class="gl-mt-3">{{ __('Type') }}</h5>
    <p>
      <slot name="type"></slot>
    </p>
    <slot v-bind="{ policy, humanizedPolicy, policyYaml, enforcementStatusLabel }"></slot>
  </div>
</template>
