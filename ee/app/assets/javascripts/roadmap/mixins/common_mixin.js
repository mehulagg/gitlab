import { s__, sprintf } from '~/locale';
import {
  dateInWords,
  totalDaysInMonth,
  dayInQuarter,
  totalDaysInQuarter,
} from '~/lib/utils/datetime_utility';

import { PRESET_TYPES, DAYS_IN_WEEK } from '../constants';

export default {
  computed: {
    presetTypeQuarters() {
      return this.presetType === PRESET_TYPES.QUARTERS;
    },
    presetTypeMonths() {
      return this.presetType === PRESET_TYPES.MONTHS;
    },
    presetTypeWeeks() {
      return this.presetType === PRESET_TYPES.WEEKS;
    },
    hasToday() {
      if (this.presetTypeQuarters) {
        return (
          this.currentDate >= this.timeframeItem.range[0] &&
          this.currentDate <= this.timeframeItem.range[2]
        );
      } else if (this.presetTypeMonths) {
        return (
          this.currentDate.getMonth() === this.timeframeItem.getMonth() &&
          this.currentDate.getFullYear() === this.timeframeItem.getFullYear()
        );
      }
      const timeframeItem = new Date(this.timeframeItem.getTime());
      const headerSubItems = new Array(7)
        .fill()
        .map(
          (val, i) =>
            new Date(
              timeframeItem.getFullYear(),
              timeframeItem.getMonth(),
              timeframeItem.getDate() + i,
            ),
        );

      return (
        this.currentDate.getTime() >= headerSubItems[0].getTime() &&
        this.currentDate.getTime() <= headerSubItems[headerSubItems.length - 1].getTime()
      );
    },
  },
  methods: {
    getIndicatorStyles() {
      let left;

      // Get total days of current timeframe Item and then
      // get size in % from current date and days in range
      // based on the current presetType
      if (this.presetTypeQuarters) {
        left = Math.floor(
          (dayInQuarter(this.currentDate, this.timeframeItem.range) /
            totalDaysInQuarter(this.timeframeItem.range)) *
            100,
        );
      } else if (this.presetTypeMonths) {
        left = Math.floor(
          (this.currentDate.getDate() / totalDaysInMonth(this.timeframeItem)) * 100,
        );
      } else if (this.presetTypeWeeks) {
        left = Math.floor(((this.currentDate.getDay() + 1) / DAYS_IN_WEEK) * 100 - DAYS_IN_WEEK);
      }

      return {
        left: `${left}%`,
      };
    },
    timeframeString(roadmapItem) {
      if (roadmapItem.startDateUndefined && roadmapItem.endDateUndefined) {
        return sprintf(s__('GroupRoadmap|No start and end date'));
      } else if (roadmapItem.startDateUndefined) {
        return sprintf(s__('GroupRoadmap|No start date – %{dateWord}'), {
          dateWord: dateInWords(this.endDate, true),
        });
      } else if (roadmapItem.endDateUndefined) {
        return sprintf(s__('GroupRoadmap|%{dateWord} – No end date'), {
          dateWord: dateInWords(this.startDate, true),
        });
      }

      // In case both start and end date fall in same year
      // We should hide year from start date
      const startDateInWords = dateInWords(
        this.startDate,
        true,
        this.startDate.getFullYear() === this.endDate.getFullYear(),
      );

      const endDateInWords = dateInWords(this.endDate, true);
      return sprintf(s__('GroupRoadmap|%{startDateInWords} – %{endDateInWords}'), {
        startDateInWords,
        endDateInWords,
      });
    },
    timelineBarStyles(roadmapItem) {
      let barStyles = {};

      if (this.hasStartDate) {
        if (this.presetTypeQuarters) {
          // CSS properties are a false positive: https://gitlab.com/gitlab-org/frontend/eslint-plugin-i18n/issues/24
          // eslint-disable-next-line @gitlab/require-i18n-strings
          barStyles = `width: ${this.getTimelineBarWidthForQuarters(
            roadmapItem,
          )}px; ${this.getTimelineBarStartOffsetForQuarters(roadmapItem)}`;
        } else if (this.presetTypeMonths) {
          // eslint-disable-next-line @gitlab/require-i18n-strings
          barStyles = `width: ${this.getTimelineBarWidthForMonths()}px; ${this.getTimelineBarStartOffsetForMonths(
            roadmapItem,
          )}`;
        } else if (this.presetTypeWeeks) {
          // eslint-disable-next-line @gitlab/require-i18n-strings
          barStyles = `width: ${this.getTimelineBarWidthForWeeks()}px; ${this.getTimelineBarStartOffsetForWeeks(
            roadmapItem,
          )}`;
        }
      }
      return barStyles;
    },
  },
};
