<script>
export default {
  name: 'ValueStreamFormCustomStage',
  props: {
    name: {
      type: String,
      required: true,
    },
    totalStages: {
      type: Number,
      require: true,
    },
    index: {
      type: Number,
      required: true,
    },
    custom: {
      type: Boolean,
      required: false,
      default: false,
    },
    hidden: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  methods: {
    
  }
};
</script>
<template>
  <gl-form-group
    v-if="!hidden"
    :label="sprintf(__('Stage %{index}'), { index: activeStageIndex + 1 })"
  >
    <div class="gl-display-flex gl-flex-direction-row gl-justify-content-space-between">
      <div>
        <gl-form-input
          v-if="custom"
          v-model.trim="name"
          :name="`create-value-stream-stage-${i}`"
          :placeholder="s__('CreateValueStreamForm|Enter stage name')"
          :state="isValid"
          required
          @input="onHandleInput"
        />
        <span v-else>{{ name }}</span>
      </div>
      <div>
        <gl-button-group>
          <gl-button
            :disabled="isLastActiveStage(index)"
            icon="arrow-down"
            @click="$emit('move', { index, direction: $options.DIRECTION.DOWN })"
          />
          <gl-button
            :disabled="isFirstActiveStage(index)"
            icon="arrow-up"
            @click="$emit('move', { index, direction: $options.DIRECTION.UP })"
          />
        </gl-button-group>
        &nbsp;
        <gl-button icon="archive" @click="onSetHidden(index)" />
      </div>
    </div>
  </gl-form-group>
</template>
