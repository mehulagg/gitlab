<script>
import MilestoneItem from './milestone_item.vue';
import CurrentDayMixin from '../mixins/current_day_mixin';

export default {
  components: {
    MilestoneItem,
  },
  mixins: [CurrentDayMixin],
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
      <!-- todaysIndex and getIndicatorStyles are in CurrentDayMixin -->
      <span
        v-if="index === todaysIndex"
        data-testid="currentDayIndicator"
        :style="getIndicatorStyles(presetType, timeframeItem)"
        class="current-day-indicator position-absolute"
      ></span>
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
