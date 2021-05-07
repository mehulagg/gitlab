<script>
import CurrentDayIndicator from './current_day_indicator.vue';
import MilestoneItem from './milestone_item.vue';

export default {
  components: {
    MilestoneItem,
    CurrentDayIndicator,
  },
  props: {
    presetType: {
      type: String,
      required: true,
    },
    timeframe: {
      type: Array,
      required: true,
    },
    milestones: {
      type: Array,
      required: true,
    },
    currentGroupId: {
      type: Number,
      required: true,
    },
    milestonesExpanded: {
      type: Boolean,
      required: true,
    },
  },
};
</script>

<template>
  <div>
    <span
      v-for="timeframeItem in timeframe"
      :key="timeframeItem.id"
      class="milestone-timeline-cell gl-display-table-cell gl-relative border-right border-bottom"
      data-qa-selector="milestone_timeline_cell"
    >
      <current-day-indicator :preset-type="presetType" :timeframe-item="timeframeItem" />
      <template v-if="milestonesExpanded">
        <milestone-item
          v-for="milestone in milestones"
          :key="milestone.id"
          :preset-type="presetType"
          :milestone="milestone"
          :timeframe="timeframe"
          :timeframe-item="timeframeItem"
          :current-group-id="currentGroupId"
        />
      </template>
    </span>
  </div>
</template>
