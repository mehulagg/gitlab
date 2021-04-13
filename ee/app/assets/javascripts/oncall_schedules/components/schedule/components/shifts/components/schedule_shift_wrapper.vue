<script>
import { SHIFT_WIDTH_CALCULATION_DELAY } from 'ee/oncall_schedules/constants';
import getTimelineWidthQuery from 'ee/oncall_schedules/graphql/queries/get_timeline_width.query.graphql';
import ShiftItem from './shift_item.vue';

export default {
  components: {
    ShiftItem,
  },
  props: {
    presetType: {
      type: String,
      required: true,
    },
    rotation: {
      type: Object,
      required: true,
    },
    timeframe: {
      type: Array,
      required: true,
    },
  },
  data() {
    return {
      timelineWidth: 0,
    };
  },
  apollo: {
    timelineWidth: {
      query: getTimelineWidthQuery,
      debounce: SHIFT_WIDTH_CALCULATION_DELAY,
    },
  },
  computed: {
    shiftsToRender() {
      return Object.freeze(this.rotation.shifts.nodes);
    },
  },
};
</script>

<template>
  <div>
    <shift-item
      v-for="shift in shiftsToRender"
      :key="shift.startAt"
      :shift="shift"
      :preset-type="presetType"
      :timeframe="timeframe"
      :timeline-width="timelineWidth"
    />
  </div>
</template>
