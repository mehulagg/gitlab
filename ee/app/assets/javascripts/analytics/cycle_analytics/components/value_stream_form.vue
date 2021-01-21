<script>
import Vue from 'vue';
import { GlButton, GlForm, GlFormInput, GlFormGroup, GlModal } from '@gitlab/ui';
import { debounce } from 'lodash';
import { mapState, mapActions } from 'vuex';
import { sprintf } from '~/locale';
import {
  DEFAULT_STAGE_CONFIG,
  STAGE_SORT_DIRECTION,
  I18N,
} from './create_value_stream_form/constants';
import { validateValueStreamName, validateStage } from './create_value_stream_form/utils';
import DefaultStageFields from './create_value_stream_form/default_stage_fields.vue';
import { DATA_REFETCH_DELAY } from '../../shared/constants';

const swapArrayItems = (arr, left, right) => [
  ...arr.slice(0, left),
  arr[right],
  arr[left],
  ...arr.slice(right + 1, arr.length),
];

const findStageIndexByName = (stages, target = '') =>
  stages.findIndex(({ name }) => name === target);

export default {
  name: 'ValueStreamForm',
  components: {
    GlButton,
    GlForm,
    GlFormInput,
    GlFormGroup,
    GlModal,
    DefaultStageFields,
  },
  props: {
    initialData: {
      type: Object,
      required: false,
      default: () => ({}),
    },
    hasExtendedFormFields: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    const { hasExtendedFormFields, initialData } = this;
    const additionalFields = hasExtendedFormFields
      ? {
          stages: DEFAULT_STAGE_CONFIG,
          ...initialData,
        }
      : { stages: [] };
    return {
      name: '',
      nameError: {},
      stageErrors: [],
      ...additionalFields,
    };
  },
  computed: {
    ...mapState({
      initialFormErrors: 'createValueStreamErrors',
      isCreating: 'isCreatingValueStream',
    }),
    ...mapState('customStages', ['formEvents']),
    isValueStreamNameValid() {
      return !this.nameError.name?.length;
    },
    invalidFeedback() {
      return this.nameError.name?.join('\n');
    },
    hasInitialFormErrors() {
      const { initialFormErrors } = this;
      return Boolean(Object.keys(initialFormErrors).length);
    },
    isValid() {
      return this.isValueStreamNameValid && !this.hasInitialFormErrors;
    },
    isLoading() {
      return this.isCreating;
    },
    primaryProps() {
      return {
        text: this.$options.I18N.FORM_TITLE,
        attributes: [
          { variant: 'success' },
          { disabled: !this.isValid },
          { loading: this.isLoading },
        ],
      };
    },
    hiddenStages() {
      return this.stages.filter((stage) => stage.hidden);
    },
    activeStages() {
      return this.stages.filter((stage) => !stage.hidden);
    },
  },
  watch: {
    initialFormErrors(newErrors = {}) {
      this.stageErrors = newErrors;
    },
  },
  mounted() {
    const { initialFormErrors } = this;
    if (this.hasInitialFormErrors) {
      this.stageErrors = initialFormErrors;
    } else {
      this.validate();
    }
  },
  methods: {
    ...mapActions(['createValueStream']),
    onUpdateValueStreamName: debounce(function debouncedValidation() {
      const { name } = this;
      this.nameError = validateValueStreamName({ name });
    }, DATA_REFETCH_DELAY),
    onSubmit() {
      const { name, stages } = this;
      return this.createValueStream({
        name,
        stages: stages.map(({ name: stageName, ...rest }) => ({
          name: stageName,
          ...rest,
          title: stageName,
        })),
      }).then(() => {
        if (!this.hasInitialFormErrors) {
          this.$toast.show(sprintf(this.$options.I18N.FORM_CREATED, { name }), {
            position: 'top-center',
          });
          this.name = '';
        }
      });
    },
    stageGroupLabel(index) {
      return sprintf(this.$options.I18N.STAGE_INDEX, { index: index + 1 });
    },
    recoverStageTitle(name) {
      return sprintf(this.$options.I18N.HIDDEN_DEFAULT_STAGE, { name });
    },
    validateStages() {
      return this.activeStages.map(validateStage);
    },
    validate() {
      const { name } = this;
      this.nameError = validateValueStreamName({ name });
      this.stageErrors = this.validateStages();
    },
    handleMove({ index, direction }) {
      const newStages =
        direction === STAGE_SORT_DIRECTION.UP
          ? swapArrayItems(this.stages, index - 1, index)
          : swapArrayItems(this.stages, index, index + 1);

      Vue.set(this, 'stages', newStages);
    },
    validateStageFields(index) {
      Vue.set(this.stageErrors, index, validateStage(this.activeStages[index]));
    },
    fieldErrors(index) {
      return this.stageErrors[index];
    },
    onHide(index) {
      const stage = this.stages[index];
      Vue.set(this.stages, index, { ...stage, hidden: true });
    },
    onRestore(hiddenStageIndex) {
      const stage = this.hiddenStages[hiddenStageIndex];
      const stageIndex = findStageIndexByName(this.stages, stage.name);
      Vue.set(this.stages, stageIndex, { ...stage, hidden: false });
    },
    handleReset() {
      this.name = '';
      DEFAULT_STAGE_CONFIG.forEach((stage, index) => {
        Vue.set(this.stages, index, { ...stage, hidden: false });
      });
    },
  },
  I18N,
};
</script>
<template>
  <gl-modal
    data-testid="value-stream-form-modal"
    modal-id="value-stream-form-modal"
    scrollable
    :title="$options.I18N.FORM_TITLE"
    :action-primary="primaryProps"
    :action-cancel="{ text: $options.I18N.BTN_CANCEL }"
    @primary.prevent="onSubmit"
  >
    <gl-form>
      <gl-form-group
        label-for="create-value-stream-name"
        :label="$options.I18N.FORM_FIELD_NAME_LABEL"
        :invalid-feedback="invalidFeedback"
        :state="isValueStreamNameValid"
      >
        <div class="gl-display-flex gl-justify-content-space-between">
          <gl-form-input
            id="create-value-stream-name"
            v-model.trim="name"
            name="create-value-stream-name"
            :placeholder="$options.I18N.FORM_FIELD_NAME_PLACEHOLDER"
            :state="isValueStreamNameValid"
            required
            @input="onUpdateValueStreamName"
          />
          <gl-button
            v-if="hiddenStages.length"
            class="gl-ml-3"
            variant="link"
            @click="handleReset"
            >{{ $options.I18N.RESTORE_DEFAULTS }}</gl-button
          >
        </div>
      </gl-form-group>
      <div v-if="hasExtendedFormFields" data-testid="extended-form-fields">
        <hr />
        <div v-for="(stage, activeStageIndex) in activeStages" :key="activeStageIndex">
          <span
            class="gl-display-flex gl-m-0 gl-vertical-align-middle gl-mr-2 gl-font-weight-bold gl-display-flex"
            >{{ stageGroupLabel(activeStageIndex) }}</span
          >
          <default-stage-fields
            :stage="stage"
            :stage-events="formEvents"
            :index="activeStageIndex"
            :total-stages="activeStages.length"
            :errors="fieldErrors(activeStageIndex)"
            @move="handleMove"
            @hide="onHide"
            @input="validateStageFields(activeStageIndex)"
          />
        </div>
        <div v-if="hiddenStages.length">
          <hr />
          <gl-form-group v-for="(stage, hiddenStageIndex) in hiddenStages" :key="stage.id">
            <span class="gl-m-0 gl-vertical-align-middle gl-mr-3 gl-font-weight-bold">{{
              recoverStageTitle(stage.name)
            }}</span>
            <gl-button variant="link" @click="onRestore(hiddenStageIndex)">{{
              $options.I18N.RESTORE_HIDDEN_STAGE
            }}</gl-button>
          </gl-form-group>
        </div>
      </div>
    </gl-form>
  </gl-modal>
</template>
