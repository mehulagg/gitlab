<script>
import { GlSkeletonLoading } from '@gitlab/ui';
import Cell from './cell.vue';

export default {
  name: 'SkeletonHeaderCell',
  components: {
    Cell,
    GlSkeletonLoading,
  },

  emits: [],
};
</script>

<template>
  <cell class="license-header-cell" :is-flexible="false">
    <gl-skeleton-loading slot="title" class="w-75 skeleton-bar" :lines="1" />
  </cell>
</template>
