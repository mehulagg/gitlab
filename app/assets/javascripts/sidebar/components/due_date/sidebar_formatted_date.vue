<script>
import { GlButton } from '@gitlab/ui';

export default {
  components: {
    GlButton,
  },
  inject: ['canUpdate'],
  props: {
    formattedDate: {
      required: true,
      type: String,
    },
    hasDate: {
      required: true,
      type: Boolean,
    },
    resetAction: {
      required: true,
      type: Function,
    },
    resetText: {
      required: true,
      type: String,
    },
    isLoading: {
      required: true,
      type: Boolean,
    },
  },
};
</script>

<template>
  <div class="gl-display-flex gl-align-items-center hide-collapsed">
    <span
      :class="hasDate ? 'gl-text-gray-900 gl-font-weight-bold' : 'gl-text-gray-500'"
      data-testid="sidebar-duedate-value"
    >
      {{ formattedDate }}
    </span>
    <div v-if="hasDate && canUpdate" class="gl-display-flex">
      <span class="gl-px-2">-</span>
      <gl-button
        variant="link"
        class="gl-text-gray-500!"
        data-testid="reset-button"
        :disabled="isLoading"
        @click="resetAction(null)"
      >
        {{ resetText }}
      </gl-button>
    </div>
  </div>
</template>
