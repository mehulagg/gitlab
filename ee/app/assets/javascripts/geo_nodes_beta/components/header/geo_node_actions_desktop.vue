<script>
import { GlButton } from '@gitlab/ui';
import { __ } from '~/locale';

export default {
  name: 'GeoNodeActionsDesktop',
  i18n: {
    editButtonLabel: __('Edit'),
    removeButtonLabel: __('Remove'),
  },
  components: {
    GlButton,
  },
  props: {
    primary: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
};
</script>

<template>
  <div>
    <gl-button class="gl-mr-3">{{ $options.i18n.editButtonLabel }}</gl-button>
    <gl-button
      variant="danger"
      category="secondary"
      :disabled="primary"
      data-testid="geo-desktop-remove-action"
      >{{ $options.i18n.removeButtonLabel }}</gl-button
    >
  </div>
</template>
