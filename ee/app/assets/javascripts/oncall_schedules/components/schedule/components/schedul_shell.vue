<script>
import scheduleTimelineSection from './schedule_timeline_section.vue';

export default {
  components: {
    scheduleTimelineSection,
  },
  props: {
    presetType: {
      type: String,
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
  <div class="schedule-shell js-schedule-shell">
    <schedule-timeline-section :preset-type="presetType" :timeframe="timeframe" />
  </div>
</template>
