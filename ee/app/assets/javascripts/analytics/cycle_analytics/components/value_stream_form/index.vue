<script>
import Vue from 'vue';
import { mapState, mapActions } from 'vuex';
import { GlButton, GlButtonGroup, GlForm, GlFormInput, GlFormGroup, GlModal } from '@gitlab/ui';
import { debounce } from 'lodash';
import { sprintf, __, s__ } from '~/locale';
import { DATA_REFETCH_DELAY } from '../../../shared/constants';

const ERRORS = {
  MIN_LENGTH: s__('CreateValueStreamForm|Name is required'),
  MAX_LENGTH: s__('CreateValueStreamForm|Maximum length 100 characters'),
};

const defaultStageFields = {
  name: '',
  custom: true,
  startEventIdentifier: null,
  startEventLabelId: null,
  endEventIdentifier: null,
  endEventLabelId: null,
  hidden: false,
};

const NAME_MAX_LENGTH = 100;

const validate = ({ name }) => {
  const errors = { name: [] };
  if (name.length > NAME_MAX_LENGTH) {
    errors.name.push(ERRORS.MAX_LENGTH);
  }
  if (!name.length) {
    errors.name.push(ERRORS.MIN_LENGTH);
  }
  return errors;
};

// TODO: move to constants
const I18N = {
  CREATE_VALUE_STREAM: __('Create Value Stream'),
  CREATED: __("'%{name}' Value Stream created"),
  CANCEL: __('Cancel'),
  FIELD_NAME_LABEL: __('Value Stream name'),
  FIELD_NAME_PLACEHOLDER: __('Example: My Value Stream'),
};

const SORT_DIRECTION = {
  UP: 'UP',
  DOWN: 'DOWN',
};

const swapArrayItems = (arr, left, right) => {
  // TODO: bounds checking
  return [...arr.slice(0, left), arr[right], arr[left], ...arr.slice(right + 1, arr.length)];
};

export default {
  name: 'ValueStreamForm',
  components: {
    GlButton,
    GlButtonGroup,
    GlForm,
    GlFormInput,
    GlFormGroup,
    GlModal,
  },
  props: {
    initialData: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    hasPathNavigation: {
      type: Boolean,
      required: false,
      default: false,
    },
    // Forcing this to false until this is supported on the BE
    canReorderDefaults: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    const { hasPathNavigation, initialData } = this;
    const additionalFields = hasPathNavigation
      ? {
          stages: [{ ...defaultStageFields }],
        }
      : {};
    return {
      form: {
        name: '',
        ...additionalFields,
        ...initialData,
      },
      errors: {},
    };
  },
  computed: {
    ...mapState({
      initialFormErrors: 'createValueStreamErrors',
      isCreating: 'isCreatingValueStream',
    }),
    isValid() {
      return !this.errors.name?.length;
    },
    invalidFeedback() {
      return this.errors.name?.join('\n');
    },
    hasFormErrors() {
      const { initialFormErrors } = this;
      return Boolean(Object.keys(initialFormErrors).length);
    },
    isLoading() {
      return this.isCreating;
    },
    primaryProps() {
      return {
        text: this.$options.I18N.CREATE_VALUE_STREAM,
        attributes: [
          { variant: 'success' },
          { disabled: !this.isValid },
          { loading: this.isLoading },
        ],
      };
    },
    secondaryProps() {
      return {
        text: s__('CreateValueStreamForm|Add another stage'),
        attributes: [{ variant: 'info', category: 'secondary' }],
      };
    },
    stagesCount() {
      return this.form.stages.length;
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
    ...mapActions(['createValueStream']),
    onHandleInput: debounce(function debouncedValidation() {
      const { form } = this;
      this.errors = validate(form);
    }, DATA_REFETCH_DELAY),
    onAddStage() {
      this.form.stages.push({ ...defaultStageFields });
    },
    findPositionByIndex(index) {
      return this.form.stages.findIndex(stage => stage.index === index);
    },
    isFirstStage(pos) {
      return pos === 0;
    },
    isLastStage(pos) {
      return pos === this.stagesCount - 1;
    },
    onSubmit() {
      const { name, stages } = this;
      return this.createValueStream({ name, stages }).then(() => {
        if (!this.hasFormErrors) {
          this.$toast.show(sprintf(this.$options.I18N.CREATED, { name }), {
            position: 'top-center',
          });
          this.name = '';
        }
      });
    },
    handleMove({ index, direction }) {
      const newStages =
        direction === SORT_DIRECTION.UP
          ? swapArrayItems(this.form.stages, index - 1, index)
          : swapArrayItems(this.form.stages, index, index + 1);

      Vue.set(this.form, 'stages', newStages);
    },
    handleRemove(index) {
      const nextStages = this.form.stages.filter((_, i) => i !== index);
      Vue.set(this.form, 'stages', nextStages);
    },
    handleReset() {
      Vue.set(this, 'form', {
        name: '',
        stages: [{ ...defaultStageFields }],
      });
    },
  },
  I18N,
  SORT_DIRECTION,
};
</script>
<template>
  <gl-modal
    data-testid="value-stream-form-modal"
    modal-id="value-stream-form-modal"
    scrollable
    :title="$options.I18N.CREATE_VALUE_STREAM"
    :action-primary="primaryProps"
    :action-cancel="{ text: $options.I18N.CANCEL }"
    :action-secondary="secondaryProps"
    @secondary.prevent="onAddStage"
    @primary.prevent="onSubmit"
  >
    <gl-form>
      <gl-form-group
        :label="$options.I18N.FIELD_NAME_LABEL"
        label-for="create-value-stream-name"
        :invalid-feedback="invalidFeedback"
        :state="isValid"
      >
        <div class="gl-display-flex gl-justify-content-space-between">
          <gl-form-input
            id="create-value-stream-name"
            v-model.trim="form.name"
            name="create-value-stream-name"
            :placeholder="$options.I18N.FIELD_NAME_PLACEHOLDER"
            :state="isValid"
            required
            @input="onHandleInput"
          />
          <gl-button v-if="hasPathNavigation" class="gl-ml-3" variant="link" @click="handleReset">{{
            __('Restore defaults')
          }}</gl-button>
        </div>
      </gl-form-group>
      <div v-if="hasPathNavigation">
        <hr />
        <div v-for="(stage, activeStageIndex) in form.stages" :key="activeStageIndex">
          <gl-form-group :label="sprintf(__('Stage %{index}'), { index: activeStageIndex + 1 })">
            <div class="gl-display-flex gl-flex-direction-row gl-justify-content-space-between">
              <gl-form-input
                v-if="stage.custom"
                v-model.trim="stage.name"
                :name="`create-value-stream-stage-${activeStageIndex}`"
                :placeholder="s__('CreateValueStreamForm|Enter stage name')"
                :state="isValid"
                required
                @input="onHandleInput"
              />
              <gl-button-group class="gl-px-2">
                <gl-button
                  :disabled="isLastStage(activeStageIndex)"
                  icon="arrow-down"
                  @click="
                    handleMove({ index: activeStageIndex, direction: $options.SORT_DIRECTION.DOWN })
                  "
                />
                <gl-button
                  :disabled="isFirstStage(activeStageIndex)"
                  icon="arrow-up"
                  @click="
                    handleMove({ index: activeStageIndex, direction: $options.SORT_DIRECTION.UP })
                  "
                />
              </gl-button-group>
              <!-- TODO: disable remove when theres no values -->
              <gl-button icon="remove" @click="handleRemove(activeStageIndex)" />
            </div>
          </gl-form-group>
        </div>
      </div>
    </gl-form>
  </gl-modal>
</template>
