<script>
import RotationAssignee from 'ee/oncall_schedules/components/rotations/components/rotation_assignee.vue';
import { DAYS_IN_WEEK, DAYS_IN_DATE_WEEK, ASSIGNEE_SPACER } from 'ee/oncall_schedules/constants';
import {
  getOverlapDateInPeriods,
  nDaysAfter,
  getDayDifference,
} from '~/lib/utils/datetime_utility';

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
  },
  computed: {
    currentTimeframeEndsAt() {
      return new Date(nDaysAfter(this.timeframeItem, DAYS_IN_DATE_WEEK));
    },
    daysUntilEndOfTimeFrame() {
      if (
        this.currentTimeframeEndsAt.getMonth() !==
        new Date(this.shiftRangeOverlap.overlapStartDate).getMonth()
      ) {
        return Math.abs(
          getDayDifference(
            this.currentTimeframeEndsAt,
            new Date(this.shiftRangeOverlap.overlapStartDate),
          ),
        );
      }

      return (
        this.currentTimeframeEndsAt.getDate() -
        new Date(this.shiftRangeOverlap.overlapStartDate).getDate() +
        1
      );
    },
    rotationAssigneeStyle() {
      const startDate = this.shiftStartsAt.getDay();
      const firstDayOfWeek = this.timeframeItem.getDay();
      const isFirstCell = startDate === firstDayOfWeek;
      let left = 0;

      if (!(isFirstCell || this.shiftStartDateOutOfRange)) {
        left =
          (DAYS_IN_WEEK - this.daysUntilEndOfTimeFrame) * this.shiftTimeUnitWidth + ASSIGNEE_SPACER;
      }

      const width = this.shiftTimeUnitWidth * this.shiftWidth - ASSIGNEE_SPACER;

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
    shiftShouldRender() {
      if (this.timeFrameIndex !== 0) {
        return (
          (nDaysAfter(this.shiftStartsAt, 1) >= this.timeframeItem ||
            new Date(this.shiftRangeOverlap.overlapStartDate) > this.timeframeItem) &&
          new Date(this.shiftRangeOverlap.overlapStartDate) < this.currentTimeframeEndsAt
        );
      }

      return Boolean(this.shiftRangeOverlap.hoursOverlap);
    },
    shiftRangeOverlap() {
      return getOverlapDateInPeriods(
        { start: this.timeframeItem, end: this.currentTimeframeEndsAt },
        { start: this.shiftStartsAt, end: this.shiftEndsAt },
      );
    },
    shiftWidth() {
      return this.totalShiftRangeOverlap.daysOverlap + 1;
    },
    timeFrameIndex() {
      return this.timeframe.indexOf(this.timeframeItem);
    },
    timeFrameEndsAt() {
      return this.timeframe[this.timeframe.length - 1];
    },
    totalShiftRangeOverlap() {
      return getOverlapDateInPeriods(
        {
          start: this.timeframeItem,
          end: nDaysAfter(this.timeFrameEndsAt, DAYS_IN_DATE_WEEK),
        },
        { start: this.shiftStartsAt, end: this.shiftEndsAt },
      );
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
  />
</template>
