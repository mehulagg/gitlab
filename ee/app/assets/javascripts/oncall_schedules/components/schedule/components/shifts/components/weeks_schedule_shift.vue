<script>
import RotationAssignee from 'ee/oncall_schedules/components/rotations/components/rotation_assignee.vue';
import { DAYS_IN_WEEK, HOURS_IN_DAY } from 'ee/oncall_schedules/constants';
import { getOverlapDateInPeriods, nDaysAfter } from '~/lib/utils/datetime_utility';
import { weekDisplayShiftLeft, getPixelWidth } from './shift_utils';

export default {
  components: {
    RotationAssignee,
  },
  props: {
    shift: {
      type: Object,
      required: true,
    },
    shiftIndex: {
      type: Number,
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
    presetType: {
      type: String,
      required: true,
    },
    shiftTimeUnitWidth: {
      type: Number,
      required: true,
    },
    rotationLength: {
      type: Object,
      required: true,
    },
    timelineWidth: {
      type: Number,
      required: true,
    },
  },
  computed: {
    currentTimeFrameEnd() {
      return nDaysAfter(this.timeframeEndsAt, DAYS_IN_WEEK);
    },
    shiftStyles() {
      const {
        shiftUnitIsHour,
        totalShiftRangeOverlap,
        shiftStartDateOutOfRange,
        shiftTimeUnitWidth,
        shiftStartsAt,
        timeframeItem,
        presetType,
        timelineWidth,
        shift,
      } = this;

      return {
        left: weekDisplayShiftLeft(
          shiftUnitIsHour,
          totalShiftRangeOverlap,
          shiftStartDateOutOfRange,
          shiftTimeUnitWidth,
          shiftStartsAt,
          timeframeItem,
          presetType,
        ),
        width: Math.round(
          getPixelWidth({
            shift,
            timelineWidth,
            presetType,
            shiftDLSOffset:
              new Date(shift.startsAt).getTimezoneOffset() -
              new Date(shift.endsAt).getTimezoneOffset(),
          }),
        ),
      };
    },
    rotationAssigneeStyle() {
      const { left, width } = this.shiftStyles;
      return {
        left: `${left}px`,
        width: `${width}px`,
      };
    },
    shiftStartsAt() {
      return new Date(this.shift.startsAt);
    },
    shiftEndsAt() {
      return new Date(this.shift.endsAt);
    },
    shiftStartDateOutOfRange() {
      return this.shiftStartsAt.getTime() < this.timeframeItem.getTime();
    },
    shiftUnitIsHour() {
      return (
        this.totalShiftRangeOverlap.hoursOverlap <= HOURS_IN_DAY &&
        this.rotationLength?.lengthUnit === 'HOURS'
      );
    },
    timeframeEndsAt() {
      return this.timeframe[this.timeframe.length - 1];
    },
    totalShiftRangeOverlap() {
      try {
        return getOverlapDateInPeriods(
          {
            start: this.timeframeItem,
            end: this.currentTimeFrameEnd,
          },
          { start: this.shiftStartsAt, end: this.shiftEndsAt },
        );
      } catch (error) {
        return { hoursOverlap: 0 };
      }
    },
  },
};
</script>

<template>
  <rotation-assignee
    :assignee="shift.participant"
    :rotation-assignee-style="rotationAssigneeStyle"
    :rotation-assignee-starts-at="shift.startsAt"
    :rotation-assignee-ends-at="shift.endsAt"
    :shift-width="shiftStyles.width"
  />
</template>
