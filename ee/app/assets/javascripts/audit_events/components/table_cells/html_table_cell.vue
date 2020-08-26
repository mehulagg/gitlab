<script>
import { sanitize } from 'dompurify';

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

  emits: [],
};
</script>

<template>
  <span v-html="sanitizedHtml"></span>
</template>
