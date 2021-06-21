<script>
import { GlLink } from '@gitlab/ui';

export default {
  components: {
    GlLink,
  },
  inject: ['projectCommitPath'],
  props: {
    value: {
      type: String,
      required: true,
    },
  },
  computed: {
    linkToCommit() {
      return `${this.projectCommitPath}/${this.value}`;
    },
  },
};
</script>

<template>
  <gl-link :href="linkToCommit">{{ value }}</gl-link>
</template>
