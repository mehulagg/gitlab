<script>
import { __ } from '~/locale';

export default {
  props: {
    rule: {
      type: Object,
      required: true,
    },
  },
  computed: {
    branchName() {
      const { protectedBranches } = this.rule;
      const [protectedBranch] = protectedBranches || [];
      return protectedBranch?.name || __('Any branch');
    },
    isAnyBranch() {
      return this.rule.protectedBranches?.length;
    },
  },
};
</script>

<template>
  <div :class="{ monospace: isAnyBranch }">{{ branchName }}</div>
</template>
