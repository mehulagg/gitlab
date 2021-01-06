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
    shiftStartsAt() {
      return new Date(this.shift.startsAt);
    },
    shiftEndsAt() {
      return new Date(this.shift.endsAt);
    },
    timeframeEndsAt() {
      let UnitOfIncrement = 0;
      if (this.presetType === PRESET_TYPES.WEEKS) {
        UnitOfIncrement = DAYS_IN_WEEK;
      }

      return new Date(new Date().setDate(this.timeframeItem.getDate() + UnitOfIncrement));
    },
    shiftStartDateOutOfRange() {
      return this.shiftStartsAt.getTime() < this.timeframeItem.getTime();
    },
    shiftShouldRender() {
      return Boolean(this.shiftRangeOverlap.overlap);
    },
    shiftRangeOverlap() {
      try {
        return getOverlappingDaysInPeriods(
          { start: this.timeframeItem, end: this.timeframeEndsAt },
          { start: this.shiftStartsAt, end: this.shiftEndsAt },
        );
      } catch (error) {
        // TODO: We need to decide the UX implications of a invalid date creation.
        return { overlap: 0 };
      }
    },
    rotationAssigneeStyle() {
      const startDate = this.shiftStartsAt.getDay() + 1;
      const firstDayOfWeek = this.timeframeItem.getDay() + 1;
      const isFirstCell = startDate === firstDayOfWeek;
      const daysUntilEndOfTimeFrame =
        new Date(this.timeframeEndsAt).getDate() -
        new Date(this.shiftRangeOverlap.overlapStartDate).getDate();

      const left =
        isFirstCell || this.shiftStartDateOutOfRange
          ? '0px'
          : `${(DAYS_IN_WEEK - daysUntilEndOfTimeFrame) * this.shiftTimeUnitWidth}px`;
      const width = `${this.shiftTimeUnitWidth * this.shiftRangeOverlap.overlap}px`;

      return {
        left,
        width,
      };
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
