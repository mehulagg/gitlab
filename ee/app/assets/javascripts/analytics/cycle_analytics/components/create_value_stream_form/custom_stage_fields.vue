<script>
import { GlFormGroup, GlFormInput, GlFormSelect } from '@gitlab/ui';
import { s__ } from '~/locale';
import LabelsSelector from '../labels_selector.vue';
import {
  isStartEvent,
  isLabelEvent,
  getAllowedEndEvents,
  eventToOption,
  eventsByIdentifier,
} from '../../utils';

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
    startEventOptions() {
      return [
        { value: null, text: s__('CustomCycleAnalytics|Select start event') },
        ...this.events.filter(isStartEvent).map(eventToOption),
      ];
    },
    endEventOptions() {
      const endEvents = getAllowedEndEvents(this.events, this.fields.startEventIdentifier);
      return [
        { value: null, text: s__('CustomCycleAnalytics|Select end event') },
        ...eventsByIdentifier(this.events, endEvents).map(eventToOption),
      ];
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
    hasFieldErrors(key) {
      return this.errors[key]?.length > 0;
    },
    fieldErrorMessage(key) {
      return this.errors[key]?.join('\n');
    },
    handleUpdateField(field, value) {
      this.$emit('update', field, value);
    },
  },
};
</script>
<template>
  <div>
    <gl-form-group
      :label="s__('CustomCycleAnalytics|Name')"
      label-for="custom-stage-name"
      :state="!hasFieldErrors('name')"
      :invalid-feedback="fieldErrorMessage('name')"
      data-testid="custom-stage-name"
    >
      <gl-form-input
        :value="fields.name"
        class="form-control"
        type="text"
        name="custom-stage-name"
        :placeholder="s__('CustomCycleAnalytics|Enter a name for the stage')"
        required
        @input="handleUpdateField('name', $event)"
      />
    </gl-form-group>
    <div class="d-flex" :class="{ 'justify-content-between': startEventRequiresLabel }">
      <div :class="[startEventRequiresLabel ? 'w-50 mr-1' : 'w-100']">
        <gl-form-group
          data-testid="custom-stage-start-event-identifier"
          :label="s__('CustomCycleAnalytics|Start event')"
          label-for="custom-stage-start-event"
          :state="!hasFieldErrors('startEventIdentifier')"
          :invalid-feedback="fieldErrorMessage('startEventIdentifier')"
        >
          <gl-form-select
            v-model="fields.startEventIdentifier"
            name="custom-stage-start-event"
            :required="true"
            :options="startEventOptions"
            @input="handleUpdateField('startEventIdentifier', $event)"
          />
        </gl-form-group>
      </div>
      <div v-if="startEventRequiresLabel" class="w-50 ml-1">
        <gl-form-group
          data-testid="custom-stage-start-event-label-id"
          :label="s__('CustomCycleAnalytics|Start event label')"
          label-for="custom-stage-start-event-label"
          :state="!hasFieldErrors('startEventLabelId')"
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
    <div class="d-flex" :class="{ 'justify-content-between': endEventRequiresLabel }">
      <div :class="[endEventRequiresLabel ? 'w-50 mr-1' : 'w-100']">
        <gl-form-group
          data-testid="custom-stage-end-event-identifier"
          :label="s__('CustomCycleAnalytics|End event')"
          label-for="custom-stage-end-event"
          :state="!hasFieldErrors('endEventIdentifier')"
          :invalid-feedback="fieldErrorMessage('endEventIdentifier')"
        >
          <gl-form-select
            v-model="fields.endEventIdentifier"
            name="custom-stage-end-event"
            :options="endEventOptions"
            :required="true"
            :disabled="!hasStartEvent"
            @input="handleUpdateField('endEventIdentifier', $event)"
          />
        </gl-form-group>
      </div>
      <div v-if="endEventRequiresLabel" class="w-50 ml-1">
        <gl-form-group
          data-testid="custom-stage-end-event-label-id"
          :label="s__('CustomCycleAnalytics|End event label')"
          label-for="custom-stage-end-event-label"
          :state="!hasFieldErrors('endEventLabelId')"
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
