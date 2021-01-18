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
      components: [
        {
          name: PRESET_TYPES.DAYS,
          component: DaysScheduleShift,
        },
        {
          name: PRESET_TYPES.WEEKS,
          component: WeeksScheduleShift,
        },
      ],
    };
  },
  computed: {
    currentComponent() {
      return this.components.find(({ name }) => name === this.presetType).component;
    },
  },
  apollo: {
    shiftTimeUnitWidth: {
      query: getShiftTimeUnitWidthQuery,
    },
  },
};
</script>

<template>
  <div v-if="currentComponent">
    <component
      :is="currentComponent"
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
  <div v-else>
    {{ s__('OncallSchedule|This type of timeline view is not currently available.') }}
  </div>
</template>
