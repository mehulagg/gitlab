<script>
import { GlPagination } from '@gitlab/ui';

export default {
  components: {
    GlPagination,
  },
  props: {
    value: {
      required: false,
      type: Object,
      default: () => ({
        page: 1,
      }),
    },
    pageInfo: {
      required: false,
      type: Object,
      default: () => ({}),
    },
  },
  computed: {
    prevPage() {
      return this.pageInfo?.hasPreviousPage ? this.value?.page - 1 : null;
    },
    nextPage() {
      return this.pageInfo?.hasNextPage ? this.value?.page + 1 : null;
    },
  },
  methods: {
    handlePageChange(page) {
      const { startCursor, endCursor } = this.pageInfo;

      let newValue;
      if (page > this.value.page) {
        newValue = {
          page,
          after: endCursor,
        };
      } else {
        newValue = {
          page,
          before: startCursor,
        };
      }
      this.$emit('input', newValue);
    },
  },
};
</script>

<template>
  <gl-pagination
    :value="value.page"
    :prev-page="prevPage"
    :next-page="nextPage"
    align="center"
    class="gl-pagination gl-mt-3"
    @input="handlePageChange"
  />
</template>
