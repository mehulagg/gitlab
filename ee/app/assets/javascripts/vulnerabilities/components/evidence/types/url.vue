<script>
import { GlLink } from '@gitlab/ui';

export default {
  components: {
    GlLink,
  },
  props: {
    name: {
      type: String,
      required: false,
      default: '',
    },
    href: {
      type: String,
      required: true,
    },
  },
  computed: {
    linkText() {
      return this.name || this.href;
    },
  },
};
</script>
<template>
  <gl-link :href="href" target="_blank">{{ linkText }}</gl-link>
</template>
