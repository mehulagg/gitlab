import { DAYS_IN_WEEK, HOURS_IN_DAY, PRESET_TYPES } from '../constants';

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
  },
  beforeCreate() {
    const currentDate = new Date();
    currentDate.setHours(0, 0, 0, 0);

    this.$options.currentDate = currentDate;
  },
  methods: {
    getIndicatorStyles(presetType = PRESET_TYPES.WEEKS) {
      if (presetType === PRESET_TYPES.DAYS) {
        return {
          left: `${(100 / HOURS_IN_DAY) * (new Date().getHours() + 1)}%`,
        };
      }

      const left = 100 / DAYS_IN_WEEK / 2;
      return {
        left: `${left}%`,
      };
    },
  },
};
