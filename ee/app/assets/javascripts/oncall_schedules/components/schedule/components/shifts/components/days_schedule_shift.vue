<script>
import RotationAssignee from 'ee/oncall_schedules/components/rotations/components/rotation_assignee.vue';
import { HOURS_IN_DAY, HOURS_IN_DATE_DAY, ASSIGNEE_SPACER } from 'ee/oncall_schedules/constants';
import { getOverlapDateInPeriods, nDaysAfter } from '~/lib/utils/datetime_utility';

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
      return new Date(nDaysAfter(this.timeframeItem, 1));
    },
    hoursUntilEndOfTimeFrame() {
      return HOURS_IN_DAY - new Date(this.shiftRangeOverlap.overlapStartDate).getHours();
    },
    rotationAssigneeStyle() {
      const startHour = this.shiftStartsAt.getHours();
      const isFirstCell = startHour === 0;
      const shouldStartAtBeginningOfCell = isFirstCell || this.shiftStartHourOutOfRange;
      const width =
        this.shiftEndsAt.getTime() >= this.currentTimeframeEndsAt.getTime()
          ? HOURS_IN_DAY
          : this.shiftRangeOverlap.hoursOverlap;

      const left = shouldStartAtBeginningOfCell
        ? '0px'
        : `${
            (HOURS_IN_DATE_DAY - this.hoursUntilEndOfTimeFrame) * this.shiftTimeUnitWidth +
            ASSIGNEE_SPACER
          }px`;

      return {
        left,
        width: `${this.shiftTimeUnitWidth * width - ASSIGNEE_SPACER}px`,
      };
    },
    shiftStartsAt() {
      return new Date(this.shift.startsAt);
    },
    shiftEndsAt() {
      return new Date(this.shift.endsAt);
    },
    shiftRangeOverlap() {
      return getOverlapDateInPeriods(
        { start: this.timeframeItem, end: this.currentTimeframeEndsAt },
        { start: this.shiftStartsAt, end: this.shiftEndsAt },
      );
    },
    shiftStartHourOutOfRange() {
      return this.shiftStartsAt.getTime() < this.timeframeItem.getTime();
    },
    shiftShouldRender() {
      return Boolean(this.shiftRangeOverlap.hoursOverlap);
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
