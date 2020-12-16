<script>
import { GlFormInput, GlFormText } from '@gitlab/ui';

export default {
  name: 'DefaultStageFields',
  components: {
    GlFormInput,
    GlFormText,
  },
  props: {
    index: {
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
  },
};
</script>
<template>
  <div class="gl-flex-grow-1">
    <gl-form-input
      v-model.trim="stage.name"
      :name="`create-value-stream-stage-${index}`"
      :placeholder="s__('CreateValueStreamForm|Enter stage name')"
      required
      @input="$emit('input', $event)"
    />
    <div class="gl-display-flex">
      <label class="gl-m-0 gl-vertical-align-middle gl-mr-3">{{ __('Start event: ') }}</label>
      <gl-form-text>{{ stage.startEventIdentifier }}</gl-form-text>
    </div>
    <div v-if="stage.startEventLabel" class="gl-display-flex">
      <label class="gl-m-0 gl-vertical-align-middle gl-mr-3">{{ __('Start event label: ') }}</label>
      <gl-form-text>{{ stage.startEventLabel }}</gl-form-text>
    </div>
    <div class="gl-display-flex">
      <label class="gl-m-0 gl-vertical-align-middle gl-mr-3">{{ __('End event: ') }}</label>
      <gl-form-text>{{ stage.endEventIdentifier }}</gl-form-text>
    </div>
    <div v-if="stage.endEventLabel" class="gl-display-flex">
      <label class="gl-m-0 gl-vertical-align-middle gl-mr-3">{{ __('End event label: ') }}</label>
      <gl-form-text>{{ stage.endEventLabel }}</gl-form-text>
    </div>
  </div>
</template>
