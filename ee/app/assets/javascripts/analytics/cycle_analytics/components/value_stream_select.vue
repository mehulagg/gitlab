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

const findStageById = (defaultStageConfig, _id = '') => {
  console.log('findStageById', defaultStageConfig, _id);
  return defaultStageConfig.find(({ name }) => name.toLowerCase().trim() === _id);
};

const prepareCustomStage = ({ startEventLabel = {}, endEventLabel = {}, ...rest }) => ({
  ...rest,
  startEventLabelId: startEventLabel?.id ? startEventLabel.id : null,
  endEventLabelId: endEventLabel?.id ? endEventLabel.id : null,
  isDefault: false,
});

// default stages currently dont have any label based events
const prepareDefaultStage = (defaultStageConfig, { name, ...rest }) => {
  const stage = findStageById(defaultStageConfig, name.toLowerCase().trim()) || {};
  const { startEventIdentifier = null, endEventIdentifier = null } = stage;
  return {
    ...rest,
    name,
    startEventIdentifier,
    endEventIdentifier,
    isDefault: true,
  };
};

// TODO: name spaces like the others
const I18N = {
  DELETE_NAME: __('Delete %{name}'),
  DELETE_CONFIRMATION: __('Are you sure you want to delete "%{name}" Value Stream?'),
  DELETED: __("'%{name}' Value Stream deleted"),
  DELETE: __('Delete'),
  CREATE_VALUE_STREAM: __('Create new Value Stream'),
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
  data() {
    return {
      showModal: false,
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
    onCreate() {
      this.showModal = true;
      this.initialData = {
        name: '',
        stages: [],
      };
    },
    onEdit() {
      // TODO: when editing a default stage name, I think we need to send `custom`???
      // TODO: this will probably also break hwo we check for a default stage?

      // TODO: hidden default value stream stages should be calculated when the form loads, separate MR
      // TODO: trigger the modal with the selected value stream
      this.showModal = true;
      this.isEditing = true;
      // TODO: move this to a util
      this.initialData = {
        ...this.selectedValueStream,
        stages: this.selectedValueStreamStages.map(
          // TODO: AFAICT default stages won't specify the start / end event identifiers
          // TODO: i dont think this will hold true if you edit a default stage, it might then become custom?
          // TODO: perhaps updating the stage only preserves one of the events that are used for the stage, not both...
          // TODO: might need to re-think how we track default stages once they have been updated - maybe some additional UI to highlight it was a default?
          // once the default stage is updated it becomes `custom` should we still allow selection of `issue_start_event`?

          ({ startEventIdentifier = null, endEventIdentifier = null, custom = false, ...rest }) => {
            const stageData =
              custom && startEventIdentifier && endEventIdentifier
                ? prepareCustomStage(rest)
                : prepareDefaultStage(this.defaultStageConfig, rest);
            return {
              ...stageData,
              startEventIdentifier,
              endEventIdentifier,
              custom,
            };
          },
        ),
      };
    },
  },
  I18N,
};
</script>
<template>
  <div>
    <gl-button
      v-if="hasExtendedFormFields"
      v-gl-modal-directive="'value-stream-form-modal'"
      @click="onEdit"
      >{{ $options.I18N.EDIT_VALUE_STREAM }}</gl-button
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
      <gl-dropdown-item v-gl-modal-directive="'value-stream-form-modal'" @click="onCreate">{{
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
    <value-stream-form
      v-if="showModal"
      :initial-data="initialData"
      :initial-form-errors="initialFormErrors"
      :has-extended-form-fields="hasExtendedFormFields"
      :default-stage-config="defaultStageConfig"
      :is-editing="isEditing"
      @hidden="showModal = false"
    />
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
