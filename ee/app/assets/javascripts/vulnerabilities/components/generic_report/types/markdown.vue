<script>
import { GlSkeletonLoader, GlSafeHtmlDirective as SafeHtml } from '@gitlab/ui';
import { getMarkdown } from '~/rest_api';

export default {
  components: { GlSkeletonLoader },
  directives: {
    SafeHtml,
  },
  inheritAttrs: false,
  props: {
    value: {
      type: String,
      required: true,
    },
  },
  data() {
    return {
      markdown: '',
      loading: true,
      error: false,
    };
  },
  computed: {
    isLoading() {
      return this.loading && !this.error;
    },
    isLoaded() {
      return !this.loading && !this.error;
    },
  },
  mounted() {
    this.renderMarkdown();
  },
  methods: {
    renderMarkdown() {
      getMarkdown({
        text: this.value,
        gfm: true,
      })
        .then(({ data }) => {
          this.markdown = data.html;
          this.loading = false;
        })
        .catch(() => {
          this.error = true;
        });
    },
  },
};
</script>

<template>
  <div>
    <gl-skeleton-loader v-if="isLoading" :width="200" :lines="2" />
    <div v-if="isLoaded" v-safe-html="markdown" data-testid="markdown"></div>
  </div>
</template>
