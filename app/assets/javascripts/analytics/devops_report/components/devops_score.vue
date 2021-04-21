<script>
import { GlTable } from '@gitlab/ui';

export default {
  components: {
    GlTable,
  },
  inject: {
    createdAt: {
      default: null,
    },
    cards: {
      default: null,
    },
    averageScore: {
      default: null,
    },
  },
};
</script>
<template>
  <gl-table />
</template>
