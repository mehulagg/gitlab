import { DAYS_IN_WEEK, HOURS_IN_DAY, PRESET_TYPES } from '../constants';
import { isToday } from '~/lib/utils/datetime_utility';

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
    getIndicatorStyles(presetType = PRESET_TYPES.WEEKS) {
      if (presetType === PRESET_TYPES.DAYS) {
        const currentDate = new Date();
        const base = 100 / HOURS_IN_DAY;
        const hours = base * currentDate.getHours();
        const minutes = base * (currentDate.getMinutes() / 60) - 2.25;

        return {
          left: `${hours + minutes}%`,
        };
      }

      const left = 100 / DAYS_IN_WEEK / 2;
      return {
        left: `${left}%`,
      };
    },
  },
};
