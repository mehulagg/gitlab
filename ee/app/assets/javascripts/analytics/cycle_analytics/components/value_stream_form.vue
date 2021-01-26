<script>
import Vue from 'vue';
import { GlButton, GlForm, GlFormInput, GlFormGroup, GlFormRadioGroup, GlModal } from '@gitlab/ui';
import { mapState, mapActions } from 'vuex';
import { sprintf } from '~/locale';
import { swapArrayItems } from '~/lib/utils/array_utility';
import {
  DEFAULT_STAGE_CONFIG,
  STAGE_SORT_DIRECTION,
  I18N,
  defaultCustomStageFields,
  PRESET_OPTIONS,
  PRESET_OPTIONS_DEFAULT,
} from './create_value_stream_form/constants';
import { validateValueStreamName, validateStage } from './create_value_stream_form/utils';
import DefaultStageFields from './create_value_stream_form/default_stage_fields.vue';
import CustomStageFields from './create_value_stream_form/custom_stage_fields.vue';

const findStageIndexByName = (stages, target = '') =>
  stages.findIndex(({ name }) => name === target);

const initializeStageErrors = (selectedPreset = PRESET_OPTIONS_DEFAULT) =>
  selectedPreset === PRESET_OPTIONS_DEFAULT ? DEFAULT_STAGE_CONFIG.map(() => ({})) : [{}];

export default {
  name: 'ValueStreamForm',
  components: {
    GlButton,
    GlForm,
    GlFormInput,
    GlFormGroup,
    GlFormRadioGroup,
    GlModal,
    DefaultStageFields,
    CustomStageFields,
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
          stageErrors: initializeStageErrors(PRESET_OPTIONS_DEFAULT),
          ...initialData,
        }
      : { stages: [] };
    return {
      selectedPreset: PRESET_OPTIONS[0].value,
      presetOptions: PRESET_OPTIONS,
      name: '',
      nameError: { name: [] },
      stageErrors: [{}],
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
    secondaryProps() {
      return {
        text: this.$options.I18N.BTN_ADD_ANOTHER_STAGE,
        attributes: [
          { category: 'secondary' },
          { variant: 'info' },
          { class: this.hasExtendedFormFields ? '' : 'gl-display-none' },
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
    }
  },
  methods: {
    ...mapActions(['createValueStream']),
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
    stageKey(index) {
      return this.selectedPreset === PRESET_OPTIONS_DEFAULT
        ? `default-template-stage-${index}`
        : `custom-template-stage-${index}`;
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
      Vue.set(this, 'nameError', validateValueStreamName({ name }));
      Vue.set(this, 'stageErrors', this.validateStages());
    },
    moveItem(arr, index, direction) {
      return direction === STAGE_SORT_DIRECTION.UP
        ? swapArrayItems(arr, index - 1, index)
        : swapArrayItems(arr, index, index + 1);
    },
    handleMove({ index, direction }) {
      const newStages = this.moveItem(this.stages, index, direction);
      const newErrors = this.moveItem(this.stageErrors, index, direction);
      Vue.set(this, 'stageErrors', newErrors);
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
    onRemove(index) {
      const newErrors = this.stageErrors.filter((_, idx) => idx !== index);
      const newStages = this.stages.filter((_, idx) => idx !== index);
      Vue.set(this, 'stages', [...newStages]);
      Vue.set(this, 'stageErrors', [...newErrors]);
    },
    onRestore(hiddenStageIndex) {
      const stage = this.hiddenStages[hiddenStageIndex];
      const stageIndex = findStageIndexByName(this.stages, stage.name);
      Vue.set(this.stages, stageIndex, { ...stage, hidden: false });
    },
    onAddStage() {
      // validate previous stages only and add a new stage
      this.validate();
      Vue.set(this, 'stages', [...this.stages, { ...defaultCustomStageFields }]);
      Vue.set(this, 'stageErrors', [...this.stageErrors, {}]);
    },
    onFieldInput(activeStageIndex, { field, value }) {
      const updatedStage = { ...this.stages[activeStageIndex], [field]: value };
      Vue.set(this.stages, activeStageIndex, updatedStage);
    },
    handleResetDefaults() {
      this.name = '';
      DEFAULT_STAGE_CONFIG.forEach((stage, index) => {
        Vue.set(this.stages, index, { ...stage, hidden: false });
      });
    },
    handleResetBlank() {
      this.name = '';
      Vue.set(this, 'stages', [{ ...defaultCustomStageFields }]);
    },
    onSelectPreset() {
      if (this.selectedPreset === PRESET_OPTIONS_DEFAULT) {
        this.handleResetDefaults();
      } else {
        this.handleResetBlank();
      }
      Vue.set(this, 'stageErrors', initializeStageErrors(this.selectedPreset));
    },
  },
  I18N,
};
</script>
<template>
  <gl-modal
    data-testid="value-stream-form-modal"
    modal-id="value-stream-form-modal"
    dialog-class="gl-align-items-flex-start! gl-py-7"
    scrollable
    :title="$options.I18N.FORM_TITLE"
    :action-primary="primaryProps"
    :action-secondary="secondaryProps"
    :action-cancel="{ text: $options.I18N.BTN_CANCEL }"
    @secondary.prevent="onAddStage"
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
          />
          <gl-button
            v-if="hiddenStages.length"
            class="gl-ml-3"
            variant="link"
            @click="handleResetDefaults"
            >{{ $options.I18N.RESTORE_DEFAULTS }}</gl-button
          >
        </div>
      </gl-form-group>
      <gl-form-radio-group
        v-if="hasExtendedFormFields"
        v-model="selectedPreset"
        class="gl-mb-4"
        data-testid="vsa-preset-selector"
        :options="presetOptions"
        name="preset"
        @input="onSelectPreset"
      />
      <div v-if="hasExtendedFormFields" data-testid="extended-form-fields">
        <div v-for="(stage, activeStageIndex) in activeStages" :key="stageKey(activeStageIndex)">
          <hr class="gl-my-3" />
          <span
            class="gl-display-flex gl-m-0 gl-vertical-align-middle gl-mr-2 gl-font-weight-bold gl-display-flex gl-pb-3"
            >{{ stageGroupLabel(activeStageIndex) }}</span
          >
          <custom-stage-fields
            v-if="stage.custom"
            :stage="stage"
            :stage-events="formEvents"
            :index="activeStageIndex"
            :total-stages="activeStages.length"
            :errors="fieldErrors(activeStageIndex)"
            @move="handleMove"
            @remove="onRemove"
            @input="onFieldInput(activeStageIndex, $event)"
          />
          <default-stage-fields
            v-else
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
