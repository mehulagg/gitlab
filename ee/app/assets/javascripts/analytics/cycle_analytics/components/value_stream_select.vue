<script>
import {
  GlAlert,
  GlButton,
  GlDropdown,
  GlDropdownItem,
  GlDropdownDivider,
  GlModal,
  GlModalDirective,
  GlSprintf,
} from '@gitlab/ui';
import { mapState, mapActions } from 'vuex';
import { sprintf, __, s__ } from '~/locale';
import { generateInitialStageData } from './create_value_stream_form/utils';
import ValueStreamForm from './value_stream_form.vue';

const i18n = {
  DELETE_NAME: s__('DeleteValueStream|Delete %{name}'),
  DELETE_CONFIRMATION: s__(
    'DeleteValueStream|Are you sure you want to delete the "%{name}" Value Stream?',
  ),
  DELETED: s__("DeleteValueStream|'%{name}' Value Stream deleted"),
  DELETE: __('Delete'),
  CREATE_VALUE_STREAM: s__('CreateValueStreamForm|Create new Value Stream'),
  CANCEL: __('Cancel'),
  EDIT_VALUE_STREAM: __('Edit'),
};

export default {
  components: {
    GlAlert,
    GlButton,
    GlDropdown,
    GlDropdownItem,
    GlDropdownDivider,
    GlModal,
    GlSprintf,
    ValueStreamForm,
  },
  directives: {
    GlModalDirective,
  },
  data() {
    return {
      showCreateModal: false,
      isEditing: false,
      initialData: {
        name: '',
        stages: [],
      },
    };
  },
  computed: {
    ...mapState({
      isDeleting: 'isDeletingValueStream',
      deleteValueStreamError: 'deleteValueStreamError',
      data: 'valueStreams',
      selectedValueStream: 'selectedValueStream',
      selectedValueStreamStages: 'stages',
      initialFormErrors: 'createValueStreamErrors',
      defaultStageConfig: 'defaultStageConfig',
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
    isCustomValueStream() {
      return this.selectedValueStream?.isCustom || false;
    },
    deleteConfirmationText() {
      return sprintf(this.$options.i18n.DELETE_CONFIRMATION, {
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
          this.onSuccess(sprintf(this.$options.i18n.DELETED, { name }));
        }
      });
    },
    onCreate() {
      this.showCreateModal = true;
      this.isEditing = false;
      this.initialData = {
        name: '',
        stages: [],
      };
    },
    onEdit() {
      this.showCreateModal = true;
      this.isEditing = true;
      this.initialData = {
        ...this.selectedValueStream,
        stages: generateInitialStageData(this.defaultStageConfig, this.selectedValueStreamStages),
      };
    },
  },
  i18n,
};
</script>
<template>
  <div>
    <gl-button
      v-if="isCustomValueStream"
      v-gl-modal-directive="'value-stream-form-modal'"
      data-testid="edit-value-stream"
      @click="onEdit"
      >{{ $options.i18n.EDIT_VALUE_STREAM }}</gl-button
    >
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
      <gl-dropdown-item
        v-gl-modal-directive="'value-stream-form-modal'"
        data-testid="create-value-stream"
        @click="onCreate"
        >{{ $options.i18n.CREATE_VALUE_STREAM }}</gl-dropdown-item
      >
      <gl-dropdown-item
        v-if="isCustomValueStream"
        v-gl-modal-directive="'delete-value-stream-modal'"
        variant="danger"
        data-testid="delete-value-stream"
      >
        <gl-sprintf :message="$options.i18n.DELETE_NAME">
          <template #name>{{ selectedValueStreamName }}</template>
        </gl-sprintf>
      </gl-dropdown-item>
    </gl-dropdown>
    <gl-button
      v-else
      v-gl-modal-directive="'value-stream-form-modal'"
      data-testid="create-value-stream-button"
      @click="onCreate"
      >{{ $options.i18n.CREATE_VALUE_STREAM }}</gl-button
    >
    <value-stream-form
      v-if="showCreateModal"
      :initial-data="initialData"
      :initial-form-errors="initialFormErrors"
      :default-stage-config="defaultStageConfig"
      :is-editing="isEditing"
      @hidden="showCreateModal = false"
    />
    <gl-modal
      data-testid="delete-value-stream-modal"
      modal-id="delete-value-stream-modal"
      :title="__('Delete Value Stream')"
      :action-primary="{
        text: $options.i18n.DELETE,
        attributes: [{ variant: 'danger' }, { loading: isDeleting }],
      }"
      :action-cancel="{ text: $options.i18n.CANCEL }"
      @primary.prevent="onDelete"
    >
      <gl-alert v-if="deleteValueStreamError" variant="danger">{{
        deleteValueStreamError
      }}</gl-alert>
      <p>
        <gl-sprintf :message="$options.i18n.DELETE_CONFIRMATION">
          <template #name>{{ selectedValueStreamName }}</template>
        </gl-sprintf>
      </p>
    </gl-modal>
  </div>
</template>
