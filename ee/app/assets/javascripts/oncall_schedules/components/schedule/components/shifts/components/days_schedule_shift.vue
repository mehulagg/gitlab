<script>
import RotationAssignee from 'ee/oncall_schedules/components/rotations/components/rotation_assignee.vue';
import { HOURS_IN_DAY, ASSIGNEE_SPACER } from 'ee/oncall_schedules/constants';
import { getOverlapDateInPeriods } from '~/lib/utils/datetime_utility';
import { currentTimeframeEndsAt } from './shift_utils';

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
    timelineWidth: {
      type: Number,
      required: true,
    },
  },
  computed: {
    currentTimeframeEndsAt() {
      return currentTimeframeEndsAt(this.timeframeItem, this.presetType);
    },
    hoursUntilEndOfTimeFrame() {
      return HOURS_IN_DAY - new Date(this.shiftRangeOverlap.overlapStartDate).getHours();
    },
    rotationAssigneeStyle() {
      return {
        left: `${this.shiftLeft}px`,
        width: `${this.shiftWidth}px`,
      };
    },
    shiftEndsAt() {
      return new Date(this.shift.endsAt);
    },
    shiftLeft() {
      const shouldStartAtBeginningOfCell =
        this.shiftStartsAt.getHours() === 0 || this.shiftStartHourOutOfRange;

      return shouldStartAtBeginningOfCell
        ? 0
        : (HOURS_IN_DAY - this.hoursUntilEndOfTimeFrame) * this.timelineWidth;
    },
    shiftRangeOverlap() {
      try {
        return getOverlapDateInPeriods(
          { start: this.timeframeItem, end: this.currentTimeframeEndsAt },
          { start: this.shiftStartsAt, end: this.shiftEndsAt },
        );
      } catch (error) {
        return { hoursOverlap: 0 };
      }
    },
    shiftStartsAt() {
      return new Date(this.shift.startsAt);
    },
    shiftStartHourOutOfRange() {
      return this.shiftStartsAt.getTime() < this.timeframeItem.getTime();
    },
    shiftWidth() {
      const baseWidth =
        this.shiftEndsAt.getTime() >= this.currentTimeframeEndsAt.getTime()
          ? HOURS_IN_DAY
          : this.shiftRangeOverlap.hoursOverlap + this.shiftOffset;
      return this.timelineWidth * baseWidth - ASSIGNEE_SPACER;
    },
    shiftOffset() {
      return (this.shiftStartsAt.getTimezoneOffset() - this.shiftEndsAt.getTimezoneOffset()) / 60;
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
    :shift-width="shiftWidth"
  />
</template>
