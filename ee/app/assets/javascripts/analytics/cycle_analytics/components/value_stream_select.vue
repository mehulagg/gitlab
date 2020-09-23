<script>
import {
  GlAlert,
  GlButton,
  GlDropdown,
  GlDropdownItem,
  GlDropdownDivider,
  GlForm,
  GlFormInput,
  GlFormGroup,
  GlModal,
  GlModalDirective,
} from '@gitlab/ui';
import { mapState, mapActions } from 'vuex';
import { debounce } from 'lodash';
import { sprintf, __ } from '~/locale';
import { DATA_REFETCH_DELAY } from '../../shared/constants';

const ERRORS = {
  MIN_LENGTH: __('Name is required'),
  MAX_LENGTH: __('Maximum length 100 characters'),
};

const validate = ({ name }) => {
  const errors = { name: [] };
  if (name.length > 100) {
    errors.name.push(ERRORS.MAX_LENGTH);
  }
  if (!name.length) {
    errors.name.push(ERRORS.MIN_LENGTH);
  }
  return errors;
};

export default {
  components: {
    GlAlert,
    GlButton,
    GlDropdown,
    GlDropdownItem,
    GlDropdownDivider,
    GlForm,
    GlFormInput,
    GlFormGroup,
    GlModal,
  },
  directives: {
    GlModalDirective,
  },
  data() {
    return {
      name: '',
      errors: {},
    };
  },
  computed: {
    ...mapState({
      isDeleting: 'isDeletingValueStream',
      isCreating: 'isCreatingValueStream',
      deleteValueStreamError: 'deleteValueStreamError',
      initialFormErrors: 'createValueStreamErrors',
      data: 'valueStreams',
      selectedValueStream: 'selectedValueStream',
    }),
    isLoading() {
      return this.isDeleting || this.isCreating;
    },
    isValid() {
      return !this.errors.name?.length;
    },
    invalidFeedback() {
      return this.errors.name?.join('\n');
    },
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
    hasFormErrors() {
      const { initialFormErrors } = this;
      return Boolean(Object.keys(initialFormErrors).length);
    },
    deleteSelectedText() {
      return sprintf(__('Delete %{name}'), { name: this.selectedValueStreamName });
    },
    deleteConfirmationText() {
      return sprintf(__('Are you sure you want to delete "%{name}" Value Stream?'), {
        name: this.selectedValueStreamName,
      });
    },
  },
  watch: {
    initialFormErrors(newErrors = {}) {
      this.errors = newErrors;
    },
  },
  mounted() {
    const { initialFormErrors } = this;
    if (this.hasFormErrors) {
      this.errors = initialFormErrors;
    } else {
      this.onHandleInput();
    }
  },
  methods: {
    ...mapActions(['createValueStream', 'setSelectedValueStream', 'deleteValueStream']),
    onSubmit() {
      const { name } = this;
      return this.createValueStream({ name }).then(() => {
        if (!this.hasFormErrors) {
          this.$toast.show(sprintf(__("'%{name}' Value Stream created"), { name }), {
            position: 'top-center',
          });
          this.name = '';
        }
      });
    },
    onHandleInput: debounce(function debouncedValidation() {
      const { name } = this;
      this.errors = validate({ name });
    }, DATA_REFETCH_DELAY),
    isSelected(id) {
      return Boolean(this.selectedValueStreamId && this.selectedValueStreamId === id);
    },
    onSelect(id) {
      this.setSelectedValueStream(id);
    },
    onDelete() {
      const name = this.selectedValueStreamName;
      return this.deleteValueStream(this.selectedValueStreamId).then(() => {
        if (!this.deleteValueStreamError) {
          this.$toast.show(sprintf(__("'%{name}' Value Stream deleted"), { name }), {
            position: 'top-center',
          });
        }
      });
    },
  },
};
</script>
<template>
  <gl-form>
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
      <gl-dropdown-item v-gl-modal-directive="'create-value-stream-modal'" @click="onHandleInput">{{
        __('Create new Value Stream')
      }}</gl-dropdown-item>
      <gl-dropdown-item
        v-if="canDeleteSelectedStage"
        v-gl-modal-directive="'delete-value-stream-modal'"
        variant="danger"
        data-testid="delete-value-stream"
        >{{ deleteSelectedText }}</gl-dropdown-item
      >
    </gl-dropdown>
    <gl-button v-else v-gl-modal-directive="'create-value-stream-modal'" @click="onHandleInput">{{
      __('Create new Value Stream')
    }}</gl-button>
    <gl-modal
      data-testid="create-value-stream-modal"
      modal-id="create-value-stream-modal"
      :title="__('Value Stream Name')"
      :action-primary="{
        text: __('Create Value Stream'),
        attributes: [
          { variant: 'success' },
          {
            disabled: !isValid,
          },
          { loading: isLoading },
        ],
      }"
      :action-cancel="{ text: __('Cancel') }"
      @primary.prevent="onSubmit"
    >
      <gl-form-group
        :label="__('Name')"
        label-for="create-value-stream-name"
        :invalid-feedback="invalidFeedback"
        :state="isValid"
      >
        <gl-form-input
          id="create-value-stream-name"
          v-model.trim="name"
          name="create-value-stream-name"
          :placeholder="__('Example: My Value Stream')"
          :state="isValid"
          required
          @input="onHandleInput"
        />
      </gl-form-group>
    </gl-modal>
    <gl-modal
      data-testid="delete-value-stream-modal"
      modal-id="delete-value-stream-modal"
      :title="__('Delete Value Stream')"
      :action-primary="{
        text: __('Delete'),
        attributes: [{ variant: 'danger' }, { loading: isLoading }],
      }"
      :action-cancel="{ text: __('Cancel') }"
      @primary.prevent="onDelete"
    >
      <gl-alert v-if="deleteValueStreamError" variant="danger">{{
        deleteValueStreamError
      }}</gl-alert>
      <p>{{ deleteConfirmationText }}</p>
    </gl-modal>
  </gl-form>
</template>
