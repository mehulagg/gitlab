<script>
import { PRESET_TYPES, TIMELINE_CELL_WIDTH } from 'ee/oncall_schedules/constants';
import { formatDate } from '~/lib/utils/datetime_utility';
import DaysHeaderSubItem from './days_header_sub_item.vue';

export default {
  PRESET_TYPES,
  components: {
    DaysHeaderSubItem,
  },
  props: {
    timeframeItem: {
      type: Date,
      required: true,
    },
  },
  computed: {
    timelineHeaderLabel() {
      return formatDate(this.timeframeItem, 'mmmm d, yyyy');
    },
    timelineHeaderStyles() {
      return {
        width: `calc(${100}% - ${TIMELINE_CELL_WIDTH}px)`,
      };
    },
  },
};
</script>

<template>
  <span class="timeline-header-item" :style="timelineHeaderStyles">
    <div class="item-label gl-pl-5 gl-py-4" data-testid="timeline-header-label">
      {{ timelineHeaderLabel }}
    </div>
    <days-header-sub-item :timeframe-item="timeframeItem" />
  </span>
</template>
