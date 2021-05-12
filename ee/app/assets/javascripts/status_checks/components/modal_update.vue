<script>
import { GlButton, GlModal, GlModalDirective } from '@gitlab/ui';
import { __, s__ } from '~/locale';
import { modalPrimaryActionProps } from '../utils';

export const i18n = {
  editButton: __('Edit'),
  title: s__('StatusCheck|Update status check'),
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
  props: {
    statusCheck: {
      type: Object,
      required: true,
    },
  },
  computed: {
    modalId() {
      return `status-checks-edit-modal-${this.statusCheck.id}`;
    },
    primaryActionProps() {
      return modalPrimaryActionProps(i18n.title, this.submitting);
    },
  },
  cancelActionProps: {
    text: i18n.cancelButton,
  },
  i18n,
};
</script>

<template>
  <div>
    <gl-button v-gl-modal="modalId" data-testid="edit-btn">
      {{ $options.i18n.editButton }}
    </gl-button>
    <gl-modal
      ref="modal"
      :modal-id="modalId"
      :title="$options.i18n.title"
      :action-primary="primaryActionProps"
      :action-cancel="$options.cancelActionProps"
      size="sm"
    />
  </div>
</template>
