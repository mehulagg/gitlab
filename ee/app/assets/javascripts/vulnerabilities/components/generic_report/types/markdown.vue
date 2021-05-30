<script>
/* eslint-disable vue/no-v-html */
import { GlLoadingIcon } from '@gitlab/ui';
import axios from '~/lib/utils/axios_utils';

export default {
  components: { GlLoadingIcon },
  props: {
    value: {
      type: String,
      required: true,
    },
    markdownEndpoint: {
      type: String,
      default: '/api/v4/markdown',
      required: false,
    },
  },
  data() {
    return {
      markdown: '',
      loading: true,
      loadError: false,
      error: false,
    };
  },
  mounted() {
    this.renderMarkdown();
  },
  methods: {
    renderMarkdown() {
      axios
        .post(this.markdownEndpoint, {
          text: this.value,
          gfm: true,
        })
        .then(res => res.data)
        .then(data => {
          this.markdown = data.html;
          this.loading = false;
        })
        .catch(e => {
          if (e.status !== 200) {
            this.loadError = true;
          }
          this.error = true;
        });
    },
  },
};
</script>

<template>
  <div>
    <div v-if="loading && !error" class="text-center loading">
      <gl-loading-icon class="mt-5" size="lg" />
    </div>
    <div v-if="!loading && !error" v-html="markdown"></div>
  </div>
</template>