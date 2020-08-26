<script>
import { GlSkeletonLoading } from '@gitlab/ui';
import Cell from './cell.vue';

export default {
  name: 'SkeletonCell',
  components: {
    Cell,
    GlSkeletonLoading,
  },

  emits: [],
};
</script>

<template>
  <cell>
    <gl-skeleton-loading slot="title" class="w-75 skeleton-bar" :lines="1" />
    <gl-skeleton-loading slot="value" class="w-50 skeleton-bar" :lines="1" />
  </cell>
</template>
