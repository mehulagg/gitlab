<script>
import { GlLink } from '@gitlab/ui';

export default {
  components: {
    GlLink,
  },
  inheritAttrs: false,
  props: {
    href: {
      type: String,
      required: true,
    },
  },
};
</script>
<template>
  <gl-link :href="href">{{ href }}</gl-link>
</template>
