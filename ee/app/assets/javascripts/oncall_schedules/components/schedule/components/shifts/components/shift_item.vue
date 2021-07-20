<script>
import RotationAssignee from 'ee/oncall_schedules/components/rotations/components/rotation_assignee.vue';
import { getPixelOffset, getPixelWidth } from './shift_utils';

export default {
  components: {
    RotationAssignee,
  },
  props: {
    shift: {
      type: Object,
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
    shiftStyles() {
      const { timeframe, presetType, timelineWidth, shift } = this;

      return {
        left: getPixelOffset({
          timeframe,
          shift,
          timelineWidth,
          presetType,
        }),
        width: Math.round(
          getPixelWidth({
            shift,
            timelineWidth,
            presetType,
            shiftDLSOffset:
              new Date(shift.startsAt).getTimezoneOffset() -
              new Date(shift.endsAt).getTimezoneOffset(),
          }),
        ),
      };
    },
    rotationAssigneeStyle() {
      const { left, width } = this.shiftStyles;
      return {
        left: `${left}px`,
        width: `${width}px`,
      };
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
    :shift-width="shiftStyles.width"
  />
</template>
