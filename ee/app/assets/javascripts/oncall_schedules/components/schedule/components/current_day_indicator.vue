<script>
import CommonMixin from '../../../mixins/common_mixin';
import { PRESET_TYPES } from '../../../constants';

export default {
  mixins: [CommonMixin],
  props: {
    presetType: {
      type: String,
      required: true,
    },
    timeframeItem: {
      type: [Date, Object],
      required: true,
    },
  },
  computed: {
    isVisible() {
      switch (this.presetType) {
        case PRESET_TYPES.WEEKS:
          return this.hasToday;
        case PRESET_TYPES.DAYS:
          return this.isToday;
        default:
          return false;
      }
    },
  },
};
</script>

<template>
  <span
    v-if="isVisible"
    :style="getIndicatorStyles(presetType)"
    data-testid="current-day-indicator"
    class="current-day-indicator"
  ></span>
</template>
