<script>
import { sanitize } from '~/lib/dompurify';

const ALLOWED_TAGS = ['strong'];

export default {
  props: {
    html: {
      type: String,
      required: true,
    },
  },
  computed: {
    sanitizedHtml() {
      return sanitize(this.html, { ALLOWED_TAGS });
    },
  },
};
</script>

<template>
  <span v-html="sanitizedHtml /* eslint-disable-line vue/no-v-html */"></span>
</template>
