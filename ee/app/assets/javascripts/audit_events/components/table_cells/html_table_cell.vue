<script>
import { GlSafeHtmlDirective as SafeHtml } from '@gitlab/ui';

export default {
  directives: {
    SafeHtml,
  },
  props: {
    html: {
      type: String,
      required: true,
    },
  },
  safeHtmlConfig: { ALLOWED_TAGS: [] },
};
</script>

<template>
  <span v-safe-html:[$options.safeHtmlConfig]="html"></span>
</template>
