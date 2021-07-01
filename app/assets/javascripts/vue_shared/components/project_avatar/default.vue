<script>
import { GlAvatar } from '@gitlab/ui';

export default {
  components: {
    GlAvatar,
  },
  props: {
    project: {
      type: Object,
      required: true,
    },
    size: {
      type: Number,
      default: 32,
      required: false,
    },
  },
  computed: {
    sizeClass() {
      return `s${this.size}`;
    },
  },
};
</script>

<template>
  <gl-avatar
    class="gl-mr-5 gl-float-left"
    shape="rect"
    :src="project.avatar_url"
    :alt="project.name"
    :entity-name="project.name"
    :size="size"
  />
</template>
