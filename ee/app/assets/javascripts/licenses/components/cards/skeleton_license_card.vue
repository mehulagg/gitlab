<script>
import { GlSkeletonLoading } from '@gitlab/ui';
import { SkeletonCell, SkeletonHeaderCell } from '../cells';

export default {
  name: 'SkeletonLicenseCard',
  components: {
    GlSkeletonLoading,
    SkeletonCell,
    SkeletonHeaderCell,
  },

  emits: [],
};
</script>

<template>
  <div class="card license-card skeleton-license-card">
    <div class="card-header d-flex justify-content-between align-items-center py-3">
      <gl-skeleton-loading class="w-75 skeleton-bar" :lines="1" />
    </div>

    <div class="card-body p-0">
      <div class="license-table">
        <div class="license-row d-flex">
          <skeleton-header-cell />
          <skeleton-cell />
          <skeleton-cell />
          <skeleton-cell />
          <skeleton-cell />
        </div>

        <div class="license-row d-flex">
          <skeleton-header-cell />
          <skeleton-cell />
          <skeleton-cell />
          <skeleton-cell />
        </div>

        <div class="license-row d-flex">
          <skeleton-header-cell />
          <skeleton-cell />
          <skeleton-cell />
          <skeleton-cell />
        </div>
      </div>
    </div>
  </div>
</template>
