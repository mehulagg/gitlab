<script>
import CurrentDayIndicator from './current_day_indicator.vue';

export default {
  components: {
    CurrentDayIndicator,
  },
  props: {
    presetType: {
      type: String,
      required: true,
    },
    rotations: {
      type: Array,
      required: true,
    },
    timeframe: {
      type: Array,
      required: true,
    },
  },
};
</script>

<template>
  <div class="list-section">
    <div class="list-item list-item-empty clearfix">
      <span class="details-cell"></span>
      <span
        v-for="(timeframeItem, index) in timeframe"
        :key="index"
        class="timeline-cell"
        data-testid="timelineCell"
      >
        <current-day-indicator :preset-type="presetType" :timeframe-item="timeframeItem" />
      </span>
    </div>
  </div>
</template>
