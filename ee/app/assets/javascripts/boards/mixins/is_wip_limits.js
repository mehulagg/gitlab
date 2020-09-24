export default {
  computed: {
    isWipLimitsOn() {
      return Boolean(gon?.features?.wipLimits);
    },
  },
};
