<script>
import { GlButton, GlButtonGroup } from '@gitlab/ui';
import { STAGE_SORT_DIRECTION } from './constants';

export default {
  name: 'StageFieldActions',
  components: {
    GlButton,
    GlButtonGroup,
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
  },
  STAGE_SORT_DIRECTION,
};
</script>
<template>
  <div>
    <gl-button-group class="gl-px-2">
      <gl-button
        :data-testid="`stage-action-move-down-${index}`"
        :disabled="isLastActiveStage"
        icon="arrow-down"
        @click="$emit('move', { index, direction: $options.STAGE_SORT_DIRECTION.DOWN })"
      />
      <gl-button
        :data-testid="`stage-action-move-up-${index}`"
        :disabled="isFirstActiveStage"
        icon="arrow-up"
        @click="$emit('move', { index, direction: $options.STAGE_SORT_DIRECTION.UP })"
      />
    </gl-button-group>
    <gl-button
      :data-testid="`stage-action-hide-${index}`"
      icon="archive"
      @click="$emit('hide', index)"
    />
  </div>
</template>
