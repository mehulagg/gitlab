<script>
import 'mathjax/es5/tex-svg';
import { GlSafeHtmlDirective as SafeHtml } from '@gitlab/ui';
import Prompt from '../prompt.vue';

export default {
  name: 'LatexOutput',
  components: {
    Prompt,
  },
  directives: {
    SafeHtml,
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
  mounted() {
    // MathJax will not parse out the inline delimeters "$$" correctly
    // so we remove them from the raw code itself
    const parsedCode = this.rawCode.replace(/\$\$/g, '');
    this.$refs.maths.appendChild(window.MathJax.tex2svg(parsedCode));
  },
};
</script>

<template>
  <div class="output">
    <prompt type="Out" :count="count" :show-output="index === 0" />
    <div ref="maths"></div>
  </div>
</template>
