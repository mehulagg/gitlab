<script>
import { GlFormGroup, GlFormInput, GlFormSelect } from '@gitlab/ui';
import LabelsSelector from '../labels_selector.vue';
import { I18N } from './constants';
import { startEventOptions, endEventOptions } from './utils';
import { isLabelEvent } from '../../utils';

export default {
  name: 'CustomStageFormFields',
  components: {
    GlFormGroup,
    GlFormInput,
    GlFormSelect,
    LabelsSelector,
  },
  props: {
    fields: {
      type: Object,
      required: true,
    },
    errors: {
      type: Object,
      required: false,
      default: () => {},
    },
    events: {
      type: Array,
      required: true,
    },
    labelEvents: {
      type: Array,
      required: true,
    },
  },
  computed: {
    startEvents() {
      return startEventOptions(this.events);
    },
    endEvents() {
      return endEventOptions(this.events, this.fields.startEventIdentifier);
    },
    hasStartEvent() {
      return this.fields.startEventIdentifier;
    },
    startEventRequiresLabel() {
      return isLabelEvent(this.labelEvents, this.fields.startEventIdentifier);
    },
    endEventRequiresLabel() {
      return isLabelEvent(this.labelEvents, this.fields.endEventIdentifier);
    },
  },
  methods: {
    eventFieldClasses(condition) {
      return condition ? 'gl-w-half gl-mr-2' : 'gl-w-full';
    },
    hasFieldErrors(key) {
      return this.errors[key]?.length < 1;
    },
    fieldErrorMessage(key) {
      return this.errors[key]?.join('\n');
    },
    handleUpdateField(field, value) {
      this.$emit('update', field, value);
    },
  },
  I18N,
};
</script>
<template>
  <div>
    <gl-form-group
      :label="$options.I18N.FORM_FIELD_NAME_LABEL"
      label-for="custom-stage-name"
      :state="hasFieldErrors('name')"
      :invalid-feedback="fieldErrorMessage('name')"
      data-testid="custom-stage-name"
    >
      <gl-form-input
        :value="fields.name"
        class="form-control"
        type="text"
        name="custom-stage-name"
        :placeholder="$options.I18N.FORM_FIELD_NAME_PLACEHOLDER"
        required
        @input="handleUpdateField('name', $event)"
      />
    </gl-form-group>
    <div class="d-flex" :class="{ 'gl-justify-content-between': startEventRequiresLabel }">
      <div :class="eventFieldClasses(startEventRequiresLabel)">
        <gl-form-group
          data-testid="custom-stage-start-event"
          :label="$options.I18N.FORM_FIELD_START_EVENT"
          label-for="custom-stage-start-event"
          :state="hasFieldErrors('startEventIdentifier')"
          :invalid-feedback="fieldErrorMessage('startEventIdentifier')"
        >
          <gl-form-select
            v-model="fields.startEventIdentifier"
            name="custom-stage-start-event"
            :required="true"
            :options="startEvents"
            @input="handleUpdateField('startEventIdentifier', $event)"
          />
        </gl-form-group>
      </div>
      <div v-if="startEventRequiresLabel" class="gl-w-half gl-ml-2">
        <gl-form-group
          data-testid="custom-stage-start-event-label"
          :label="$options.I18N.FORM_FIELD_START_EVENT_LABEL"
          label-for="custom-stage-start-event-label"
          :state="hasFieldErrors('startEventLabelId')"
          :invalid-feedback="fieldErrorMessage('startEventLabelId')"
        >
          <labels-selector
            :selected-label-id="[fields.startEventLabelId]"
            name="custom-stage-start-event-label"
            @selectLabel="handleUpdateField('startEventLabelId', $event)"
          />
        </gl-form-group>
      </div>
    </div>
    <div class="d-flex" :class="{ 'gl-justify-content-between': endEventRequiresLabel }">
      <div :class="eventFieldClasses(endEventRequiresLabel)">
        <gl-form-group
          data-testid="custom-stage-end-event"
          :label="$options.I18N.FORM_FIELD_END_EVENT"
          label-for="custom-stage-end-event"
          :state="hasFieldErrors('endEventIdentifier')"
          :invalid-feedback="fieldErrorMessage('endEventIdentifier')"
        >
          <gl-form-select
            v-model="fields.endEventIdentifier"
            name="custom-stage-end-event"
            :options="endEvents"
            :required="true"
            :disabled="!hasStartEvent"
            @input="handleUpdateField('endEventIdentifier', $event)"
          />
        </gl-form-group>
      </div>
      <div v-if="endEventRequiresLabel" class="gl-w-half gl-ml-2">
        <gl-form-group
          data-testid="custom-stage-end-event-label"
          :label="$options.I18N.FORM_FIELD_END_EVENT_LABEL"
          label-for="custom-stage-end-event-label"
          :state="hasFieldErrors('endEventLabelId')"
          :invalid-feedback="fieldErrorMessage('endEventLabelId')"
        >
          <labels-selector
            :selected-label-id="[fields.endEventLabelId]"
            name="custom-stage-end-event-label"
            @selectLabel="handleUpdateField('endEventLabelId', $event)"
          />
        </gl-form-group>
      </div>
    </div>
  </div>
</template>
