<script>
import RotationAssignee from 'ee/oncall_schedules/components/rotations/components/rotation_assignee.vue';
import { DAYS_IN_WEEK, ASSIGNEE_SPACER, HOURS_IN_DAY } from 'ee/oncall_schedules/constants';
import { getOverlapDateInPeriods, nDaysAfter } from '~/lib/utils/datetime_utility';
import { daysUntilEndOfTimeFrame, weekShiftShouldRender } from './shift_utils';

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
      required: false,
      default: () => ({}),
    },
  },
  computed: {
    currentTimeFrameEnd() {
      return nDaysAfter(this.timeframeEndsAt, DAYS_IN_WEEK);
    },
    daysUntilEndOfTimeFrame() {
      return daysUntilEndOfTimeFrame(
        this.totalShiftRangeOverlap,
        this.timeframeItem,
        this.presetType,
      );
    },
    rotationAssigneeStyle() {
      return {
        left: `${this.shiftLeft}px`,
        width: `${this.shiftWidth}px`,
      };
    },
    shiftLeft() {
      const startDate = this.shiftStartsAt.getDate();
      const firstDayOfWeek = this.timeframeItem.getDate();
      const shiftStartsEarly = startDate === firstDayOfWeek || this.shiftStartDateOutOfRange;
      const dayOffSet = (DAYS_IN_WEEK - this.daysUntilEndOfTimeFrame) * this.shiftTimeUnitWidth;

      if (this.shiftUnitIsHour) {
        const hourOffset =
          (this.shiftTimeUnitWidth / HOURS_IN_DAY) *
          new Date(this.totalShiftRangeOverlap.overlapStartDate).getHours();
        if (shiftStartsEarly) {
          return 0 + hourOffset;
        }
        return dayOffSet + hourOffset;
      }

      if (shiftStartsEarly) {
        return 0;
      }

      return dayOffSet + ASSIGNEE_SPACER;
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
    shiftShouldRender() {
      return weekShiftShouldRender(
        this.totalShiftRangeOverlap,
        this.timeframeIndex,
        this.shiftStartsAt,
        this.timeframeItem,
      );
    },
    shiftWidth() {
      if (this.shiftUnitIsHour) {
        return (
          (this.shiftTimeUnitWidth / HOURS_IN_DAY) * this.totalShiftRangeOverlap.hoursOverlap -
          ASSIGNEE_SPACER
        );
      }

      return this.shiftTimeUnitWidth * this.totalShiftRangeOverlap.daysOverlap - ASSIGNEE_SPACER;
    },
    shiftUnitIsHour() {
      return (
        this.totalShiftRangeOverlap.hoursOverlap < HOURS_IN_DAY &&
        this.rotationLength?.lengthUnit === 'HOURS'
      );
    },
    timeframeIndex() {
      return this.timeframe.indexOf(this.timeframeItem);
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
        return { daysOverlap: 0 };
      }
    },
  },
};
</script>

<template>
  <rotation-assignee
    v-if="shiftShouldRender"
    :assignee="shift.participant"
    :rotation-assignee-style="rotationAssigneeStyle"
    :rotation-assignee-starts-at="shift.startsAt"
    :rotation-assignee-ends-at="shift.endsAt"
    :shift-width="shiftWidth"
  />
</template>
