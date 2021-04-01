<script>
import { SHIFT_WIDTH_CALCULATION_DELAY } from 'ee/oncall_schedules/constants';
import getShiftTimeUnitWidthQuery from 'ee/oncall_schedules/graphql/queries/get_shift_time_unit_width.query.graphql';
import getTimelineWidthQuery from 'ee/oncall_schedules/graphql/queries/get_timeline_width.query.graphql';
import ShiftItem from './shift_item.vue';

export default {
  components: {
    ShiftItem,
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
      return Object.freeze(this.rotation.shifts.nodes);
    },
  },
};
</script>

<template>
  <div>
    <shift-item
      v-for="shift in shiftsToRender"
      :key="shift.startAt"
      :shift="shift"
      :preset-type="presetType"
      :timeframe-item="timeframeItem"
      :timeframe="timeframe"
      :shift-time-unit-width="shiftTimeUnitWidth"
      :rotation-length="rotationLength"
      :timeline-width="timelineWidth"
    />
  </div>
</template>
