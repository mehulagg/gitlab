import { getDayDifference, isToday } from '~/lib/utils/datetime_utility';
import {
  DAYS_IN_WEEK,
  HOURS_IN_DAY,
  PRESET_TYPES,
  CURRENT_DAY_INDICATOR_OFFSET,
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
    getIndicatorStyles(presetType = PRESET_TYPES.WEEKS, timeframeStartDate = new Date()) {
      const currentDate = new Date();
      const base = 100 / HOURS_IN_DAY;
      const hours = base * currentDate.getHours();
      const weeklyOffset = 100 / DAYS_IN_WEEK / 2;
      const weeklyHourOffset = (weeklyOffset / HOURS_IN_DAY) * currentDate.getHours();

      if (presetType === PRESET_TYPES.DAYS) {
        const minutes = base * (currentDate.getMinutes() / 60) - CURRENT_DAY_INDICATOR_OFFSET;

        return {
          left: `${hours + minutes}%`,
        };
      }

      if (currentDate !== timeframeStartDate) {
        const weeklyDayDifferenceOffset =
          (100 / DAYS_IN_WEEK) * getDayDifference(timeframeStartDate, currentDate);
        return {
          left: `${weeklyDayDifferenceOffset + weeklyOffset + weeklyHourOffset}%`,
        };
      }

      return {
        left: `${weeklyOffset + weeklyHourOffset}%`,
      };
    },
  },
};
