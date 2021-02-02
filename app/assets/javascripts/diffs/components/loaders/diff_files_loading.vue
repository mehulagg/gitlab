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
    <rect x="0" y="0" width="67" height="11" rx="3" />
    <rect x="76" y="0" width="140" height="11" rx="3" />
    <rect x="127" y="48" width="53" height="11" rx="3" />
    <rect x="187" y="48" width="72" height="11" rx="3" />
    <rect x="18" y="48" width="100" height="11" rx="3" />
    <rect x="0" y="71" width="37" height="11" rx="3" />
    <rect x="18" y="23" width="140" height="11" rx="3" />
    <rect x="166" y="23" width="173" height="11" rx="3" />

    <rect x="0" y="100" width="67" height="11" rx="3" />
    <rect x="76" y="100" width="140" height="11" rx="3" />
    <rect x="127" y="148" width="53" height="11" rx="3" />
    <rect x="187" y="148" width="72" height="11" rx="3" />
    <rect x="18" y="148" width="100" height="11" rx="3" />
    <rect x="0" y="171" width="37" height="11" rx="3" />
    <rect x="18" y="123" width="140" height="11" rx="3" />
    <rect x="166" y="123" width="173" height="11" rx="3" />

    <rect x="0" y="200" width="67" height="11" rx="3" />
    <rect x="76" y="200" width="140" height="11" rx="3" />
    <rect x="127" y="248" width="53" height="11" rx="3" />
    <rect x="187" y="248" width="72" height="11" rx="3" />
    <rect x="18" y="248" width="100" height="11" rx="3" />
    <rect x="0" y="271" width="37" height="11" rx="3" />
    <rect x="18" y="223" width="140" height="11" rx="3" />
    <rect x="166" y="223" width="173" height="11" rx="3" />
  </gl-skeleton-loader>
</template>
