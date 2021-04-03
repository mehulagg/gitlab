<script>
import { GlPagination } from '@gitlab/ui';
import { getParameterValues, setUrlParams } from '~/lib/utils/url_utility';

export default {
  components: {
    GlPagination,
  },
  props: {
    isLastPage: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      page: parseInt(getParameterValues('page')[0], 10) || 1,
    };
  },
  computed: {
    isOnlyPage() {
      return this.isLastPage && this.page === 1;
    },
    prevPage() {
      return this.page > 1 ? this.page - 1 : null;
    },
    nextPage() {
      return !this.isLastPage ? this.page + 1 : null;
    },
  },
  methods: {
    generateLink(page) {
      return setUrlParams({ page });
    },
  },
};
</script>

<template>
  <gl-pagination
    v-if="!isOnlyPage"
    v-model="page"
    :prev-page="prevPage"
    :next-page="nextPage"
    :link-gen="generateLink"
    align="center"
    class="w-100"
  />
</template>
