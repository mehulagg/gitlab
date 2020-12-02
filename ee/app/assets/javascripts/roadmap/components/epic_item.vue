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
  CURRENT_DAY_INDICATOR_COLOR,
} from '../constants';

export default {
  epicItemHeight: EPIC_ITEM_HEIGHT,
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
  data() {
    const currentDate = new Date();
    currentDate.setHours(0, 0, 0, 0);

    return {
      currentDate,
    };
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
      return this.timeframe.length * TIMELINE_CELL_MIN_WIDTH;
    },
    /**
     * The index of the timeframe that includes the current date.
     * ex. let timeframe be [ timeframeItem0, timeframeItem1 ].
     * If today is in timeframeItem1, we should return 1.
     */
    currentDayTimeframeIndex() {
      return this.timeframe.findIndex(timeframeItem => {
        return this.timeframeHasToday(timeframeItem);
      });
    },
  },
  watch: {
    timeframe: {
      deep: true,
      handler() {
        window.requestAnimationFrame(this.updateCanvas);
      },
    },
  },
  mounted() {
    window.requestAnimationFrame(this.updateCanvas);
  },
  updated() {
    this.removeHighlight();
  },
  methods: {
    updateCanvas() {
      const { canvas } = this.$refs;
      const ctx = canvas.getContext('2d');

      // Draw grid
      ctx.beginPath();
      ctx.strokeStyle = GRID_COLOR;
      ctx.lineWidth = 1;
      this.timeframe
        .map((_, i) => i * TIMELINE_CELL_MIN_WIDTH - 0.5)
        .forEach(x => {
          ctx.moveTo(x, 0);
          ctx.lineTo(x, EPIC_ITEM_HEIGHT);
        });
      ctx.moveTo(0, EPIC_ITEM_HEIGHT - 0.5);
      // TODO check if clientWidth can be used
      ctx.lineTo(this.canvasWidth, EPIC_ITEM_HEIGHT - 0.5);
      // console.log('line to:', this.canvasWidth);
      ctx.stroke();

      // Draw current time indicator (vertical line)
      ctx.beginPath();
      ctx.strokeStyle = CURRENT_DAY_INDICATOR_COLOR;
      ctx.lineWidth = 2;
      const leftOffset = this.getIndicatorOffset(this.timeframe[this.currentDayTimeframeIndex]);
      // console.log(leftOffset)
      ctx.moveTo(
        this.currentDayTimeframeIndex * TIMELINE_CELL_MIN_WIDTH +
          0.5 +
          (TIMELINE_CELL_MIN_WIDTH * leftOffset) / 100.0,
        0,
      );
      ctx.lineTo(
        this.currentDayTimeframeIndex * TIMELINE_CELL_MIN_WIDTH +
          0.5 +
          (TIMELINE_CELL_MIN_WIDTH * leftOffset) / 100.0,
        EPIC_ITEM_HEIGHT,
      );
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
    <div :class="{ 'newly-added-epic': epic.newEpic }" class="epics-list-item gl-relative clearfix">
      <epic-item-details
        :epic="epic"
        :current-group-id="currentGroupId"
        :timeframe-string="timeframeString(epic)"
        :child-level="childLevel"
        :children-flags="childrenFlags"
        :has-filters-applied="hasFiltersApplied"
        :is-children-empty="isChildrenEmpty"
      />
      <canvas
        ref="canvas"
        :height="`${this.$options.epicItemHeight}px`"
        :width="`${canvasWidth}px`"
        class="epic-timeline-canvas gl-display-block"
      ></canvas>
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
