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
import { STAGE_ACTIONS, DEFAULT_STAGE_NAMES } from '../../constants';
import { getAllowedEndEvents, getLabelEventsIdentifiers } from '../../utils';
import CustomStageFormFields from './custom_stage_form_fields.vue';

const defaultFields = {
  id: null,
  name: null,
  startEventIdentifier: null,
  startEventLabelId: null,
  endEventIdentifier: null,
  endEventLabelId: null,
};

const defaultErrors = {
  id: [],
  name: [],
  startEventIdentifier: [],
  startEventLabelId: [],
  endEventIdentifier: [],
  endEventLabelId: [],
};

const ERRORS = {
  START_EVENT_REQUIRED: s__('CustomCycleAnalytics|Please select a start event first'),
  STAGE_NAME_EXISTS: s__('CustomCycleAnalytics|Stage name already exists'),
  INVALID_EVENT_PAIRS: s__(
    'CustomCycleAnalytics|Start event changed, please select a valid stop event',
  ),
};

export const initializeFormData = ({ emptyFieldState = defaultFields, fields, errors }) => {
  const initErrors = fields?.endEventIdentifier
    ? defaultErrors
    : {
        ...defaultErrors,
        endEventIdentifier: !fields?.startEventIdentifier ? [ERRORS.START_EVENT_REQUIRED] : [],
      };
  return {
    fields: {
      ...emptyFieldState,
      ...fields,
    },
    errors: {
      ...initErrors,
      ...errors,
    },
  };
};

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
      errors: [],
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
    isComplete() {
      // TODO: maybe this should take an array, and index
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
    handleSelectLabel(key, labelId) {
      this.fields[key] = labelId;
    },
    handleClearLabel(key) {
      this.fields[key] = null;
    },
    hasFieldErrors(key) {
      return this.errors[key]?.length > 0;
    },
    fieldErrorMessage(key) {
      return this.errors[key]?.join('\n');
    },
    onUpdateNameField() {
      this.errors.name = DEFAULT_STAGE_NAMES.includes(this.fields.name.toLowerCase())
        ? [ERRORS.STAGE_NAME_EXISTS]
        : [];
    },
    onUpdateStartEventField() {
      this.fields.endEventIdentifier = null;
      this.errors.endEventIdentifier = [ERRORS.INVALID_EVENT_PAIRS];
    },
    onUpdateEndEventField() {
      this.errors.endEventIdentifier = [];
    },
    handleRecoverStage(id) {
      this.$emit(STAGE_ACTIONS.UPDATE, { id, hidden: false });
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
        class="js-recover-hidden-stage-dropdown"
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
      @input="
        newFields => {
          fields = newFields;
        }
      "
    />
    <div class="custom-stage-form-actions">
      <gl-button
        :disabled="!isDirty"
        category="primary"
        class="js-save-stage-cancel"
        @click="handleCancel"
      >
        {{ __('Cancel') }}
      </gl-button>
      <gl-button
        :disabled="!isComplete || !isDirty"
        variant="success"
        category="primary"
        class="js-save-stage"
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
