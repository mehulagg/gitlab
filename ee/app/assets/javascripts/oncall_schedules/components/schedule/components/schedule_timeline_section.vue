<script>
import { PRESET_TYPES } from 'ee/oncall_schedules/constants';
import HeaderItem from './preset_weeks/weeks_header_item.vue';

export default {
  components: {
    HeaderItem,
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
  computed: {
    timeframeToDraw() {
      if (this.presetType === PRESET_TYPES.DAYS) {
        return [this.timeframe[0]];
      }

      return this.timeframe;
    },
  },
};
</script>

<template>
  <div class="timeline-section clearfix">
    <span class="timeline-header-blank"></span>
    <header-item
      v-for="(timeframeItem, index) in timeframeToDraw"
      :key="index"
      :timeframe-index="index"
      :timeframe-item="timeframeItem"
      :timeframe="timeframe"
      :preset-type="presetType"
    />
  </div>
</template>
