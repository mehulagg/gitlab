<script>
import { GlIcon, GlTruncate } from '@gitlab/ui';

export default {
  components: { GlIcon, GlTruncate },
  props: {
    displayName: { type: String, required: true },
    isSelected: { type: Boolean, required: true },
  },
};
</script>

<template>
  <a role="menuitem" type="button" class="dropdown-item" @click="$emit('click')">
    <gl-icon v-if="isSelected" class="gl-absolute" name="mobile-issue-close" />
    <gl-truncate class="gl-ml-2 gl-pl-5" :text="displayName" />
  </a>
</template>
