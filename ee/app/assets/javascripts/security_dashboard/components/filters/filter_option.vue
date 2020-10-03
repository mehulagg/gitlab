<script>
import { GlIcon } from '@gitlab/ui';

export default {
  components: { GlIcon },
  props: {
    displayName: { type: String, required: true },
    isSelected: { type: Boolean, required: true },
  },
};
</script>

<template>
  <button role="menuitem" type="button" class="dropdown-item" @click="$emit('click')">
    <span class="d-flex">
      <gl-icon v-if="isSelected" class="flex-shrink-0 js-check" name="mobile-issue-close" />
      <span class="gl-white-space-nowrap gl-ml-2" :class="{ 'gl-pl-5': !isSelected }">
        {{ displayName }}
      </span>
    </span>
  </button>
</template>
