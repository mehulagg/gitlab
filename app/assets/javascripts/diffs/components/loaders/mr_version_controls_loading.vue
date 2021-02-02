<script>
import { GlSkeletonLoader } from '@gitlab/ui';

export default {
  components: {
    GlSkeletonLoader,
  },
};
</script>

<template>
  <gl-skeleton-loader height="100%" width="100%">
    <rect height="5.5" rx="1" ry="1" width="85%" x="31" y="5" />
    <rect height="5.5" rx="1" ry="1" width="85%" x="31" y="15" />
    <circle cx="95%" cy="12" r="12" />
    <rect height="24" rx="0" ry="0" width="24" x="0" y="0" />
  </gl-skeleton-loader>
</template>
