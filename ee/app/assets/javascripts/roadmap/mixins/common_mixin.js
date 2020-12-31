import { s__, sprintf } from '~/locale';
import { dateInWords } from '~/lib/utils/datetime_utility';

import { PRESET_TYPES } from '../constants';

export default {
  computed: {
    roadmapItem() {
      return this.epic ? this.epic : this.milestone;
    },
    startDateValues() {
      const { startDate } = this.roadmapItem;

      return {
        day: startDate.getDay(),
        date: startDate.getDate(),
        month: startDate.getMonth(),
        year: startDate.getFullYear(),
        time: startDate.getTime(),
      };
    },
    endDateValues() {
      const { endDate } = this.roadmapItem;

      return {
        day: endDate.getDay(),
        date: endDate.getDate(),
        month: endDate.getMonth(),
        year: endDate.getFullYear(),
        time: endDate.getTime(),
      };
    },
    presetTypeQuarters() {
      return this.presetType === PRESET_TYPES.QUARTERS;
    },
    presetTypeMonths() {
      return this.presetType === PRESET_TYPES.MONTHS;
    },
    presetTypeWeeks() {
      return this.presetType === PRESET_TYPES.WEEKS;
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
    roadmapItemIndex() {
      return this.timeframe.findIndex((item) => {
        if (this.presetTypeQuarters) {
          return this.hasStartDateForQuarter(item);
        } else if (this.presetTypeMonths) {
          return this.hasStartDateForMonth(item);
        } else if (this.presetTypeWeeks) {
          return this.hasStartDateForWeek(item);
        }
        return false;
      });
    },
  },
  methods: {
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

      return barStyles;
    },
  },
};
