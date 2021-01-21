<script>
import CommonMixin from '../../../mixins/common_mixin';

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
};
</script>

<template>
  <span
    v-if="hasToday"
    :style="getIndicatorStyles()"
    data-testid="current-day-indicator"
    class="current-day-indicator"
  ></span>
</template>
