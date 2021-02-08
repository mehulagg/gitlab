<script>
import { PRESET_TYPES } from 'ee/oncall_schedules/constants';
import getShiftTimeUnitWidthQuery from 'ee/oncall_schedules/graphql/queries/get_shift_time_unit_width.query.graphql';
import DaysScheduleShift from './days_schedule_shift.vue';
import WeeksScheduleShift from './weeks_schedule_shift.vue';

export default {
  components: {
    DaysScheduleShift,
    WeeksScheduleShift,
  },
  props: {
    timeframeItem: {
      type: [Date, Object],
      required: true,
    },
    timeframe: {
      type: Array,
      required: true,
    },
    presetType: {
      type: String,
      required: true,
    },
    rotation: {
      type: Object,
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
    };
  },
  apollo: {
    shiftTimeUnitWidth: {
      query: getShiftTimeUnitWidthQuery,
    },
  },
};
</script>

<template>
  <div>
    <component
      :is="componentByPreset[presetType]"
      v-for="(shift, shiftIndex) in rotation.shifts.nodes"
      :key="shift.startAt"
      :shift="shift"
      :shift-index="shiftIndex"
      :preset-type="presetType"
      :timeframe-item="timeframeItem"
      :timeframe="timeframe"
      :shift-time-unit-width="shiftTimeUnitWidth"
    />
  </div>
</template>
