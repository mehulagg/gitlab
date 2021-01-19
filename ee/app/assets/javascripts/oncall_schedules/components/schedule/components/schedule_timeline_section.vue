<script>
import { PRESET_TYPES } from 'ee/oncall_schedules/constants';
import DaysHeaderItem from './preset_days/days_header_item.vue';
import WeeksHeaderItem from './preset_weeks/weeks_header_item.vue';

export default {
  PRESET_TYPES,
  components: {
    DaysHeaderItem,
    WeeksHeaderItem,
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
  <div class="timeline-section clearfix">
    <span class="timeline-header-blank"></span>
    <div v-if="presetType === $options.PRESET_TYPES.DAYS">
      <days-header-item :timeframe-item="timeframe[0]" />
    </div>
    <div v-else>
      <weeks-header-item
        v-for="(timeframeItem, index) in timeframe"
        :key="index"
        :timeframe-index="index"
        :timeframe-item="timeframeItem"
        :timeframe="timeframe"
        :preset-type="presetType"
      />
    </div>
  </div>
</template>
