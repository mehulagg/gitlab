<script>
import { GlSearchBoxByClick } from '@gitlab/ui';
import { mapActions } from 'vuex';

export default {
  components: {
    GlSearchBoxByClick,
  },
  methods: {
    ...mapActions(['setFilter']),
  },

  emits: ['filter'],
};
</script>

<template>
  <gl-search-box-by-click
    :placeholder="s__('PackageRegistry|Filter by name')"
    @submit="$emit('filter')"
    @input="setFilter"
  />
</template>
