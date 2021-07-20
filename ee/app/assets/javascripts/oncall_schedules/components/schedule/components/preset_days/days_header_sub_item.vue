<script>
import { PRESET_TYPES, HOURS_IN_DAY } from 'ee/oncall_schedules/constants';
import CommonMixin from 'ee/oncall_schedules/mixins/common_mixin';

export default {
  PRESET_TYPES,
  HOURS_IN_DAY,
  mixins: [CommonMixin],
  props: {
    timeframeItem: {
      type: Date,
      required: true,
    },
  },
};
</script>

<template>
  <div class="item-sublabel" data-testid="day-item-sublabel">
    <span
      v-for="hour in $options.HOURS_IN_DAY"
      :key="hour"
      ref="dailyHourCell"
      class="sublabel-value"
      data-testid="sublabel-value"
      >{{ hour - 1 }}</span
    >
    <span
      v-if="isToday"
      :style="getIndicatorStyles($options.PRESET_TYPES.DAYS)"
      class="current-day-indicator-header preset-days"
      data-testid="day-item-sublabel-current-indicator"
    ></span>
  </div>
</template>
