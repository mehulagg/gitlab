<script>
import RotationAssignee from 'ee/oncall_schedules/components/rotations/components/rotation_assignee.vue';
import { PRESET_TYPES, DAYS_IN_WEEK } from 'ee/oncall_schedules/constants';
import getShiftTimeUnitWidthQuery from 'ee/oncall_schedules/graphql/queries/get_shift_time_unit_width.query.graphql';
import { getOverlappingDaysInPeriods } from '~/lib/utils/datetime_utility';

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
        UnitOfIncrement = DAYS_IN_WEEK - 1;
      }

      return new Date(new Date().setDate(this.timeframeItem.getDate() + UnitOfIncrement));
    },
    daysUntilEndOfTimeFrame() {
      return (
        new Date(this.currentTimeframeEndsAt).getDate() -
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
          : `${(DAYS_IN_WEEK - this.daysUntilEndOfTimeFrame) * this.shiftTimeUnitWidth}px`;
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

      return Boolean(this.shiftRangeOverlap.overlap);
    },
    shiftRangeOverlap() {
      try {
        return getOverlappingDaysInPeriods(
          { start: this.timeframeItem, end: this.currentTimeframeEndsAt },
          { start: this.shiftStartsAt, end: this.shiftEndsAt },
        );
      } catch (error) {
        // TODO: We need to decide the UX implications of a invalid date creation.
        return { overlap: 0 };
      }
    },
    shiftWidth() {
      let offset = 1;

      if (this.shiftStartDateOutOfRange) {
        offset = 0;
      }

      const baseWidth =
        this.timeFrameIndex === 0
          ? this.totalShiftRangeOverlap.overlap
          : this.shiftRangeOverlap.overlap;

      return baseWidth + offset;
    },
    timeFrameIndex() {
      return this.timeframe.indexOf(this.timeframeItem);
    },
    totalShiftRangeOverlap() {
      return getOverlappingDaysInPeriods(
        {
          start: this.timeframeItem,
          end: new Date(
            new Date().setDate(this.timeframe[this.timeframe.length - 1].getDate() + 6),
          ),
        },
        { start: this.shiftStartsAt, end: this.shiftEndsAt },
      );
    },
  },
};
</script>

<template>
  <div v-if="shiftShouldRender">
    <rotation-assignee
      :assignee="shift.participant"
      :rotation-assignee-style="rotationAssigneeStyle"
      :rotation-assignee-starts-at="shift.startsAt"
      :rotation-assignee-ends-at="shift.endsAt"
    />
  </div>
</template>
