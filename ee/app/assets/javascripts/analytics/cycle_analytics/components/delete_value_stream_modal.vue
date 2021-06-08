<script>
import { GlAlert, GlModal, GlSprintf } from '@gitlab/ui';
import { mapState, mapActions } from 'vuex';
import { sprintf } from '~/locale';
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
  },
  computed: {
    ...mapState({
      isDeleting: 'isDeletingValueStream',
      error: 'deleteValueStreamError',
      selectedValueStream: 'selectedValueStream',
    }),
    deleteConfirmationText() {
      return sprintf(this.$options.I18N.DELETE_CONFIRMATION, {
        name: this.selectedValueStreamName,
      });
    },
    selectedValueStreamName() {
      return this.selectedValueStream?.name || '';
    },
    selectedValueStreamId() {
      return this.selectedValueStream?.id || '';
    },
  },
  methods: {
    ...mapActions(['deleteValueStream']),
    onDelete() {
      const name = this.selectedValueStreamName;
      return this.deleteValueStream(this.selectedValueStreamId).then(() => {
        if (!this.error) {
          this.$emit('success', sprintf(this.$options.I18N.DELETED, { name }));
          this.track('delete_value_stream', { extra: { name } });
        }
      });
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
    @primary.prevent="onDelete"
    @hidden="$emit('hidden')"
  >
    <gl-alert v-if="error" variant="danger">{{ error }}</gl-alert>
    <p>
      <gl-sprintf :message="$options.I18N.DELETE_CONFIRMATION">
        <template #name>{{ selectedValueStreamName }}</template>
      </gl-sprintf>
    </p>
  </gl-modal>
</template>
