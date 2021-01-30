<script>
import { PRESET_TYPES, DAYS_IN_DATE_WEEK } from 'ee/oncall_schedules/constants';
import getShiftTimeUnitWidthQuery from 'ee/oncall_schedules/graphql/queries/get_shift_time_unit_width.query.graphql';
import DaysScheduleShift from './days_schedule_shift.vue';
import WeeksScheduleShift from './weeks_schedule_shift.vue';
import { getOverlapDateInPeriods, nDaysAfter } from '~/lib/utils/datetime_utility';

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
  computed: {
    currentTimeframeEndsAt() {
      return new Date(nDaysAfter(this.timeframeItem, this.presetType === PRESET_TYPES.DAYS ? 1 : DAYS_IN_DATE_WEEK));
    },
    shiftsToRender() {
      const validShifts = this.rotation.shifts.nodes.filter(({ startsAt, endsAt }) => this.shiftRangeOverlap(startsAt, endsAt).hoursOverlap > 0);
      // TODO: If week view and on same day, dont show more than 1 assignee or use CSS to limit their size to be readable
      return Object.freeze(validShifts);
    }
  },
  methods: {
    shiftRangeOverlap(shiftStartsAt, shiftEndsAt) {
      return getOverlapDateInPeriods(
        { start: this.timeframeItem, end: this.currentTimeframeEndsAt },
        { start: shiftStartsAt, end: shiftEndsAt },
      );
    },
  }
};
</script>

<template>
  <div v-if="rotation.shifts.nodes">
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
    />
  </div>
</template>
