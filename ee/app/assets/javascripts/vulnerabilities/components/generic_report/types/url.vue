<script>
import { GlLink } from '@gitlab/ui';

export default {
  components: {
    GlLink,
  },
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
