<script>
import { GlButton, GlButtonGroup, GlTooltipDirective } from '@gitlab/ui';
import { __ } from '~/locale';
import { STAGE_SORT_DIRECTION } from './constants';

export default {
  name: 'StageFieldActions',
  components: {
    GlButton,
    GlButtonGroup,
  },
  directives: {
    GlTooltip: GlTooltipDirective,
  },
  props: {
    index: {
      type: Number,
      required: true,
    },
    stageCount: {
      type: Number,
      required: true,
    },
    canRemove: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  computed: {
    lastStageIndex() {
      return this.stageCount - 1;
    },
    isFirstActiveStage() {
      return this.index === 0;
    },
    isLastActiveStage() {
      return this.index === this.lastStageIndex;
    },
    hideActionEvent() {
      return this.canRemove ? 'remove' : 'hide';
    },
    hideActionTooltip() {
      return this.canRemove ? __('Remove') : __('Hide');
    },
    hideActionIcon() {
      return this.canRemove ? 'remove' : 'eye-slash';
    },
    hideActionTestId() {
      return `stage-action-${this.canRemove ? 'remove' : 'hide'}-${this.index}`;
    },
  },
  STAGE_SORT_DIRECTION,
};
</script>
<template>
  <div>
    <gl-button-group class="gl-px-2">
      <gl-button
        v-gl-tooltip
        :data-testid="`stage-action-move-down-${index}`"
        :disabled="isLastActiveStage"
        icon="arrow-down"
        :title="__('Move down')"
        @click="$emit('move', { index, direction: $options.STAGE_SORT_DIRECTION.DOWN })"
      />
      <gl-button
        v-gl-tooltip
        :data-testid="`stage-action-move-up-${index}`"
        :disabled="isFirstActiveStage"
        icon="arrow-up"
        :title="__('Move up')"
        @click="$emit('move', { index, direction: $options.STAGE_SORT_DIRECTION.UP })"
      />
    </gl-button-group>
    <gl-button
      v-gl-tooltip
      :title="hideActionTooltip"
      :data-testid="hideActionTestId"
      :icon="hideActionIcon"
      @click="$emit(hideActionEvent, index)"
    />
  </div>
</template>
