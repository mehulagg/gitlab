<script>
import { GlPagination } from '@gitlab/ui';
import ImageListRow from './image_list_row.vue';

export default {
  name: 'ImageList',
  components: {
    GlPagination,
    ImageListRow,
  },
  props: {
    images: {
      type: Array,
      required: true,
    },
    pageInfo: {
      type: Object,
      required: true,
    },
  },
  computed: {
    showPagination() {
      return this.pageInfo?.hasPreviousPage || this.pageInfo?.hasNextPage;
    },
    previousPage() {
      return this.pageInfo.hasPreviousPage ? 1 : null;
    },
    nextPage() {
      return this.pageInfo.hasNextPage ? 2 : null;
    },
    currentPage: {
      get() {
        if (this.pageInfo.hasPreviousPage) {
          return 2;
        }
        return 1;
      },
      set(page) {
        if (page === 1) {
          this.$emit('prev-page');
        } else {
          this.$emit('next-page');
        }
      },
    },
  },
};
</script>

<template>
  <div class="gl-display-flex gl-flex-direction-column">
    <image-list-row
      v-for="(listItem, index) in images"
      :key="index"
      :item="listItem"
      :first="index === 0"
      @delete="$emit('delete', $event)"
    />

    <gl-pagination
      v-if="showPagination"
      v-model="currentPage"
      :prev-page="previousPage"
      :next-page="nextPage"
      align="center"
      class="gl-mt-3"
    />
  </div>
</template>
