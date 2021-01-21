<script>
import {
  GlAlert,
  GlButton,
  GlDropdown,
  GlDropdownItem,
  GlDropdownDivider,
  GlModal,
  GlModalDirective,
} from '@gitlab/ui';
import { mapState, mapActions } from 'vuex';
import { sprintf, __ } from '~/locale';
import ValueStreamForm from './value_stream_form.vue';

const I18N = {
  DELETE_NAME: __('Delete %{name}'),
  DELETE_CONFIRMATION: __('Are you sure you want to delete "%{name}" Value Stream?'),
  DELETED: __("'%{name}' Value Stream deleted"),
  DELETE: __('Delete'),
  CREATE_VALUE_STREAM: __('Create new Value Stream'),
  CANCEL: __('Cancel'),
};

export default {
  components: {
    GlAlert,
    GlButton,
    GlDropdown,
    GlDropdownItem,
    GlDropdownDivider,
    GlModal,
    ValueStreamForm,
  },
  directives: {
    GlModalDirective,
  },
  props: {
    hasExtendedFormFields: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    ...mapState({
      isDeleting: 'isDeletingValueStream',
      deleteValueStreamError: 'deleteValueStreamError',
      data: 'valueStreams',
      selectedValueStream: 'selectedValueStream',
    }),
    hasValueStreams() {
      return Boolean(this.data.length);
    },
    selectedValueStreamName() {
      return this.selectedValueStream?.name || '';
    },
    selectedValueStreamId() {
      return this.selectedValueStream?.id || null;
    },
    canDeleteSelectedStage() {
      return this.selectedValueStream?.isCustom || false;
    },
    deleteSelectedText() {
      return sprintf(this.$options.I18N.DELETE_NAME, { name: this.selectedValueStreamName });
    },
    deleteConfirmationText() {
      return sprintf(this.$options.I18N.DELETE_CONFIRMATION, {
        name: this.selectedValueStreamName,
      });
    },
  },
  methods: {
    ...mapActions(['setSelectedValueStream', 'deleteValueStream']),
    onSuccess(message) {
      this.$toast.show(message, { position: 'top-center' });
    },
    isSelected(id) {
      return Boolean(this.selectedValueStreamId && this.selectedValueStreamId === id);
    },
    onSelect(selectedId) {
      this.setSelectedValueStream(this.data.find(({ id }) => id === selectedId));
    },
    onDelete() {
      const name = this.selectedValueStreamName;
      return this.deleteValueStream(this.selectedValueStreamId).then(() => {
        if (!this.deleteValueStreamError) {
          this.onSuccess(sprintf(this.$options.I18N.DELETED, { name }));
        }
      });
    },
  },
  I18N,
};
</script>
<template>
  <div>
    <gl-dropdown
      v-if="hasValueStreams"
      data-testid="dropdown-value-streams"
      :text="selectedValueStreamName"
      right
    >
      <gl-dropdown-item
        v-for="{ id, name: streamName } in data"
        :key="id"
        :is-check-item="true"
        :is-checked="isSelected(id)"
        @click="onSelect(id)"
        >{{ streamName }}</gl-dropdown-item
      >
      <gl-dropdown-divider />
      <gl-dropdown-item v-gl-modal-directive="'value-stream-form-modal'">{{
        $options.I18N.CREATE_VALUE_STREAM
      }}</gl-dropdown-item>
      <gl-dropdown-item
        v-if="canDeleteSelectedStage"
        v-gl-modal-directive="'delete-value-stream-modal'"
        variant="danger"
        data-testid="delete-value-stream"
        >{{ deleteSelectedText }}</gl-dropdown-item
      >
    </gl-dropdown>
    <gl-button v-else v-gl-modal-directive="'value-stream-form-modal'">{{
      $options.I18N.CREATE_VALUE_STREAM
    }}</gl-button>
    <value-stream-form :has-extended-form-fields="hasExtendedFormFields" />
    <gl-modal
      data-testid="delete-value-stream-modal"
      modal-id="delete-value-stream-modal"
      :title="__('Delete Value Stream')"
      :action-primary="{
        text: $options.I18N.DELETE,
        attributes: [{ variant: 'danger' }, { loading: isDeleting }],
      }"
      :action-cancel="{ text: $options.I18N.CANCEL }"
      @primary.prevent="onDelete"
    >
      <gl-alert v-if="deleteValueStreamError" variant="danger">{{
        deleteValueStreamError
      }}</gl-alert>
      <p>{{ deleteConfirmationText }}</p>
    </gl-modal>
  </div>
</template>
