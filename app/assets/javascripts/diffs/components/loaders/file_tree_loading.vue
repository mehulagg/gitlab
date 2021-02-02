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
    <circle cx="10" cy="20" r="8" />
    <rect x="25" y="15" rx="5" ry="5" width="100%" height="10" />
    <circle cx="10" cy="50" r="8" />
    <rect x="25" y="45" rx="5" ry="5" width="100%" height="10" />
    <circle cx="10" cy="80" r="8" />
    <rect x="25" y="75" rx="5" ry="5" width="100%" height="10" />
    <circle cx="10" cy="110" r="8" />
    <rect x="25" y="105" rx="5" ry="5" width="100%" height="10" />
    <circle cx="10" cy="140" r="8" />
    <rect x="25" y="135" rx="5" ry="5" width="100%" height="10" />
    <circle cx="10" cy="170" r="8" />
    <rect x="25" y="165" rx="5" ry="5" width="100%" height="10" />
    <circle cx="10" cy="200" r="8" />
    <rect x="25" y="195" rx="5" ry="5" width="100%" height="10" />
    <circle cx="10" cy="230" r="8" />
    <rect x="25" y="225" rx="5" ry="5" width="100%" height="10" />
  </gl-skeleton-loader>
</template>
