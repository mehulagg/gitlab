<script>
import RotationAssignee from 'ee/oncall_schedules/components/rotations/components/rotation_assignee.vue';
import {
  PRESET_TYPES,
  DAYS_IN_WEEK,
  DAYS_IN_DATE_WEEK,
  ASSIGNEE_SPACER,
} from 'ee/oncall_schedules/constants';
import getShiftTimeUnitWidthQuery from 'ee/oncall_schedules/graphql/queries/get_shift_time_unit_width.query.graphql';
import { getOverlappingDaysInPeriods } from '~/lib/utils/datetime_utility';
import { incrementDateByDays } from '../utils';

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
  },
  data() {
    return {
      shiftTimeUnitWidth: 0,
    };
  },
  apollo: {
    shiftTimeUnitWidth: {
      query: getShiftTimeUnitWidthQuery,
    },
  },
  computed: {
    currentTimeframeEndsAt() {
      let UnitOfIncrement = 0;
      if (this.presetType === PRESET_TYPES.WEEKS) {
        UnitOfIncrement = DAYS_IN_DATE_WEEK;
      }

      return incrementDateByDays(this.timeframeItem, UnitOfIncrement);
    },
    daysUntilEndOfTimeFrame() {
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
      const left =
        isFirstCell || this.shiftStartDateOutOfRange
          ? '0px'
          : `${
              (DAYS_IN_WEEK - this.daysUntilEndOfTimeFrame) * this.shiftTimeUnitWidth +
              ASSIGNEE_SPACER
            }px`;
      const width = `${this.shiftTimeUnitWidth * this.shiftWidth}px`;

      return {
        left,
        width,
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
          new Date(this.shiftRangeOverlap.overlapStartDate) > this.timeframeItem &&
          new Date(this.shiftRangeOverlap.overlapStartDate) < this.currentTimeframeEndsAt
        );
      }

      return Boolean(this.shiftRangeOverlap.daysOverlap);
    },
    shiftRangeOverlap() {
      try {
        return getOverlappingDaysInPeriods(
          { start: this.timeframeItem, end: this.currentTimeframeEndsAt },
          { start: this.shiftStartsAt, end: this.shiftEndsAt },
        );
      } catch (error) {
        // TODO: We need to decide the UX implications of a invalid date creation.
        return { daysOverlap: 0 };
      }
    },
    shiftWidth() {
      const offset = this.shiftStartDateOutOfRange ? 0 : 1;
      const baseWidth =
        this.timeFrameIndex === 0
          ? this.totalShiftRangeOverlap.daysOverlap
          : this.shiftRangeOverlap.daysOverlap;

      return baseWidth + offset;
    },
    timeFrameIndex() {
      return this.timeframe.indexOf(this.timeframeItem);
    },
    timeFrameEndsAt() {
      return this.timeframe[this.timeframe.length - 1];
    },
    totalShiftRangeOverlap() {
      return getOverlappingDaysInPeriods(
        {
          start: this.timeframeItem,
          end: incrementDateByDays(this.timeFrameEndsAt, DAYS_IN_DATE_WEEK),
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
