<script>
import { mapGetters, mapState } from 'vuex';
import { isEqual } from 'lodash';
import {
  GlLoadingIcon,
  GlDropdown,
  GlDropdownSectionHeader,
  GlDropdownItem,
  GlSprintf,
  GlButton,
} from '@gitlab/ui';
import { s__ } from '~/locale';
import { convertObjectPropsToSnakeCase } from '~/lib/utils/common_utils';
import CustomStageFormFields from './create_value_stream_form/custom_stage_fields.vue';
import { validateFields, initializeFormData } from './create_value_stream_form/utils';
import { defaultFields, ERRORS } from './create_value_stream_form/constants';
import { STAGE_ACTIONS } from '../constants';
import { getAllowedEndEvents, getLabelEventsIdentifiers, isLabelEvent } from '../utils';

export default {
  components: {
    GlLoadingIcon,
    GlDropdown,
    GlDropdownSectionHeader,
    GlDropdownItem,
    GlSprintf,
    GlButton,
    CustomStageFormFields,
  },
  props: {
    events: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      labelEvents: getLabelEventsIdentifiers(this.events),
      fields: {},
      errors: {},
    };
  },
  computed: {
    ...mapGetters(['hiddenStages']),
    ...mapState('customStages', [
      'isLoading',
      'isSavingCustomStage',
      'isEditingCustomStage',
      'formInitialData',
      'formErrors',
    ]),

    hasErrors() {
      return (
        this.eventMismatchError || Object.values(this.errors).some(errArray => errArray?.length)
      );
    },
    startEventRequiresLabel() {
      return isLabelEvent(this.labelEvents, this.fields.startEventIdentifier);
    },
    endEventRequiresLabel() {
      return isLabelEvent(this.labelEvents, this.fields.endEventIdentifier);
    },
    isComplete() {
      if (this.hasErrors) {
        return false;
      }
      const {
        fields: {
          name,
          startEventIdentifier,
          startEventLabelId,
          endEventIdentifier,
          endEventLabelId,
        },
      } = this;

      const requiredFields = [startEventIdentifier, endEventIdentifier, name];
      if (this.startEventRequiresLabel) {
        requiredFields.push(startEventLabelId);
      }
      if (this.endEventRequiresLabel) {
        requiredFields.push(endEventLabelId);
      }
      return requiredFields.every(
        fieldValue => fieldValue && (fieldValue.length > 0 || fieldValue > 0),
      );
    },
    isDirty() {
      return !isEqual(this.fields, this.formInitialData || defaultFields);
    },
    eventMismatchError() {
      const {
        fields: { startEventIdentifier = null, endEventIdentifier = null },
      } = this;

      if (!startEventIdentifier || !endEventIdentifier) return true;
      const endEvents = getAllowedEndEvents(this.events, startEventIdentifier);
      return !endEvents.length || !endEvents.includes(endEventIdentifier);
    },
    saveStageText() {
      return this.isEditingCustomStage
        ? s__('CustomCycleAnalytics|Update stage')
        : s__('CustomCycleAnalytics|Add stage');
    },
    formTitle() {
      return this.isEditingCustomStage
        ? s__('CustomCycleAnalytics|Editing stage')
        : s__('CustomCycleAnalytics|New stage');
    },
    hasHiddenStages() {
      return this.hiddenStages.length;
    },
  },
  watch: {
    formInitialData(newFields = {}) {
      this.fields = {
        ...defaultFields,
        ...newFields,
      };
    },
    formErrors(newErrors = {}) {
      this.errors = {
        ...newErrors,
      };
    },
  },
  mounted() {
    this.resetFields();
  },
  methods: {
    resetFields() {
      const { formInitialData, formErrors } = this;
      const { fields, errors } = initializeFormData({
        fields: formInitialData,
        errors: formErrors,
      });
      this.fields = { ...fields };
      this.errors = { ...errors };
    },
    handleCancel() {
      this.resetFields();
      this.$emit('cancel');
    },
    handleSave() {
      const data = convertObjectPropsToSnakeCase(this.fields);
      if (this.isEditingCustomStage) {
        const { id } = this.fields;
        this.$emit(STAGE_ACTIONS.UPDATE, { ...data, id });
      } else {
        this.$emit(STAGE_ACTIONS.CREATE, data);
      }
    },
    hasFieldErrors(key) {
      return this.errors[key]?.length > 0;
    },
    fieldErrorMessage(key) {
      return this.errors[key]?.join('\n');
    },
    handleRecoverStage(id) {
      this.$emit(STAGE_ACTIONS.UPDATE, { id, hidden: false });
    },
    handleUpdateFields(field, value) {
      this.fields = { ...this.fields, [field]: value };
      const newErrors = validateFields(this.fields);
      newErrors.endEventIdentifier =
        this.fields.startEventIdentifier && this.eventMismatchError
          ? [ERRORS.INVALID_EVENT_PAIRS]
          : newErrors.endEventIdentifier;
      this.errors = { ...this.errors, ...newErrors };
    },
  },
};
</script>
<template>
  <div v-if="isLoading">
    <gl-loading-icon class="mt-4" size="md" />
  </div>
  <form v-else class="custom-stage-form m-4 mt-0">
    <div class="gl-mb-1 gl-display-flex gl-justify-content-space-between gl-align-items-center">
      <h4>{{ formTitle }}</h4>
      <gl-dropdown
        :text="__('Recover hidden stage')"
        data-testid="recover-hidden-stage-dropdown"
        right
      >
        <gl-dropdown-section-header>{{ __('Default stages') }}</gl-dropdown-section-header>
        <template v-if="hasHiddenStages">
          <gl-dropdown-item
            v-for="stage in hiddenStages"
            :key="stage.id"
            @click="handleRecoverStage(stage.id)"
            >{{ stage.title }}</gl-dropdown-item
          >
        </template>
        <p v-else class="mx-3 my-2">{{ __('All default stages are currently visible') }}</p>
      </gl-dropdown>
    </div>
    <custom-stage-form-fields
      :fields="fields"
      :label-events="labelEvents"
      :errors="errors"
      :events="events"
      @update="handleUpdateFields"
    />
    <div class="custom-stage-form-actions">
      <gl-button
        :disabled="!isDirty"
        category="primary"
        data-testid="cancel-custom-stage"
        @click="handleCancel"
      >
        {{ __('Cancel') }}
      </gl-button>
      <gl-button
        :disabled="!isComplete || !isDirty"
        variant="success"
        category="primary"
        data-testid="save-custom-stage"
        @click="handleSave"
      >
        <gl-loading-icon v-if="isSavingCustomStage" size="sm" inline />
        {{ saveStageText }}
      </gl-button>
    </div>
    <div class="mt-2">
      <gl-sprintf
        :message="
          __(
            '%{strongStart}Note:%{strongEnd} Once a custom stage has been added you can re-order stages by dragging them into the desired position.',
          )
        "
      >
        <template #strong="{ content }">
          <strong>{{ content }}</strong>
        </template>
      </gl-sprintf>
    </div>
  </form>
</template>
