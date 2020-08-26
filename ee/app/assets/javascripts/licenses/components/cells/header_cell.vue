<script>
import { GlIcon } from '@gitlab/ui';
import Cell from './cell.vue';

export default {
  name: 'HeaderCell',
  components: {
    GlIcon,
    Cell,
  },
  props: {
    title: {
      type: String,
      required: true,
    },
    icon: {
      type: String,
      required: true,
    },
  },

  emits: [],
};
</script>

<template>
  <cell class="license-header-cell" :is-flexible="false">
    <template slot="title">
      <gl-icon class="icon" :name="icon" />
      <span class="ml-2 font-weight-bold">{{ title }}</span>
    </template>
  </cell>
</template>
