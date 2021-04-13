import { getDayDifference, isToday } from '~/lib/utils/datetime_utility';
import {
  PRESET_TYPES,
  oneHourOffsetDayView,
  oneDayOffsetWeekView,
  oneHourOffsetWeekView,
} from '../constants';

export default {
  currentDate: null,
  computed: {
    hasToday() {
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
        this.$options.currentDate.getTime() >= headerSubItems[0].getTime() &&
        this.$options.currentDate.getTime() <= headerSubItems[headerSubItems.length - 1].getTime()
      );
    },
    isToday() {
      return isToday(this.timeframeItem);
    },
  },
  beforeCreate() {
    const currentDate = new Date();
    currentDate.setHours(0, 0, 0, 0);

    this.$options.currentDate = currentDate;
  },
  methods: {
    getIndicatorStyles(
      presetType = PRESET_TYPES.WEEKS,
      timeframeStartDate = new Date(),
      timelineWidth = 1,
    ) {
      if (presetType === PRESET_TYPES.DAYS) {
        return this.getDayViewIndicatorStyles();
      }

      return this.getWeekViewIndicatorStyles(timeframeStartDate, timelineWidth);
    },
    getDayViewIndicatorStyles() {
      const currentDate = new Date();
      const hours = oneHourOffsetDayView * currentDate.getHours();
      const minutes = oneHourOffsetDayView * (currentDate.getMinutes() / 60);

      return {
        left: `${hours + minutes}%`,
      };
    },
    getWeekViewIndicatorStyles(timeframeStartDate, timelineWidth) {
      const currentDate = new Date();
      const hourOffset = oneHourOffsetWeekView * currentDate.getHours();
      const daysSinceShiftStart = getDayDifference(timeframeStartDate, currentDate);
      const leftOffset = oneDayOffsetWeekView * daysSinceShiftStart + hourOffset;

      return {
        left: `${leftOffset / timelineWidth}%`,
      };
    },
  },
};
