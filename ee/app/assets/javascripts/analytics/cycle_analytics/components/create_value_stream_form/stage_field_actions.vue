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
    isFirstActiveStage() {
      return this.index === 0;
    },
    isLastActiveStage() {
      return this.index === this.stageCount;
    },
  },
  STAGE_SORT_DIRECTION,
};
</script>
<template>
  <div>
    <!-- TODO: inroduce actions in a separate MR if the diff is too big -->
    <gl-button-group class="gl-px-2">
      <gl-button
        :disabled="isLastActiveStage"
        icon="arrow-down"
        @click="$emit('move', { index, direction: $options.STAGE_SORT_DIRECTION.DOWN })"
      />
      <gl-button
        :disabled="isFirstActiveStage"
        icon="arrow-up"
        @click="$emit('move', { index, direction: $options.STAGE_SORT_DIRECTION.UP })"
      />
    </gl-button-group>
    <gl-button icon="archive" @click="$emit('hide', index)" />
  </div>
</template>
