<script>
import { GlAlert, GlModal, GlSprintf } from '@gitlab/ui';
import { I18N } from '../constants';

export default {
  name: 'DeleteValueStreamForm',
  components: {
    GlAlert,
    GlModal,
    GlSprintf,
  },
  props: {
    isVisible: {
      type: Boolean,
      required: true,
    },
    isDeleting: {
      type: Boolean,
      required: true,
    },
    error: {
      type: String,
      required: false,
      default: '',
    },
    valueStreamName: {
      type: String,
      required: true,
    },
  },
  I18N,
};
</script>
<template>
  <gl-modal
    data-testid="delete-value-stream-modal"
    modal-id="delete-value-stream-modal"
    :title="$options.I18N.DELETE_VALUE_STREAM_TITLE"
    :action-primary="{
      text: $options.I18N.DELETE,
      attributes: [{ variant: 'danger' }, { loading: isDeleting }],
    }"
    :action-cancel="{ text: $options.I18N.CANCEL }"
    :visible="isVisible"
    @primary.prevent="$emit('delete')"
    @hidden="$emit('hidden')"
  >
    <gl-alert v-if="error" variant="danger">{{ error }}</gl-alert>
    <p>
      <gl-sprintf :message="$options.I18N.DELETE_CONFIRMATION">
        <template #name>{{ valueStreamName }}</template>
      </gl-sprintf>
    </p>
  </gl-modal>
</template>
