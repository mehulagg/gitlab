import { PRESET_TYPES, DAYS_IN_WEEK } from '../constants';
import { dayInQuarter, totalDaysInQuarter, totalDaysInMonth } from '~/lib/utils/datetime_utility';

export default {
  computed: {
    todaysIndex() {
      const currentDate = new Date();
      currentDate.setHours(0, 0, 0, 0);

      return this.timeframe.findIndex((item) =>
        this.isTimeframeForToday(item, currentDate, this.presetType),
      );
    },
  },
  methods: {
    isTimeframeForToday(timeframeItem, currentDate, presetType) {
      if (presetType === PRESET_TYPES.QUARTERS) {
        return currentDate >= timeframeItem.range[0] && currentDate <= timeframeItem.range[2];
      } else if (presetType === PRESET_TYPES.MONTHS) {
        return (
          currentDate.getMonth() === timeframeItem.getMonth() &&
          currentDate.getFullYear() === timeframeItem.getFullYear()
        );
      }
      const itemTime = new Date(timeframeItem.getTime());
      const headerSubItems = new Array(7)
        .fill()
        .map(
          (_, i) => new Date(itemTime.getFullYear(), itemTime.getMonth(), itemTime.getDate() + i),
        );

      return (
        currentDate.getTime() >= headerSubItems[0].getTime() &&
        currentDate.getTime() <= headerSubItems[headerSubItems.length - 1].getTime()
      );
    },
    getIndicatorStyles(presetType, timeframeItem) {
      const currentDate = new Date();
      currentDate.setHours(0, 0, 0, 0);

      let left;

      // Get total days of current timeframe Item and then
      // get size in % from current date and days in range
      // based on the current presetType
      if (presetType === PRESET_TYPES.QUARTERS) {
        left = Math.floor(
          (dayInQuarter(currentDate, timeframeItem.range) /
            totalDaysInQuarter(timeframeItem.range)) *
            100,
        );
      } else if (presetType === PRESET_TYPES.MONTHS) {
        left = Math.floor((currentDate.getDate() / totalDaysInMonth(timeframeItem)) * 100);
      } else if (presetType === PRESET_TYPES.WEEKS) {
        left = Math.floor(((currentDate.getDay() + 1) / DAYS_IN_WEEK) * 100 - DAYS_IN_WEEK);
      }

      return {
        left: `${left}%`,
      };
    },
  },
};
