<script>
import { __ } from '~/locale';

export default {
  props: {
    branches: {
      type: Array,
      required: false,
      default: () => [],
    },
  },
  computed: {
    isAnyBranch() {
      return !this.branches?.length;
    },
    branchName() {
      return this.isAnyBranch ? __('Any branch') : this.branches[0].name;
    },
  },
};
</script>

<template>
  <span :class="{ monospace: isAnyBranch }">{{ branchName }}</span>
</template>
