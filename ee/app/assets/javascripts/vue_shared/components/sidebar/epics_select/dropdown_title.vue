<script>
import { GlLoadingIcon, GlLink } from '@gitlab/ui';

export default {
  components: {
    GlLoadingIcon,
    GlLink,
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
      <gl-link
        class="edit-link float-right sidebar-dropdown-toggle"
        @click="$emit('onClickEdit', $event)"
        >{{ __('Edit') }}</gl-link
      >
    </template>
  </div>
</template>
