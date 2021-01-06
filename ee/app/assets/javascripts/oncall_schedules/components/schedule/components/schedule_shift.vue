<script>
import RotationAssignee from 'ee/oncall_schedules/components/rotations/components/rotation_assignee.vue';
import { PRESET_TYPES, DAYS_IN_WEEK } from 'ee/oncall_schedules/constants';
import getShiftTimeUnitWidthQuery from 'ee/oncall_schedules/graphql/queries/get_shift_time_unit_width.query.graphql';
import { getOverlappingDaysInIntervals } from '~/lib/utils/datetime_utility';

export default {
  components: {
    RotationAssignee,
  },
  props: {
    shift: {
      type: Object,
      required: false,
      default: () => ({}),
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

      return new Date(
        new Date().setDate(this.timeframeItem.getDate() + UnitOfIncrement),
      );
    },
    shiftStartDateOutOfRange() {
      return this.shiftStartsAt.getTime() < this.timeframeItem.getTime();
    },
    shiftShouldRender() {
      return (Boolean(this.timeframeItem <= this.shiftEndsAt && (this.shiftStartsAt <= this.timeframeEndsAt)));
    },
    shiftRangeOverlap() {
      return getOverlappingDaysInIntervals({start: this.timeframeItem, end: this.timeframeEndsAt}, { start: this.shiftStartsAt, end: this.shiftEndsAt});
    },
    rotationAssigneeStyle() {
      const startDate = this.shiftStartsAt.getDay() + 1;
      const firstDayOfWeek = this.timeframeItem.getDay() + 1;

      /* eslint-disable-next-line @gitlab/require-i18n-strings */
      const left =  (startDate === firstDayOfWeek || this.shiftStartDateOutOfRange) ? '0px' : `${startDate * this.shiftTimeUnitWidth - this.shiftTimeUnitWidth / 2}px`;
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
