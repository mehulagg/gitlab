<script>
import RotationAssignee from 'ee/oncall_schedules/components/rotations/components/rotation_assignee.vue';
import { HOURS_IN_DAY, ASSIGNEE_SPACER } from 'ee/oncall_schedules/constants';
import { getOverlapDateInPeriods } from '~/lib/utils/datetime_utility';
import { incrementDateByDays } from '../../../utils';

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
      return incrementDateByDays(this.timeframeItem, 1);
    },
    hoursUntilEndOfTimeFrame() {
      return HOURS_IN_DAY - new Date(this.shiftRangeOverlap.overlapStartDate).getHours();
    },
    rotationAssigneeStyle() {
      const startHour = this.shiftStartsAt.getHours();
      const isFirstCell = startHour === 0;
      const shouldStartAtBeginningOfCell = isFirstCell || this.shiftStartHourOutOfRange;
      const widthOffset = shouldStartAtBeginningOfCell ? 0 : 1;
      const width =
        this.shiftEndsAt.getTime() > this.currentTimeframeEndsAt.getTime()
          ? HOURS_IN_DAY
          : this.shiftRangeOverlap.hoursOverlap + widthOffset;

      const left = shouldStartAtBeginningOfCell
        ? '0px'
        : `${(23 - this.hoursUntilEndOfTimeFrame) * this.shiftTimeUnitWidth + ASSIGNEE_SPACER}px`;

      return {
        left,
        width: `${this.shiftTimeUnitWidth * width}px`,
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
    shiftShouldRender() {
      return Boolean(
        this.shiftRangeOverlap.hoursOverlap &&
          !(this.shiftStartsAt.getDate() > this.timeframeItem.getDate()),
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
