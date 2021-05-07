<script>
import { GlButton } from '@gitlab/ui';
import { __ } from '~/locale';
import ModalUpdate from './modal_update.vue';

export default {
  components: {
    GlButton,
    ModalUpdate,
  },
  props: {
    statusCheck: {
      type: Object,
      required: true,
    },
  },
  i18n: {
    removeButton: __('Remove...'),
  },
};
</script>

<template>
  <div class="gl-display-flex gl-justify-content-end">
    <modal-update :status-check="statusCheck" />
    <gl-button class="gl-ml-3" data-testid="remove-btn">
      {{ $options.i18n.removeButton }}
    </gl-button>
  </div>
</template>
