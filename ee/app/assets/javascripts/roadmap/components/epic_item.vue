<script>
import { delay } from 'lodash';

import EpicItemDetails from './epic_item_details.vue';
import EpicItemTimeline from './epic_item_timeline.vue';

import CommonMixin from '../mixins/common_mixin';

import {
  EPIC_HIGHLIGHT_REMOVE_AFTER,
  EPIC_ITEM_HEIGHT,
  TIMELINE_CELL_MIN_WIDTH,
  GRID_COLOR,
} from '../constants';

export default {
  components: {
    EpicItemDetails,
    EpicItemTimeline,
  },
  mixins: [CommonMixin],
  props: {
    presetType: {
      type: String,
      required: true,
    },
    epic: {
      type: Object,
      required: true,
    },
    timeframe: {
      type: Array,
      required: true,
    },
    currentGroupId: {
      type: Number,
      required: true,
    },
    clientWidth: {
      type: Number,
      required: false,
      default: 0,
    },
    childLevel: {
      type: Number,
      required: true,
    },
    childrenEpics: {
      type: Object,
      required: true,
    },
    childrenFlags: {
      type: Object,
      required: true,
    },
    hasFiltersApplied: {
      type: Boolean,
      required: true,
    },
  },
  computed: {
    /**
     * In case Epic start date is out of range
     * we need to use original date instead of proxy date
     */
    startDate() {
      if (this.epic.startDateOutOfRange) {
        return this.epic.originalStartDate;
      }

      return this.epic.startDate;
    },
    /**
     * In case Epic end date is out of range
     * we need to use original date instead of proxy date
     */
    endDate() {
      if (this.epic.endDateOutOfRange) {
        return this.epic.originalEndDate;
      }
      return this.epic.endDate;
    },
    isChildrenEmpty() {
      return this.childrenEpics[this.epic.id] && this.childrenEpics[this.epic.id].length === 0;
    },
    hasChildrenToShow() {
      return this.childrenFlags[this.epic.id].itemExpanded && this.childrenEpics[this.epic.id];
    },
    canvasWidth() {
      return `${this.timeframe.length * 180}px`;
    }
  },
  mounted() {
    console.log('clientWidth:', this.clientWidth, ' timeframe.length:', this.timeframe.length);
    this.updateCanvas();
  },
  watch: {
    timeframe: 'updateCanvas',
  },
  updated() {
    this.removeHighlight();
  },
  methods: {
    updateCanvas() {
      const canvas = this.$refs.canvas;
      const ctx = canvas.getContext('2d');
      ctx.strokeStyle = GRID_COLOR;
      ctx.lineWidth = 1;

      this.timeframe
        .map((_, i) => i * TIMELINE_CELL_MIN_WIDTH - 0.5)
        .forEach(x => {
          ctx.moveTo(x, 0);
          ctx.lineTo(x, EPIC_ITEM_HEIGHT);
        });

      // TODO port(draw) current_day_indicator

      ctx.stroke();
    },
    /**
     * When new epics are added to the list on
     * timeline scroll, we set `newEpic` flag
     * as true and then use it in template
     * to set `newly-added-epic` class for
     * highlighting epic using CSS animations
     *
     * Once animation is complete, we need to
     * remove the flag so that animation is not
     * replayed when list is re-rendered.
     */
    removeHighlight() {
      if (this.epic.newEpic) {
        this.$nextTick(() => {
          delay(() => {
            this.epic.newEpic = false;
          }, EPIC_HIGHLIGHT_REMOVE_AFTER);
        });
      }
    },
  },
};
</script>

<template>
  <div class="epic-item-container">
    <div :class="{ 'newly-added-epic': epic.newEpic }" class="epics-list-item clearfix">
      <epic-item-details
        :epic="epic"
        :current-group-id="currentGroupId"
        :timeframe-string="timeframeString(epic)"
        :child-level="childLevel"
        :children-flags="childrenFlags"
        :has-filters-applied="hasFiltersApplied"
        :is-children-empty="isChildrenEmpty"
      />
      <!-- TODO implement hover -->
      <canvas
        ref="canvas"
        height="49px"
        :width="canvasWidth"
        class="gl-display-block gl-border-1 gl-border-b-solid gl-border-gray-100 gl-position-relative"
        ></canvas>
      <!-- TODO implement current-day-indicator  -->
      <!-- <current-day-indicator :preset-type="presetType" :timeframe-item="timeframeItem" /> -->
      <epic-item-timeline
        :preset-type="presetType"
        :timeframe="timeframe"
        :epic="epic"
        :client-width="clientWidth"
      />
    </div>
    <epic-item-container
      v-if="hasChildrenToShow"
      :preset-type="presetType"
      :timeframe="timeframe"
      :current-group-id="currentGroupId"
      :client-width="clientWidth"
      :children="childrenEpics[epic.id] || []"
      :child-level="childLevel + 1"
      :children-epics="childrenEpics"
      :children-flags="childrenFlags"
      :has-filters-applied="hasFiltersApplied"
    />
  </div>
</template>

<style scoped>
/* canvas {
    background-color: aqua;
  } */
</style>
