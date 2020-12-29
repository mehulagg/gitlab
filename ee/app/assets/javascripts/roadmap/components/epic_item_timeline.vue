<script>
import { GlPopover, GlProgressBar, GlIcon } from '@gitlab/ui';
import { __, sprintf } from '~/locale';
import { generateKey } from '../utils/epic_utils';

import CommonMixin from '../mixins/common_mixin';
import QuartersPresetMixin from '../mixins/quarters_preset_mixin';
import MonthsPresetMixin from '../mixins/months_preset_mixin';
import WeeksPresetMixin from '../mixins/weeks_preset_mixin';

import CurrentDayIndicator from './current_day_indicator.vue';

import {
  EPIC_DETAILS_CELL_WIDTH,
  PERCENTAGE,
  PRESET_TYPES,
  SMALL_TIMELINE_BAR,
  TIMELINE_CELL_MIN_WIDTH,
} from '../constants';

export default {
  cellWidth: TIMELINE_CELL_MIN_WIDTH,
  components: {
    CurrentDayIndicator,
    GlIcon,
    GlPopover,
    GlProgressBar,
  },
  mixins: [CommonMixin, QuartersPresetMixin, MonthsPresetMixin, WeeksPresetMixin],
  props: {
    presetType: {
      type: String,
      required: true,
    },
    timeframe: {
      type: Array,
      required: true,
    },
    timeframeItem: {
      type: [Date, Object],
      required: true,
    },
    epic: {
      type: Object,
      required: true,
    },
    clientWidth: {
      type: Number,
      required: false,
      default: 0,
    },
  },
  computed: {
    startDateValues() {
      const { startDate } = this.epic;

      return {
        day: startDate.getDay(),
        date: startDate.getDate(),
        month: startDate.getMonth(),
        year: startDate.getFullYear(),
        time: startDate.getTime(),
      };
    },
    endDateValues() {
      const { endDate } = this.epic;

      return {
        day: endDate.getDay(),
        date: endDate.getDate(),
        month: endDate.getMonth(),
        year: endDate.getFullYear(),
        time: endDate.getTime(),
      };
    },
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
    hasStartDate() {
      if (this.presetTypeQuarters) {
        return this.hasStartDateForQuarter(this.timeframeItem);
      } else if (this.presetTypeMonths) {
        return this.hasStartDateForMonth(this.timeframeItem);
      } else if (this.presetTypeWeeks) {
        return this.hasStartDateForWeek(this.timeframeItem);
      }
      return false;
    },
    timelineBarInnerStyle() {
      return {
        maxWidth: `${this.clientWidth - EPIC_DETAILS_CELL_WIDTH}px`,
      };
    },
    timelineBarWidth() {
      if (this.hasStartDate) {
        if (this.presetType === PRESET_TYPES.QUARTERS) {
          return this.getTimelineBarWidthForQuarters(this.epic);
        } else if (this.presetType === PRESET_TYPES.MONTHS) {
          return this.getTimelineBarWidthForMonths();
        } else if (this.presetType === PRESET_TYPES.WEEKS) {
          return this.getTimelineBarWidthForWeeks();
        }
      }
      return Infinity;
    },
    isTimelineBarSmall() {
      return this.timelineBarWidth < SMALL_TIMELINE_BAR;
    },
    timelineBarTitle() {
      return this.isTimelineBarSmall ? '...' : this.epic.title;
    },
    epicTotalWeight() {
      if (this.epic.descendantWeightSum) {
        const { openedIssues, closedIssues } = this.epic.descendantWeightSum;
        return openedIssues + closedIssues;
      }
      return undefined;
    },
    epicWeightPercentage() {
      return this.epicTotalWeight
        ? Math.round(
            (this.epic.descendantWeightSum.closedIssues / this.epicTotalWeight) * PERCENTAGE,
          )
        : 0;
    },
    epicWeightPercentageText() {
      return sprintf(__(`%{percentage}%% weight completed`), {
        percentage: this.epicWeightPercentage,
      });
    },
    popoverWeightText() {
      if (this.epic.descendantWeightSum) {
        return sprintf(__('%{completedWeight} of %{totalWeight} weight completed'), {
          completedWeight: this.epic.descendantWeightSum.closedIssues,
          totalWeight: this.epicTotalWeight,
        });
      }
      return __('- of - weight completed');
    },
  },
  methods: {
    generateKey,
  },
};
</script>

<template>
  <span class="epic-timeline-cell" data-qa-selector="epic_timeline_cell">
    <current-day-indicator :preset-type="presetType" :timeframe-item="timeframeItem" />
    <div class="gl-relative">
      <a
        v-if="hasStartDate"
        :id="generateKey(epic)"
        :href="epic.webUrl"
        :style="timelineBarStyles(epic)"
        :class="{ 'epic-bar-child-epic': epic.isChildEpic }"
        class="epic-bar rounded"
      >
        <div class="epic-bar-inner gl-px-3 gl-py-2" :style="timelineBarInnerStyle">
          <p class="epic-bar-title gl-text-truncate gl-m-0">{{ timelineBarTitle }}</p>

          <div v-if="!isTimelineBarSmall" class="gl-display-flex gl-align-items-center">
            <gl-progress-bar
              class="epic-bar-progress gl-flex-grow-1 gl-mr-2"
              :value="epicWeightPercentage"
              aria-hidden="true"
            />
            <div class="gl-font-sm gl-display-flex gl-align-items-center gl-white-space-nowrap">
              <gl-icon class="gl-mr-1" :size="12" name="weight" />
              <p class="gl-m-0" :aria-label="epicWeightPercentageText">
                {{ epicWeightPercentage }}%
              </p>
            </div>
          </div>
        </div>
      </a>
      <gl-popover :target="generateKey(epic)" :title="epic.title" triggers="hover" placement="left">
        <p class="gl-text-gray-500 gl-m-0">{{ timeframeString(epic) }}</p>
        <p class="gl-m-0">{{ popoverWeightText }}</p> </gl-popover
      >>
    </div>
  </span>
</template>
