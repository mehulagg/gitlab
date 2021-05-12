<script>
import { GlButton, GlModal, GlModalDirective } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import { modalPrimaryActionProps } from '../utils';

export const i18n = {
  addButton: s__('StatusCheck|Add status check'),
  title: s__('StatusCheck|Add status check'),
  cancelButton: __('Cancel'),
};

export default {
  components: {
    GlButton,
    GlModal,
  },
  directives: {
    GlModal: GlModalDirective,
  },
  computed: {
    primaryActionProps() {
      return modalPrimaryActionProps(i18n.title);
    },
  },
  modalId: 'status-checks-add-modal',
  cancelActionProps: {
    text: i18n.cancelButton,
  },
  i18n,
};
</script>

<template>
  <div>
    <gl-button v-gl-modal="$options.modalId" category="secondary" variant="confirm" size="small">
      {{ $options.i18n.addButton }}
    </gl-button>
    <gl-modal
      ref="modal"
      :modal-id="$options.modalId"
      :title="$options.i18n.title"
      :action-primary="primaryActionProps"
      :action-cancel="$options.cancelActionProps"
      size="sm"
    />
  </div>
</template>
