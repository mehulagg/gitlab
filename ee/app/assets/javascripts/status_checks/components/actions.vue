<script>
import { GlButton } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  components: {
    GlButton,
  },
  props: {
    statusCheck: {
      type: Object,
      required: true,
    },
  },
  i18n: {
    editButton: __('Edit'),
    removeButton: __('Remove...'),
  },
};
</script>

<template>
  <div class="gl-display-flex gl-justify-content-end">
    <gl-button data-testid="edit-btn" @click="$emit('update-status-to-check', statusCheck)">
      {{ $options.i18n.editButton }}
    </gl-button>
    <gl-button class="gl-ml-3" data-testid="remove-btn">
      {{ $options.i18n.removeButton }}
    </gl-button>
  </div>
</template>
