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
      const left = Math.floor((this.currentDate.getDay() / DAYS_IN_WEEK) * 100 - DAYS_IN_WEEK);

      return {
        left: `${left}%`,
      };
    },
  },
};
