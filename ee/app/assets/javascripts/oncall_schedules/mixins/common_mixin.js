import { DAYS_IN_WEEK } from '../constants';

export default {
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
        this.currentDate.getTime() >= headerSubItems[0].getTime() &&
        this.currentDate.getTime() <= headerSubItems[headerSubItems.length - 1].getTime()
      );
    },
  },
  methods: {
    getIndicatorStyles() {
      // as we start schedule scale from the current date the indicator will always be on the first date. So we find
      // the percentage of space one day cell takes and divide it by 2 cause the tick is in the middle of the cell.
      // It might be updated to more precise position - time of the day
      const left = 100 / DAYS_IN_WEEK / 2;

      return {
        left: `${left}%`,
      };
    },
  },
};
