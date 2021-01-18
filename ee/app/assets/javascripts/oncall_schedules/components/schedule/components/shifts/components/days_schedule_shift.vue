<script>
import RotationAssignee from 'ee/oncall_schedules/components/rotations/components/rotation_assignee.vue';
import { DAYS_IN_WEEK, ASSIGNEE_SPACER } from 'ee/oncall_schedules/constants';

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
    rotationAssigneeStyle() {
      return {
        left: `0px`,
        width: `0px`,
      };
    },
    shiftShouldRender() {
      return true;
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
