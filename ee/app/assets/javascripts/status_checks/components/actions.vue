<script>
import { GlButton } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  components: {
    GlButton,
  },
  i18n: {
    editButton: __('Edit'),
    removeButton: __('Remove...'),
  },
};
</script>

<template>
  <div class="gl-display-flex gl-justify-content-end">
    <gl-button data-testid="edit-btn">{{ $options.i18n.editButton }}</gl-button>
    <gl-button class="gl-ml-3" data-testid="remove-btn">
      {{ $options.i18n.removeButton }}
    </gl-button>
  </div>
</template>
