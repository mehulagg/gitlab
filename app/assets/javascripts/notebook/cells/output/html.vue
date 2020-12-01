<script>
/* eslint-disable vue/no-v-html */
import { sanitize } from '~/lib/dompurify';
import Prompt from '../prompt.vue';

export default {
  components: {
    Prompt,
  },
  props: {
    count: {
      type: Number,
      required: true,
    },
    rawCode: {
      type: String,
      required: true,
    },
    index: {
      type: Number,
      required: true,
    },
    codeCssClass: {
      type: String,
      required: false,
      default: '',
    },
  },
  computed: {
    sanitizedOutput() {
      return sanitize(this.rawCode);
    },
    showOutput() {
      return this.index === 0;
    },
  },
};
</script>

<template>
  <div class="output">
    <prompt type="Out" :count="count" :show-output="showOutput" />
    <div v-if="sanitizedOutput.length" class="gl-overflow-auto" v-html="sanitizedOutput"></div>
    <pre v-else ref="code" :class="codeCssClass" class="language-python" v-text="rawCode"></pre>
  </div>
</template>
