<script>
import { GlLoadingIcon, GlButton } from '@gitlab/ui';

export default {
  components: {
    GlLoadingIcon,
    GlButton,
  },
  props: {
    canEdit: {
      type: Boolean,
      required: true,
    },
    blockTitle: {
      type: String,
      required: true,
    },
    isLoading: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
};
</script>

<template>
  <div class="title hide-collapsed align-items-center gl-mb-3">
    <div class="flex-grow-1">
      <span :class="{ 'align-text-top': isLoading }">{{ blockTitle }}</span>
      <gl-loading-icon v-show="isLoading" inline />
    </div>
    <template v-if="canEdit">
      <gl-button
        class="sidebar-dropdown-toggle"
        category="tertiary"
        variant="default"
        size="small"
        @click="$emit('onClickEdit', $event)"
        >{{ __('Edit') }}</gl-button
      >
    </template>
  </div>
</template>
