export default {
  inject: ['groupId', 'weightFeatureAvailable', 'boardWeight'],
  methods: {
    extraIssueInput() {
      if (this.weightFeatureAvailable) {
        return {
          weight: this.boardWeight >= 0 ? this.boardWeight : null,
        };
      }

      return {};
    },
  },
};
