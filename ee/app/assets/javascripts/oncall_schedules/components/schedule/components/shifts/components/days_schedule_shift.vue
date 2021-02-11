<script>
import RotationAssignee from 'ee/oncall_schedules/components/rotations/components/rotation_assignee.vue';
import { HOURS_IN_DAY, HOURS_IN_DATE_DAY, ASSIGNEE_SPACER } from 'ee/oncall_schedules/constants';
import { getOverlapDateInPeriods } from '~/lib/utils/datetime_utility';
import { shiftShouldRender, currentTimeframeEndsAt } from './shift_utils';

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
      return currentTimeframeEndsAt(this.timeframeItem, this.presetType);
    },
    hoursUntilEndOfTimeFrame() {
      return HOURS_IN_DAY - new Date(this.shiftRangeOverlap.overlapStartDate).getHours();
    },
    rotationAssigneeStyle() {
      const shouldStartAtBeginningOfCell =
        this.shiftStartsAt.getHours() === 0 || this.shiftStartHourOutOfRange;
      const baseWidth =
        this.shiftEndsAt.getTime() >= this.currentTimeframeEndsAt.getTime()
          ? HOURS_IN_DAY
          : this.shiftRangeOverlap.hoursOverlap;

      const left = shouldStartAtBeginningOfCell
        ? 0
        : (HOURS_IN_DATE_DAY - this.hoursUntilEndOfTimeFrame) * this.shiftTimeUnitWidth -
          ASSIGNEE_SPACER;

      return {
        left: `${left}px`,
        width: `${this.shiftTimeUnitWidth * baseWidth - ASSIGNEE_SPACER}px`,
      };
    },
    shiftStartsAt() {
      return new Date(this.shift.startsAt);
    },
    shiftEndsAt() {
      return new Date(this.shift.endsAt);
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
    shiftStartHourOutOfRange() {
      return this.shiftStartsAt.getTime() < this.timeframeItem.getTime();
    },
    shouldRender() {
      return shiftShouldRender(this.shiftRangeOverlap);
    },
  },
};
</script>

<template>
  <rotation-assignee
    v-if="shouldRender"
    :assignee="shift.participant"
    :rotation-assignee-style="rotationAssigneeStyle"
    :rotation-assignee-starts-at="shift.startsAt"
    :rotation-assignee-ends-at="shift.endsAt"
  />
</template>
