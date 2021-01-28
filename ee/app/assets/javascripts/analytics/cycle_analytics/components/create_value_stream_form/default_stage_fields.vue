<script>
import { GlFormGroup, GlFormInput, GlFormText } from '@gitlab/ui';
import StageFieldActions from './stage_field_actions.vue';
import { I18N } from './constants';

const findStageEvent = (stageEvents = [], eid = null) => {
  if (!eid) return '';
  return stageEvents.find(({ identifier }) => identifier === eid);
};

const eventIdsToName = (stageEvents = [], eventIds = []) =>
  eventIds
    .map((eid) => {
      const stage = findStageEvent(stageEvents, eid);
      return stage?.name || '';
    })
    .join(', ');

export default {
  name: 'DefaultStageFields',
  components: {
    StageFieldActions,
    GlFormGroup,
    GlFormInput,
    GlFormText,
  },
  props: {
    index: {
      type: Number,
      required: true,
    },
    totalStages: {
      type: Number,
      required: true,
    },
    stage: {
      type: Object,
      required: true,
    },
    errors: {
      type: Object,
      required: false,
      default: () => {},
    },
    stageEvents: {
      type: Array,
      required: true,
    },
  },
  methods: {
    isValid(field) {
      return !this.errors[field]?.length;
    },
    renderError(field) {
      return this.errors[field]?.join('\n');
    },
    eventName(eventIds = []) {
      return eventIdsToName(this.stageEvents, eventIds);
    },
  },
  I18N,
};
</script>
<template>
  <div class="gl-mb-4">
    <div class="gl-display-flex">
      <gl-form-group
        class="gl-flex-grow-1 gl-mb-0"
        :state="isValid('name')"
        :invalid-feedback="renderError('name')"
      >
        <!-- eslint-disable vue/no-mutating-props -->
        <gl-form-input
          v-model.trim="stage.name"
          :name="`create-value-stream-stage-${index}`"
          :placeholder="$options.I18N.FORM_FIELD_STAGE_NAME_PLACEHOLDER"
          required
          @input="$emit('input', $event)"
        />
        <!-- eslint-enable vue/no-mutating-props -->
      </gl-form-group>
      <stage-field-actions
        :index="index"
        :stage-count="totalStages"
        @move="$emit('move', $event)"
        @hide="$emit('hide', $event)"
      />
    </div>
    <div class="gl-display-flex gl-align-items-center" :data-testid="`stage-start-event-${index}`">
      <span class="gl-m-0 gl-vertical-align-middle gl-mr-2 gl-font-weight-bold">{{
        $options.I18N.DEFAULT_FIELD_START_EVENT_LABEL
      }}</span>
      <gl-form-text class="gl-m-0">{{ eventName(stage.startEventIdentifier) }}</gl-form-text>
      <gl-form-text v-if="stage.startEventLabel" class="gl-m-0"
        >&nbsp;-&nbsp;{{ stage.startEventLabel }}</gl-form-text
      >
    </div>
    <div class="gl-display-flex gl-align-items-center" :data-testid="`stage-end-event-${index}`">
      <span class="gl-m-0 gl-vertical-align-middle gl-mr-2 gl-font-weight-bold">{{
        $options.I18N.DEFAULT_FIELD_END_EVENT_LABEL
      }}</span>
      <gl-form-text class="gl-m-0">{{ eventName(stage.endEventIdentifier) }}</gl-form-text>
      <gl-form-text v-if="stage.endEventLabel" class="gl-m-0"
        >&nbsp;-&nbsp;{{ stage.endEventLabel }}</gl-form-text
      >
    </div>
  </div>
</template>
