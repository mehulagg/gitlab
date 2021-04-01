<script>
import { PRESET_TYPES, SHIFT_WIDTH_CALCULATION_DELAY } from 'ee/oncall_schedules/constants';
import getShiftTimeUnitWidthQuery from 'ee/oncall_schedules/graphql/queries/get_shift_time_unit_width.query.graphql';
import getTimelineWidthQuery from 'ee/oncall_schedules/graphql/queries/get_timeline_width.query.graphql';
import DaysScheduleShift from './days_schedule_shift.vue';
import { shiftsToRender } from './shift_utils';
import WeeksScheduleShift from './weeks_schedule_shift.vue';

export default {
  components: {
    DaysScheduleShift,
    WeeksScheduleShift,
  },
  props: {
    presetType: {
      type: String,
      required: true,
    },
    rotation: {
      type: Object,
      required: true,
    },
    timeframeItem: {
      type: [Date, Object],
      required: true,
    },
    timeframe: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      shiftTimeUnitWidth: 0,
      componentByPreset: {
        [PRESET_TYPES.DAYS]: DaysScheduleShift,
        [PRESET_TYPES.WEEKS]: WeeksScheduleShift,
      },
      timelineWidth: 0,
    };
  },
  apollo: {
    shiftTimeUnitWidth: {
      query: getShiftTimeUnitWidthQuery,
      debounce: SHIFT_WIDTH_CALCULATION_DELAY,
    },
    timelineWidth: {
      query: getTimelineWidthQuery,
      debounce: SHIFT_WIDTH_CALCULATION_DELAY,
    },
  },
  computed: {
    rotationLength() {
      const { length, lengthUnit } = this.rotation;
      return { length, lengthUnit };
    },
    shiftsToRender() {
      return Object.freeze(
        shiftsToRender(
          this.rotation.shifts.nodes,
          this.timeframeItem,
          this.presetType,
          this.timeframeIndex,
        ),
      );
    },
    timeframeIndex() {
      return this.timeframe.indexOf(this.timeframeItem);
    },
  },
};
</script>

<template>
  <div>
    <component
      :is="componentByPreset[presetType]"
      v-for="(shift, shiftIndex) in shiftsToRender"
      :key="shift.startAt"
      :shift="shift"
      :shift-index="shiftIndex"
      :preset-type="presetType"
      :timeframe-item="timeframeItem"
      :timeframe="timeframe"
      :shift-time-unit-width="shiftTimeUnitWidth"
      :rotation-length="rotationLength"
      :timeline-width="timelineWidth"
    />
  </div>
</template>
